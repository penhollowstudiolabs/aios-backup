# Slow Telegram responses — diagnostic recipe

Avi's most common "something is wrong" symptom. Use this to determine whether
slow replies are **model inference over context** (almost always) vs the
network/pipe (rarely).

## 1. Model-layer latency (the real cause in practice)

Wall-clock per message, from the gateway:
```bash
tail -30 /root/.hermes/profiles/alyosha/logs/gateway.log | grep "response ready"
# e.g. time=229.4s api_calls=1  -> the model took that long by itself
```
Per-call latency + raw token counts, from the agent:
```bash
grep -E "API call" /root/.hermes/profiles/alyosha/logs/agent.log | tail -10
# e.g. in=127,499 out=2,569 latency=63.7s cache=125184/127499 (98%)
```
- `in=` equals the session context size. When it has ballooned to ~100k+ tokens
  (a long-running session all day), a single call legitimately takes 40–65s.
- `cache=... (98%)` means the context is cached but still slow — the model
  still has to read the whole (cached) context before generating. So cache hits
  help cost, not latency.

## 2. Rule out the pipe (quick, decisive)

```bash
time curl -s -o /dev/null -w "HTTP %{http_code} in %{time_total}s\n" https://openrouter.ai/api/v1/models   # ~0.06s
time curl -s -o /dev/null -w "HTTP %{http_code} in %{time_total}s\n" https://api.telegram.org             # ~0.45s
tailscale status
for p in ilocos avi-laptop avi-iphone; do ping -c1 -W2 $p >/dev/null 2>&1; echo "$p: $?"; done
uptime   # load usually 0.0x — proves CPU/mem aren't the bottleneck
```
If OpenRouter answers in ~60ms and peers ping clean, the network is exonerated.

## 3. The fix
- Fresh session or `/compact` on the Telegram side drops the ~127k context to
  near-zero; a cold ~20k-token call returns in 6–12s (see a newly-started
  desktop session's `API call #N` latencies as the baseline).
- Start the fresh session BEFORE running the long/durable task so it lands with
  a small context.
- Durable vault writes survive session end regardless — verify with the
  `ob-sync` steps in `vault-sync-verification.md`.
