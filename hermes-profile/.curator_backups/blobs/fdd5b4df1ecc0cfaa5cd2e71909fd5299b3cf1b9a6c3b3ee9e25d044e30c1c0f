# AgentMail — reading the full body of a coordination-lane message (verified 8/12)

The AgentMail **list endpoint omits the message body**. When you need more than
the `preview` (e.g. to file a Hollow handoff into the vault, or to check whether
a message made a claim you're about to curate), you must fetch the full message
by id.

## The two-step shape

1. **List** to find the message id:
   `GET /v0/inboxes/{inbox}/messages?limit=20`
   Each item has `message_id` (a long `<...@email.amazonses.com>` opaque id),
   `preview` (truncated ~400 chars), `subject`, `timestamp`. NOTE: `id` is
   `None` in the list — the real identifier is `message_id`.

2. **GET the full message** (URL-encode the message_id):
   `GET /v0/inboxes/{inbox}/messages/{urlencoded_message_id}`
   → returns `text`, `html`, `extracted_text`, `extracted_html` plus the metadata.
   Read `.get("text")` for the plain body.

## Pitfalls (hit live 8/12)
- The list item's `id` field is `None`; use `message_id`, and it must be
  URL-encoded (`urllib.parse.quote(mid, safe="")`) because it contains `<` `>` `@`.
- `preview` is truncated and starts mid-sentence — never curate a handoff from
  the preview alone. A Hollow "end-of-day checkpoint" handoff needed its full
  `text` to know the exact commit-pending state and what to file.

## Python sketch (stdlib urllib)

```python
import urllib.request, urllib.parse, json

def get_json(url, key):
    req = urllib.request.Request(url, headers={"Authorization": "Bearer " + key})
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.load(r)

# 1. list
data = get_json(f"https://api.agentmail.to/v0/inboxes/{INBOX}/messages?limit=20", key)
mid = next(m["message_id"] for m in data["messages"]
           if "SUBJECT_PHRASE" in (m.get("subject") or ""))
# 2. full message
mid_enc = urllib.parse.quote(mid, safe="")
full = get_json(f"https://api.agentmail.to/v0/inboxes/{INBOX}/messages/{mid_enc}", key)
body = full.get("text") or ""
```

This complements `agentmail-attachment-download.md` (attachments) and
`agentmail-send-from-aios.md` (sending). The watchdog `check_agentmail.py`
already surfaces previews for alerting; use this pattern only when you actually
need the full body to act on a handoff.
