# AgentMail attachment download (verified 8/10)

When Hollow attaches files (CSV/JSON handoffs) to a coordination-lane message,
this is the working recipe. It is NOT in the user-owned `agentmail-integration`
skill — keep this copy current if that skill changes.

## The three-step shape

1. **List** (`/inboxes/{inbox}/messages?limit=N`) does NOT include attachments.
   You must GET the **full message** to see them:
   `GET /inboxes/{inbox}/messages/{urlencoded_message_id}` → `attachments: [{attachment_id, filename, size, ...}]`
2. **Attachment endpoint returns JSON metadata, NOT bytes:**
   `GET /inboxes/{inbox}/messages/{msg_id}/attachments/{attachment_id}`
   → `{attachment_id, filename, size, content_type, download_url}` where
   `download_url` is a signed CDN URL (`https://cdn.agentmail.to/attachments/...?Expires=...&Signature=...`).
3. **Fetch the `download_url`** (no Authorization header — it's pre-signed) to get the real bytes.

## Pitfall (hit live 8/10)

Writing the attachment-endpoint response straight to a file silently saves the
JSON metadata, not the file. Symptom: file size on disk (~1.2KB) doesn't match
the metadata `size` field (11–15KB). Always compare saved byte count to
`attachments[].size`.

## Python sketch (stdlib urllib)

```python
# after reading full message -> msg (dict with 'attachments')
for att in msg['attachments']:
    meta = get_json(f"inboxes/{inbox}/messages/{mid}/attachments/{att['attachment_id']}")
    req = urllib.request.Request(meta['download_url'])
    with urllib.request.urlopen(req) as r:
        data = r.read()
    assert len(data) == att['size'], f"size mismatch: {len(data)} != {att['size']}"
    open(dest + att['filename'], 'wb').write(data)
```
