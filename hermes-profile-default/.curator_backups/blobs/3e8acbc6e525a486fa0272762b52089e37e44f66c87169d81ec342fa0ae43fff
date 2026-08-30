# Reading cron job status without over-diagnosing (learned 2026-08-29)

Avi's job list showed `Vault curation — first protected session` as
`last_status: error`, `enabled: false`, `state: completed`, with a
`RuntimeError: [drift_skip] Skipped to prevent unintended spend` in its log
(provider/model config drifted since job creation; job was unpinned). I read
that as a "silent failure" — that a protected session reminder had fired,
errored, and never reached Avi.

That was wrong. Avi corrected me: **the reminder had delivered and he was busy
that day and told me to forget it.** The `error` status reflected a guardrail
(drift-skip on an unpinned job), not a delivery failure — and the user had
already handled the underlying item.

## Rules

1. `last_status=error` ≠ "user never saw it." Distinguish two separate facts:
   - Did the job run successfully / hit a guardrail? (status + log)
   - Did the intended notification reach and get handled by the user?
   Verify actual delivery with the user before declaring a silent failure.
2. A consumed one-shot job (`enabled: false`, `state: completed`) dropping off
   the active list is normal bookkeeping, not itself evidence of lost work.
   Check `~/.hermes/cron/output/<job_id>/` for the run log before concluding
   anything is unrecoverable.
3. If the user explicitly deferred or deleted the item the job was reminding
   about, do not re-litigate it as a failure. A closed-by-user item is not a
   lost item.
4. A `drift-skip` on an unpinned job is a cost-safety guardrail, not an error
   in the system — it means the job's model/provider config moved since
   creation. Fix by pinning the job's model/provider, not by treating the skip
   as a bug.

## Prefer asking before escalating

When a scheduled item looks failed, the cheapest high-signal step is usually to
ask the user whether they received/handled it — not to launch a scheduler
autopsy. Avi sets the scope of any investigation himself.
