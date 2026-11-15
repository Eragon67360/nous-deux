// Helpers for the internal functions, which only the database calls.

/// The database sends PUSH_WEBHOOK_SECRET with every request to these
/// functions (see the push_webhooks migration). Fail closed: without it set,
/// nothing passes.
export function fromDatabase(req: Request): boolean {
  const secret = Deno.env.get("PUSH_WEBHOOK_SECRET");
  return !!secret && req.headers.get("x-webhook-secret") === secret;
}

export function json(body: unknown): Response {
  return new Response(JSON.stringify(body), {
    headers: { "Content-Type": "application/json" },
    status: 200,
  });
}
