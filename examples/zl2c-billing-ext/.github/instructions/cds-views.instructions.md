---
name: 'CDS View Standards'
description: 'Conventions for CDS view entities and projection views in this repo'
applyTo: '**/*.asddls'
---

# CDS view entity standards

- Use `DEFINE VIEW ENTITY`. Never `DEFINE VIEW` with a DDIC-based SQL view —
  that form is not available in ABAP for Cloud Development.
- No `client` field in the field list. Client handling is implicit.
- Every exposed element carries `@EndUserText.label`.
- Name elements in CamelCase (`BillingDocument`), not underscored DDIC style.
- Prefix by layer: `ZI_*` interface view, `ZR_*` restricted/base, `ZC_*`
  consumption/projection.

## Annotations

- `@AccessControl.authorizationCheck: #CHECK` unless there is a stated reason
  for `#NOT_REQUIRED` — and if it's `#NOT_REQUIRED`, say why in a comment.
- `@Metadata.allowExtensions: true` only where an extension is actually planned.
- UI annotations belong on the consumption view, not the interface view.

## Sources

- Select only from released interface views or from this project's own `Z*`
  tables. If you need an SAP view name you are not certain is released, write
  `[CONFIRM in ADT]` rather than guessing a plausible-looking name.
- Check release state the way [`released-apis.md`](../../reference/released-apis.md)
  describes.
