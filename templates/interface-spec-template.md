# Interface Specification

> One per integration point. Referenced from the SDD §8 integration register.
> Build-ready: an offshore developer and an Integration Suite developer should
> both be able to build their side from this without a call.

## 1. Header

| Field | Value |
|---|---|
| Interface ID | IF-XX |
| Name | |
| SDD / FS reference | |
| Direction | S/4 → external / external → S/4 / bidirectional |
| Source system | |
| Target system | |
| Status | Draft / Approved / Built |
| Owner | |

## 2. Purpose & Trigger

- Business purpose (one paragraph).
- Trigger: user action / RAP event / scheduled job / inbound call — be specific
  (e.g. "on billing document release, RAP raise-event `BillingDocReleased`").
- Frequency & timing window.

## 3. Pattern

| Aspect | Value |
|---|---|
| Style | Synchronous request/response / Asynchronous event / Batch file / Query |
| Protocol | OData V4 / SOAP / REST / SFTP / IDoc-replacement event |
| Released API used | name + API state (verify in ADT / Accelerator Hub) |
| Middleware | Integration Suite iFlow / API Management proxy / Event Mesh topic / direct |
| Mode | Real-time / near-real-time / scheduled (cron) |

## 4. Payload

- **Structure** — field table or schema reference.

| Field | Type / length | Source (CDS / BO field) | Mandatory | Notes / mapping |
|---|---|---|---|---|

- **Sample message** — one realistic example (redacted).
- **Volume** — messages/day, peak/hour, average & max payload size.
- **PII / sensitivity** — fields needing masking, encryption, or logging exclusion.

## 5. Security

| Aspect | Value |
|---|---|
| Authentication | OAuth2 client credentials / mTLS / API key / basic (discouraged) |
| Communication user / arrangement | (S/4 side) |
| BTP destination & trust | (side-by-side, if any) |
| Authorization | scopes / roles required on each side |
| Transport security | TLS 1.2+ |

## 6. Error Handling & Resilience

| Concern | Handling |
|---|---|
| Validation failure | response code, error payload shape, who is notified |
| Target unavailable | retry policy (count, backoff), dead-letter / replay |
| Duplicate delivery | idempotency key, dedup strategy |
| Ordering | guaranteed? partition key? |
| Partial batch failure | all-or-nothing vs per-record status |
| Reprocessing | manual replay tool / monitoring app |

## 7. Monitoring & Support

- Where success/failure is visible (Integration Suite monitoring, SAP Application
  Logging, custom log).
- Alerting: threshold, channel, on-call owner.
- SLA / OLA for this interface.

## 8. Test Scenarios

| # | Scenario | Precondition | Input | Expected result |
|---|---|---|---|---|
| 1 | Happy path | | | |
| 2 | Validation error | | | |
| 3 | Target down → retry → recover | | | |
| 4 | Duplicate message | | | |

## 9. Open Questions

| # | Question | Owner | Status |
|---|---|---|---|
