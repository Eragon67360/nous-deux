// End-to-end check of the self-hosted Supabase, as the app uses it.
// Run after a deploy or an upgrade:
//   SUPABASE_URL=https://api.nous-deux.app SUPABASE_ANON_KEY=... \
//   SMOKE_PHONES=447700900001:123456,447700900002:654321 npm run smoke
// The two phones must be GOTRUE_SMS_TEST_OTP numbers. The test leaves the
// couple at the end, so the accounts stay free for other tests. Wait a minute
// between runs: a number can request a code once every 60 seconds.
import { createClient } from '@supabase/supabase-js'

const url = process.env.SUPABASE_URL
const anonKey = process.env.SUPABASE_ANON_KEY
const phones = (process.env.SMOKE_PHONES ?? '').split(',').map((p) => p.split(':'))
if (!url || !anonKey || phones.length !== 2 || phones.some((p) => p.length !== 2)) {
  console.error('Set SUPABASE_URL, SUPABASE_ANON_KEY and SMOKE_PHONES=phone:code,phone:code')
  process.exit(2)
}

let failed = 0
const check = (ok, what, detail = '') => {
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${what}${detail ? ` (${detail})` : ''}`)
  if (!ok) failed++
}
const within = (ms, promise) =>
  Promise.race([promise, new Promise((resolve) => setTimeout(() => resolve('timeout'), ms))])

const client = () =>
  createClient(url, anonKey, { auth: { persistSession: false, autoRefreshToken: false } })

// 1. Gateway, auth and RLS
{
  const res = await fetch(`${url}/auth/v1/health`, { headers: { apikey: anonKey } })
  check(res.ok, 'auth is up', `HTTP ${res.status}`)
  const { data, error } = await client().from('profiles').select('id')
  check(!error && data.length === 0, 'signed out, profiles are hidden', error?.message)
  const fn = await fetch(`${url}/functions/v1/notify-partner-ping`, { method: 'POST' })
  const body = await fn.text()
  check(fn.status !== 200 && !body.includes('forbidden'), 'push functions are not public', `HTTP ${fn.status}`)
}

// 2. Phone sign-in with test codes
const people = []
for (const [phone, code] of phones) {
  const sb = client()
  const sent = await sb.auth.signInWithOtp({ phone: `+${phone}` })
  check(!sent.error, `code requested for +${phone}`, sent.error?.message)
  const { data, error } = await sb.auth.verifyOtp({ phone: `+${phone}`, token: code, type: 'sms' })
  check(!error && !!data.session, `signed in as +${phone}`, error?.message)
  if (error) process.exit(1)
  people.push({ sb, id: data.user.id })
}
const [a, b] = people

// 3. Profiles and pairing, the app's way
for (const [p, name] of [[a, 'Smoke A'], [b, 'Smoke B']]) {
  const { error } = await p.sb.from('profiles').upsert({ id: p.id, username: name })
  check(!error, `profile ${name}`, error?.message)
}
await a.sb.rpc('leave_couple') // in case an earlier run stopped half-way
await b.sb.rpc('leave_couple')
const code = 'SMK' + Math.floor(Math.random() * 1000).toString().padStart(3, '0')
const created = await a.sb.from('couples').insert({ user1_id: a.id, pairing_code: code }).select().single()
check(!created.error, 'A creates a couple', created.error?.message)
const today = new Date().toISOString().slice(0, 10)
const joined = await b.sb
  .from('couples')
  .update({ user2_id: b.id, together_since: today })
  .eq('id', created.data?.id)
check(!joined.error, 'B joins with the code', joined.error?.message)
const { data: linked } = await a.sb.from('profiles').select('partner_id').eq('id', a.id).single()
check(linked?.partner_id === b.id, 'profiles linked')
const coupleId = created.data?.id

// 4. Realtime: B hears A delete a list item (deletes are heard unfiltered)
{
  const list = await a.sb.from('shared_lists').insert({ couple_id: coupleId, name: 'Smoke' }).select().single()
  const item = await a.sb
    .from('shared_list_items')
    .insert({ list_id: list.data?.id, couple_id: coupleId, text: 'Pain' })
    .select()
    .single()
  check(!list.error && !item.error, 'A adds a list and an item', list.error?.message ?? item.error?.message)
  let heard
  const gotDelete = new Promise((resolve) => (heard = resolve))
  const channel = b.sb
    .channel('smoke-items')
    .on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'shared_list_items' }, (p) => {
      if (p.old?.id === item.data?.id) heard('heard')
    })
  const subscribed = await within(10000, new Promise((resolve) => channel.subscribe((s) => s === 'SUBSCRIBED' && resolve('ok'))))
  check(subscribed === 'ok', 'B subscribes to live changes', subscribed)
  // The database side of the subscription is set up just after SUBSCRIBED.
  await new Promise((resolve) => setTimeout(resolve, 2000))
  await a.sb.from('shared_list_items').delete().eq('id', item.data?.id)
  check((await within(10000, gotDelete)) === 'heard', "B sees A's delete live")
  await b.sb.removeChannel(channel)
  await a.sb.from('shared_lists').delete().eq('id', list.data?.id)
}

// 5. Storage: avatar upload and its public URL
{
  const path = `${a.id}/avatar.jpg`
  // Smallest valid JPEG
  const jpeg = Buffer.from('/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////wgALCAABAAEBAREA/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABPxA=', 'base64')
  const up = await a.sb.storage.from('avatars').upload(path, jpeg, { upsert: true, contentType: 'image/jpeg' })
  check(!up.error, 'A uploads an avatar', up.error?.message)
  const publicUrl = a.sb.storage.from('avatars').getPublicUrl(path).data.publicUrl
  const res = await fetch(publicUrl)
  check(res.ok && publicUrl.startsWith(url), 'its public URL is served', `HTTP ${res.status}`)
  await a.sb.storage.from('avatars').remove([path])
}

// 6. Push chain: the ping triggers the database → function call. Its answer
//    lands in net._http_response, checked on the server (see the runbook).
{
  const { data, error } = await a.sb.rpc('send_ping', { p_kind: 'kiss' })
  check(!error && data?.kind === 'kiss', 'A sends a little note', error?.message)
  // The database sends the push after the write commits; let the function
  // read the note before the couple (and the note) is deleted below. The
  // first call after a restart also downloads the function's libraries.
  await new Promise((resolve) => setTimeout(resolve, 8000))
}

// 7. Leave: everything shared goes
{
  const { error } = await a.sb.rpc('leave_couple')
  check(!error, 'A leaves the couple', error?.message)
  const { data } = await b.sb.from('couples').select('id')
  check(data?.length === 0, 'B no longer sees a couple')
}

console.log(failed ? `\n${failed} check(s) failed` : '\nall checks passed')
process.exit(failed ? 1 : 0)
