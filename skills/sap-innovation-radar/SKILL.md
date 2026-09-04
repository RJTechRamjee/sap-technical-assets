---
name: sap-innovation-radar
description: Use to research and summarize the latest S/4HANA Cloud, BTP, RAP/ABAP Cloud, and SAP AI (Joule, AI Launchpad/Hub) innovations relevant to Lead-to-Cash, SD, or Invoicing — for architecture decisions, roadmap conversations, or as raw material for a COE knowledge-sharing session.
---

# SAP Innovation Radar

You research current SAP product direction and turn it into something an architect can act on or teach from. This skill assumes web search/fetch is available (Claude Desktop/Code) — if not, produce the best structured brief from existing knowledge and clearly flag it as **not verified against current SAP release notes**.

## Process

1. **Scope the search.** Default areas to check unless told otherwise:
   - S/4HANA Cloud Public Edition release notes (quarterly release, current + last one)
   - ABAP Cloud / RAP roadmap items (SAP Roadmap Explorer, ABAP Cloud topic on SAP Community)
   - BTP extensibility updates (Custom Fields and Logic, Custom CDS Views, Event Mesh, Integration Suite)
   - SAP AI: Joule (in S/4HANA and for developers), AI Launchpad, AI Hub, Generative AI Hub, embedded AI in SD/Billing (e.g., anomaly detection, AI-assisted pricing)
   - Lead-to-Cash / SD / Invoicing specific: any new Fiori apps, billing innovations (e.g., Convergent/High-Volume Billing, RAP-based billing extensibility), credit management AI features

2. **Search with specific, dated queries** — "SAP S/4HANA Cloud 2025 release notes SD," "ABAP Cloud RAP roadmap 2025/2026," "SAP Joule ABAP developer," etc. Prefer official sources: help.sap.com, SAP Roadmap Explorer, SAP Community, SAP Business Accelerator Hub. Always check today's date before claiming something is "latest."

3. **Produce a briefing** with this structure:
   - **Headline items** (3-6 bullets) — what's genuinely new and relevant, one line each, with source link.
   - **Relevance to our work** — for each headline item, one line on why it matters for L2C/SD/Invoicing architecture or Clean Core practice.
   - **Action for the architect** — concrete next step (e.g., "evaluate for the next extensibility ADR," "candidate for next COE session," "no action, informational").
   - **Sources** — every claim must trace to a link found via search this session. Never state a release date, feature name, or capability from memory alone without verifying it's still current.

4. **Flag uncertainty explicitly.** SAP renames and reshuffles products often (e.g., "AI Launchpad" vs "AI Hub" positioning has shifted). If search results conflict or are unclear, say so rather than picking one confidently.

## When feeding into the COE pipeline

If the output of this skill will become a knowledge-sharing session, hand off directly to `coe-session-planner` — pass it the "Headline items" and "Relevance" sections as the topic seed rather than re-researching from scratch.

## Guardrails

- Don't editorialize about SAP's strategy beyond what sources say.
- Don't recommend adopting a feature still in "customer validation"/beta for production without flagging that status clearly.
- Keep the briefing short enough to read in under 5 minutes — this is a radar, not a white paper.
