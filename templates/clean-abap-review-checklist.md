# Clean ABAP Code Review Checklist

Use alongside the `clean-abap-code-reviewer` skill. Severity: 🔴 Blocker · 🟠 Major · 🟡 Minor · 🔵 Suggestion.

## ABAP Cloud / Clean Core Compliance
- [ ] 🔴 Uses only released APIs (check API State / Release status in ADT)
- [ ] 🔴 No direct SELECT/INSERT/UPDATE/DELETE on standard SAP tables — only released CDS/BOs
- [ ] 🔴 No calls to non-released function modules / classes
- [ ] 🔴 No modification of SAP standard objects (no core mods, no implicit enhancements on standard)
- [ ] 🟠 New objects follow customer/partner namespace convention
- [ ] 🟠 RAP used where transactional logic is new (not classic BAPI wrapper unless justified)

## Clean ABAP Language Rules (subset most missed)
- [ ] 🟠 Meaningful names (no `lv_x`, `ls_data`, single-letter loop vars beyond trivial scope)
- [ ] 🟠 Methods do one thing; length is a smell past ~20-30 lines
- [ ] 🟠 No dead code / commented-out code left in
- [ ] 🟡 Boolean methods read as questions (`is_`, `has_`, `can_`)
- [ ] 🟡 Use `LOOP AT ... ASSIGNING/REFERENCE INTO` and avoid unnecessary deep copies
- [ ] 🟡 Prefer functional/constructor expressions (`VALUE`, `COND`, `SWITCH`, `NEW`) over verbose classic style
- [ ] 🟡 Avoid nested IFs beyond 2-3 levels — extract methods / use early RETURN
- [ ] 🔵 Comments explain *why*, not *what* the code already says
- [ ] 🟠 No hardcoded literals for business-relevant values (use constants / customizing)
- [ ] 🟠 Exceptions used for genuinely exceptional cases, not control flow

## Error Handling & Robustness
- [ ] 🟠 RAISE EXCEPTION with proper class hierarchy, not generic `sy-subrc` swallow
- [ ] 🟠 RAP: proper use of `REPORTED`, `FAILED`, `MAPPED` in save sequence / validations
- [ ] 🟡 Authorization checks present where the object is user-facing

## Performance
- [ ] 🟠 No SELECT inside LOOP (use FOR ALL ENTRIES / JOIN / CDS association instead)
- [ ] 🟡 Appropriate table type (HASHED/SORTED) for lookup-heavy logic
- [ ] 🟡 Package size considered for mass data (RAP / AMDP where needed)

## Testability
- [ ] 🟠 Business logic isolated from database access (testable without DB where feasible)
- [ ] 🟡 ABAP Unit tests exist for new/changed logic
- [ ] 🔵 Test doubles / CDS test double framework used for RAP behavior tests

## Documentation
- [ ] 🔵 Class/interface has a purpose header
- [ ] 🔵 Non-obvious business rule references back to FS section/requirement ID
