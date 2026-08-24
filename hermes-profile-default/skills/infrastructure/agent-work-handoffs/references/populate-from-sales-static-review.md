# Verified pilot — static review before a live importer write

## Pattern
Alyosha issued a read-only handoff card to Dewey for a laptop-local PHP importer. Dewey inspected source only, produced one return report in `Atlas/_Inbox`, and made no external changes. Alyosha compared the return against Mayumi's approved import contract.

## Outcome
The review confirmed the intended delivered-only status mapping, pending/canceled skips, title-to-padded-SKU resolution, PII exclusion, and idempotency. It found a production blocker: a leading-number regex would map the packing-supply title `100 Pcs Clear Plant Label` to false plant SKU `PLT-0100`.

## Lesson
Static contract review is a cheap, high-value gate before a live data write. A documented business exception is not safe until the actual implementation enforces it. Require a code fix and target-environment validation before approving the live run.

## Operational detail
The source task card and return artifact were placed in `Atlas/_Inbox`. The card itself did not dispatch work; Avi explicitly instructed Dewey to execute it.
