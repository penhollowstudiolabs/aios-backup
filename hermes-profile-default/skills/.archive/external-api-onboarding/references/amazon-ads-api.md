# Amazon Ads API — Reconciled Onboarding Reference

**Primary documentation checked:** 2026-08-24.

## Official onboarding sequence

1. Create a **new Login with Amazon (LwA) security profile** in Amazon Developer. Existing SP-API LwA credentials are not the Ads API client application.
2. A **Direct Advertiser** submits the Amazon Ads API application while signed in with the same email address used for the Amazon Developer account.
3. After approval, Amazon sends an email containing a link to **assign API access** to the selected LwA application.
4. Before opening that link, log out of all other Amazon identities. Opening it under the wrong identity invalidates it; Amazon API Support must reset it.
5. The assignment confirmation should show the client ID and `advertising::campaign_management` scope.
6. The advertiser completes the OAuth consent flow for that client. Exchange the authorization code for access and refresh tokens; retrieve the intended Ads profile ID.
7. Make a bounded authenticated request (for example, profile discovery or a narrow reporting request). Only then enable the collector and confirm its output fields.

## Application-status escalation

Amazon’s onboarding overview says approval may take up to one business day. If that time has passed and no explicit approval, rejection, or assignment link can be found, first reconcile the original application acknowledgment and full email thread (Inbox, Spam, All Mail) under the application identity.

Then use Amazon’s published API support contact:

- `ads-api-support@amazon.com`
- CC: `ads-api-onboarding@amazon.com`

Include: business name, Direct Advertiser status, date of application, application/case evidence, and a precise request for application status plus reissue of the assignment link if approval already occurred.

## What does *not* establish Ads API status

- Amazon Developer Console identity-verification notices for Appstore publishing.
- Seller Central role assignments.
- Existing Selling Partner API authorization.
- A generic vendor email that lacks an Ads API approval/rejection or documented assignment artifact.

## Sources

- Amazon Ads API onboarding overview: https://advertising.amazon.com/API/docs/en-us/guides/onboarding/overview
- Apply for API access: https://advertising.amazon.com/API/docs/en-us/guides/onboarding/apply-for-access
- Assign API access to an LwA application: https://advertising.amazon.com/API/docs/en-us/guides/onboarding/assign-api-access
- Authorization overview: https://advertising.amazon.com/API/docs/en-us/guides/account-management/authorization/overview
- Amazon Ads API support contacts: https://amazon-ads-api.zendesk.com/hc/en-us/articles/25110088401435-Need-Support-Find-your-Answers-Here
