// What the database asks of wake-partner-calendar (migration
// 20261117200000_calendar_follow.sql): someone opened the couple's calendar,
// so their partner's phone should sync the calendars it follows. The push
// shows nothing; it only carries its type (docs/CALENDAR_SYNC.md, Task 2).

import { fromDatabase, json } from "../_shared/database.ts";

export interface Profile {
  fcm_token: string | null;
  calendar_sync_device: string | null;
}

export interface Deps {
  /// The person to wake, or null when the account is gone.
  loadProfile: (userId: string) => Promise<Profile | null>;
  sendBackgroundPush: (
    token: string,
    data: Record<string, string>,
  ) => Promise<{ ok: boolean; detail?: string }>;
}

export async function handleWake(req: Request, deps: Deps): Promise<Response> {
  if (!fromDatabase(req)) return new Response("forbidden", { status: 403 });

  let userId: unknown;
  try {
    userId = (await req.json())?.record?.user_id;
  } catch {
    userId = undefined;
  }
  if (typeof userId !== "string") return json({ ok: false, skipped: "not a wake" });

  const profile = await deps.loadProfile(userId);
  if (!profile) return json({ ok: true, skipped: "no profile" });
  // They may have stopped following since the wake was asked for.
  if (!profile.calendar_sync_device) return json({ ok: true, skipped: "not following" });
  if (!profile.fcm_token) return json({ ok: true, skipped: "no token" });

  const result = await deps.sendBackgroundPush(profile.fcm_token, { type: "calendar_sync" });
  if (!result.ok) {
    // FCM's answer can name the token; log only that it failed.
    console.error("wake-partner-calendar: FCM refused the push");
    return json({ ok: false });
  }
  return json({ ok: true });
}
