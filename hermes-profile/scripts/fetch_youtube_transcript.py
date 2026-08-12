#!/usr/bin/env python3
"""Fetch YouTube transcripts via youtube-transcript.io API (works from VPS datacenter IP).

Usage:
  fetch_youtube_transcript.py <youtube_url_or_id> [--out file.json]

Reads API key from YOUTUBE_TRANSCRIPT_API_KEY env var (profile .env).
Output: JSON array of {text, start, dur} segments; prints to stdout unless --out.

Notes:
- Free tier returns the video's DEFAULT caption track only; there is NO language
  selection on the /api/transcripts endpoint (the `language` param is ignored).
- The API 403s on urllib's default User-Agent; must send a browser UA.
- Rare edge: videos with captions disabled return an error for that id.
"""
import json, os, re, sys, urllib.request

UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

def video_id(url):
    if not url:
        return None
    m = re.search(r'(?:v=|youtu\.be/|shorts/|embed/)([\w-]{11})', url)
    if m:
        return m.group(1)
    if re.fullmatch(r'[\w-]{11}', url.strip()):
        return url.strip()
    return None

def fetch(ids):
    key = os.environ.get("YOUTUBE_TRANSCRIPT_API_KEY", "").strip()
    if not key:
        sys.exit("ERR: YOUTUBE_TRANSCRIPT_API_KEY not set in profile .env")
    req = urllib.request.Request(
        "https://www.youtube-transcript.io/api/transcripts",
        data=json.dumps({"ids": ids}).encode(),
        headers={"Authorization": f"Basic {key}", "Content-Type": "application/json",
                 "User-Agent": UA},
        method="POST")
    with urllib.request.urlopen(req, timeout=90) as resp:
        return json.loads(resp.read().decode())

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit("usage: fetch_youtube_transcript.py <url_or_id> [--out file.json]")
    url = sys.argv[1]
    out = None
    if "--out" in sys.argv:
        i = sys.argv.index("--out")
        if i + 1 < len(sys.argv):
            out = sys.argv[i + 1]
    vid = video_id(url)
    if not vid:
        sys.exit(f"ERR: could not parse video id from: {url}")
    try:
        result = fetch([vid])
    except Exception as e:
        sys.exit(f"ERR: {e}")
    if out:
        with open(out, "w") as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"OK: {len(result)} segments -> {out}")
    else:
        print(json.dumps(result, ensure_ascii=False))
