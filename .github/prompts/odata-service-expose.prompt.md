---
mode: 'ask'
description: 'Generate the service definition + OData V4 binding to expose an existing CDS/RAP entity, with the publish steps (UI vs inbound API).'
---
Generate the OData exposure for the CDS/RAP entity in the selection, following sap-technical-assets/reference/sap-project-standards.md (naming §5) and sap-technical-assets/skills/abap-object-generator/SKILL.md (Mode 3).

Produce:
1. Service definition — `ZUI_<Entity>` for a Fiori UI service, `ZAPI_<Entity>` for an inbound integration API; `expose` the root plus the child/associated entities that the consumer needs (name them, don't over-expose).
2. Service binding — `ZUI_<Entity>_O4` / `ZAPI_<Entity>_O4`, OData V4, binding type UI or Web API accordingly.
3. Publish steps:
   - UI service: activate binding, add to a Fiori launchpad content / IAM app + business catalog.
   - Inbound API: create/extend a Communication Scenario, assign the service, note the Communication Arrangement + communication user + OAuth2 client credentials.
4. A note on which released authorizations/DCL apply and any rate/size limits to set in API Management if it fronts the service.

Rules:
- S/4HANA Cloud Private Edition, S/4HANA 2025; released APIs only.
- Don't invent catalog/scenario technical names — mark `[CONFIRM in ADT]`.

Entity:
${selection}
