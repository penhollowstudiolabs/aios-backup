# Calendar sync verification (Outlook → Google)

Use when asked whether the work Outlook→Google calendar sync is still alive
(Avi's pre-VPS setup, untouched over a long break, or after he's been away).
Verify with live evidence, never assume from the presence of events.

## Working method (verified 8/10)

1. Enumerate calendars via `calendarList().list()`. The work mirror typically
   appears as a Google **import calendar**: id ends `@import.calendar.google.com`
   (human label often just "Calendar"). Not all its events are sync evidence —
   see the origin markers below.

2. Pull events from that import calendar over a wide window (full year) and
   inspect each event's `created` timestamp.
   - **Fresh `created` batches during a period Avi wasn't manually working =
     sync is alive.** Observed: 92 events created in April (initial bulk),
     then 5–12/month dribble through Aug — an ongoing import, not one-shot.
   - A-flat timeline (nothing created recently) points to a dead/manual setup.

3. Distinguish sync vs native/manual origin:
   - **Native Google events:** `iCalUID` ends `@google.com`; `creator`/`organizer`
     = the personal gmail. A recurring series made this way proves NOTHING about
     sync (Avi set the UHS weekly series up natively; it fooled us once).
   - **Imported/synced events:** the import calendar itself as creator, long
     base32-ish event IDs, and often the original invite text embedded in
     `description` (e.g. IUSD Compass registration emails survived in full).
4. The definitive human test: this week's events Avi recognizes that he did NOT
   hand-enter. Confirm with him explicitly before declaring the sync alive.

## False positives that look like evidence (corrected 8/10 — don't repeat)
- Recurring department-meeting series Avi entered by hand earlier → not sync.
- TK/school events for Ravi (son) → family, not work-sync proof.
- Kathleen's / Family / Classroom calendars empty in a window → not a verdict.

## Not a sync verdict either way
Hollow confirmed 11/10 and 12/16 Department Meetings are MANUALLY added on the
primary calendar (from the operational Fall meeting calendar), while 9/16 and
10/14 arrive from Outlook via the import mirror. Mixed sources are normal —
ask which is authoritative for the brief rather than assuming one flow.
