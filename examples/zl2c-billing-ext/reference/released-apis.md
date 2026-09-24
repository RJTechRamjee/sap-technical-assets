# Checking whether an SAP object is released

This file is **ours**, not Copilot's. The instruction files link to it instead of
duplicating its content, so there is one copy of the rule and it changes in one
place.

It deliberately does **not** contain a list of released CDS views, BAdIs or APIs.
Such a list goes stale silently and is then wrong in a way nobody notices until
a transport fails. The system is the source of truth. This page tells you how to
ask it.

## The rule

In ABAP for Cloud Development you may only use SAP objects that are **released
for cloud development**. Anything else will not compile, or will compile today
and break on an upgrade. There is no "just this once" exception that survives
contact with an upgrade.

## How to check, in ADT

1. Open the object in ADT (Eclipse).
2. Open the **Properties** view, **API State** tab.
3. Read the release contract:
   - **Released for cloud development** — usable. Note the contract type
     (remote API, extension point, etc.) because it constrains *how* you use it.
   - **Use System-Internally (Restricted)** or no release state — not usable.
     Find the released alternative or the extension point instead.
4. If the object is deprecated, the tab names the **successor**. Use it.

You can also browse released objects directly in ADT rather than guessing a name
and then checking it.

## What to do when you don't know

Write `[CONFIRM in ADT]` and move on. Do **not** write a plausible-looking
technical name.

This matters more with AI assistance than it did without it. An assistant will
produce a table, field or BAdI name that is correctly shaped, correctly prefixed
and completely fictional, and it will do so with no hedging whatsoever. Treat
every SAP technical name in generated output as unverified until you have seen
it in ADT.

## The two guardrails

1. **Released-API check still applies.** AI authorship does not change the
   compliance bar.
2. **Generated code is reviewed like hand-written code.** Same reviewer, same
   checklist, same standard.
