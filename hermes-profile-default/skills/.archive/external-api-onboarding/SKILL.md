---
name: external-api-onboarding
description: "Use when onboarding a third-party API. Verify status first."
version: 1.0.0
author: Alyosha
---

# External API Onboarding

Use when connecting an external business platform API to an internal collector, reporting feed, or automation—especially when onboarding requires registration, approval, OAuth, developer-console setup, or a vendor support case.

## Operating rule

Do **not** infer the current stage from an email subject, a generic account notice, an old workboard entry, or an assumed console flow. Establish the actual state of the application and its linked client application before telling the user what action remains.

## Procedure

1. **Separate the systems involved.** Identify the provider API, developer account, OAuth/client application, business/advertiser account, and any internal consumer of the resulting credentials. Do not treat existing credentials for a different API on the same platform as interchangeable.
2. **Find the vendor’s current official onboarding sequence.** Read the provider’s developer documentation, not a third-party tutorial, and record each gated transition: client creation, application, approval, client assignment, account consent, token exchange, and first authenticated probe.
3. **Reconcile the application record.** Obtain the original submission acknowledgment/case ID and the full vendor email thread from the account used to apply. Check Inbox, Spam, and All Mail before declaring a vendor response missing, final, or unrelated.
4. **Classify vendor correspondence precisely.** A generic developer-account, identity-verification, policy, or billing message is not proof of API approval, rejection, or completion unless it explicitly states the API application status or contains the documented next-step artifact.
5. **Use the exact next action for the verified stage.**
   - If an application is awaiting review beyond the vendor’s stated timeframe: send a concise status request through the vendor’s official API-support channel, preserving the application/case evidence.
   - If approval is confirmed: follow the vendor’s documented client-assignment and OAuth-consent flow using the same identity required by the vendor.
   - If a workflow link is one-time or identity-bound: do not open it under a different logged-in account; request a reset if that occurred.
6. **Protect credentials.** Never paste client secrets, refresh tokens, or authorization codes into chat, tickets, or general notes. Store them only in the approved secret location.
7. **Activate only after a real probe.** Before enabling a scheduled collector, make a bounded authenticated request and verify the expected profile/account and fields. Then enable the collector and read back its output.

## User-facing reporting

State these separately:
- **Verified current stage** and the evidence that supports it.
- **What remains unknown** and what source will resolve it.
- **Exact next action** and who must perform it.
- **Downstream activation condition**—what is blocked and the concrete test that unblocks it.

Never turn a stale estimate into a current commitment. If a previous operating note names an obsolete path, correct the note after reconciling against vendor documentation and primary correspondence.

## Pitfalls

- Treating a response from a platform as confirmation that it answered the *specific* API application.
- Claiming an application is still pending without inspecting the actual correspondence or current status surface.
- Skipping the client-application assignment step after approval.
- Confusing business-account roles or a different platform API with API access approval.
- Enabling the internal collector on the strength of an email rather than an authenticated data probe.
- Opening a one-time approval link while signed in to the wrong identity and thereby invalidating it.

## Provider references

- `references/amazon-ads-api.md` — official Amazon Ads onboarding sequence, approval artifact, support escalation, and verification checklist.

## Completion checklist

- [ ] Provider’s official onboarding documentation checked.
- [ ] Original application submission and complete correspondence reconciled.
- [ ] Actual onboarding stage supported by primary evidence.
- [ ] Client/app assignment completed where required.
- [ ] OAuth consent and token exchange completed without exposing secrets.
- [ ] Bounded authenticated API probe succeeds against the intended account.
- [ ] Downstream collector enabled only after the probe and its output read back.
