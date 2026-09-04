---
mode: 'ask'
description: 'Write an ABAP Unit test class for the selected ABAP Cloud code (RAP behavior, CDS view, or class with doubles), traced to the functional-spec business rules.'
---
Write a complete, runnable ABAP Unit test class for the selected code, following sap-technical-assets/skills/abap-unit-test-writer/SKILL.md and sap-technical-assets/reference/sap-project-standards.md.

Pick the framework from the code under test:
- RAP behavior → `cl_abap_behv_test_environment`; EML `MODIFY`/`READ` in tests; assert on `reported`/`failed` for validations, on a follow-up `READ` for determinations, on the result + state for actions.
- CDS view → `cl_cds_test_environment=>create( )`; insert test doubles for every data source; test each DCL branch.
- Class with released-CDS/OSQL reads → `cl_osql_test_environment=>create( )`.
- Class with interface collaborators → `cl_abap_testdouble=>create( )`, injected via constructor.

Rules:
- One test method per business rule (R1, R2…) plus boundary and negative paths; method names read as sentences.
- Given/When/Then delimited in each method; `cl_abap_unit_assert` with a `msg` naming the rule.
- Set up the double in `setup`/`class_setup`, tear down cleanly; no shared mutable state; deterministic (freeze or inject date/time/random).
- No real DB, no WAIT, no RFC.
- End with an FS-rule → test-method coverage table; mark any uncovered rule `[GAP]` — do not leave an empty assertion in a method that claims to test a rule.

Code under test:
${selection}
