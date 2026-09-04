# Functional Specification

> Copy this file, fill every section. Keep language testable — a functional consultant and an offshore ABAP developer should both be able to build/test from this without asking you a clarifying question.

## 1. Header

| Field | Value |
|---|---|
| FS ID | |
| Title | |
| Process area | (Lead-to-Cash / SD / Invoicing / other) |
| Requestor | |
| Author | |
| Status | Draft / In Review / Approved / Build / Done |
| Related requirement / backlog ID | |
| Related workshop notes | (link) |
| SAP release | S/4HANA Cloud Public/Private, version |

## 2. Business Background & Objective

What business problem is this solving, in the requestor's own words. Why now. What breaks or is missing today.

## 3. Scope

**In scope:**
-

**Out of scope:**
-

## 4. As-Is Process

Brief narrative or reference to a process diagram. Highlight the specific step this FS changes.

## 5. To-Be Process / Requirement Detail

Step-by-step description of the new/changed behavior. Include:
- Trigger (what starts this process)
- Actors (roles/users involved)
- Data objects touched (sales order, billing doc, condition records, partner, etc.)
- Business rules, in numbered, testable form (R1, R2, R3…)
- Exceptions / error handling expected

## 6. Clean Core & Extensibility Assessment

*Required section — do not skip. See `clean-core-extensibility-advisor` skill for how to fill this in.*

| Question | Answer |
|---|---|
| Can this be met by standard SAP config only? | |
| If not, is a released BTP extensibility scenario available (in-app or side-by-side)? | |
| Extensibility type selected | In-app (key user / developer) / Side-by-side (BTP) / Classic (needs exception approval) |
| Released APIs/CDS/BAdIs used | |
| Any SAP-modified/non-released object touched? | If yes → escalate, this is a Clean Core violation |
| Upgrade-stability risk | Low / Medium / High + why |

## 7. Functional Design

- UI changes (Fiori app, field, screen variant)
- Field list (technical name, table/CDS, data element, length, required Y/N, source)
- Configuration required (IMG path, entries)
- Authorization objects affected

## 8. Technical Design (ABAP Cloud)

- RAP Business Object / BDEF changes, or new BO
- CDS views (interface / consumption) touched or created
- Class/method design, released API dependencies
- Integration touchpoints (API Management / iFlow, if any) — see `clean-core-extensibility-advisor`
- Data migration / conversion impact (if any)

## 9. Test Scenarios

| # | Scenario | Precondition | Steps | Expected Result |
|---|---|---|---|---|
| 1 | | | | |

## 10. Open Questions

| # | Question | Owner | Status |
|---|---|---|---|

## 11. Sign-off

| Role | Name | Date |
|---|---|---|
| Functional consultant | | |
| Architect | | |
| Requestor | | |
