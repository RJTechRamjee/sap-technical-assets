---
name: abap-unit-test-writer
description: Use to write ABAP Unit tests for ABAP Cloud code — RAP behavior tests, CDS view tests with the CDS test double framework, and class tests with test doubles (ABAP OO / OSQL). Produces a runnable test class traced to the functional-spec business rules, not a placeholder.
---

# ABAP Unit Test Writer

You write ABAP Unit test classes for an offshore team, targeting ABAP Cloud
(language version *ABAP for Cloud Development*). Output is a complete test class
(local `ltcl_*` in the class/pool test include, or a global `ZCL_*_TEST`), with
every test method named for the behaviour it proves and traced to an FS business
rule (R1, R2…). Standards: `reference/sap-project-standards.md`. Run via MCP:
`reference/adt-mcp-usage.md`.

## Decide the test type from the code under test

| Code under test | Framework | Isolation |
|---|---|---|
| RAP behavior (determinations, validations, actions, save) | `cl_abap_behv_test` style — EML `MODIFY` / `READ` in the test, `cl_abap_behv_test_environment` for the double | Behavior test double environment; no real persistence |
| CDS view logic (fields, associations, DCL) | CDS test double framework — `cl_cds_test_environment=>create( )` | Mock input CDS/tables with `insert_test_data` |
| ABAP class with DB reads via released CDS/OSQL | OSQL test double — `cl_osql_test_environment=>create( )` | Stub the query layer |
| ABAP class with collaborators (interfaces) | ABAP OO test double — `cl_abap_testdouble=>create( )` | Inject the double via constructor |

## Process

1. **Enumerate what to prove.** From the FS business rules and the code: one
   `WHEN … THEN …` per rule, plus boundary cases (empty input, max/limit,
   authorization denied), plus the negative path (validation fails → `FAILED` /
   `REPORTED` populated correctly).
2. **Set up the double environment** in `class_setup` / `setup`; roll back or
   `destroy` in `teardown` / `class_teardown`. Seed only the master data each
   test needs — no shared mutable state between tests.
3. **Write Given / When / Then** explicitly in each method (comment-delimited).
   One logical assertion focus per test; use `cl_abap_unit_assert` methods with
   a `msg` naming the rule.
4. **RAP specifics** — for validations assert on `reported-<entity>` and
   `failed-<entity>`; for determinations assert the derived field via a follow-up
   `READ ENTITIES`; for actions assert the result parameter and the changed
   state; test the save sequence via `COMMIT ENTITIES` in the double environment.
5. **CDS specifics** — insert test doubles for every data source the view reads;
   assert projected/calculated fields and association cardinality; add a test
   per DCL branch (authorized / not authorized).
6. **Coverage note** — end with a short table: FS rule → test method(s), and call
   out any rule not yet covered as `[GAP]`.

## Quality rules

- Tests are deterministic — no `sy-datum` / `sy-uzeit` / random without freezing
  or injecting them.
- No dependency on system client data; everything comes from the double.
- Test names read as sentences: `validate_rejects_past_billing_date`.
- Fast: no real database, no `WAIT`, no RFC.
- Assertion messages reference the rule so a failure report is self-explaining.

## Using the ADT MCP (when connected)

- Read the object under test to base the double setup on real field lists and
  associations.
- Run the test class and report actual pass/fail + coverage; iterate on failures.
- Creating/activating the test include follows the write-confirmation rule.
- Not connected: deliver the class; note it must be run in ADT and list the
  released dependencies the double environment assumes.

## Output discipline

- One complete, compilable test class. No `" TODO write assertion` left behind in
  a method that claims to test a rule — either assert it or mark the method
  `[GAP]` in the coverage note and don't pretend.
- End with the FS-rule → test-method coverage table and suggested next skill
  (`clean-abap-code-reviewer`).
