---
mode: 'ask'
description: 'Check whether ABAP code/design is ABAP Cloud-compliant (released APIs only, portable language subset) ahead of an S/4HANA Cloud migration or new build.'
---
Assess ABAP Cloud readiness for the code/design below.

Check for:
- Restricted language scope violations: EXPORT/IMPORT TO MEMORY, dynamic subroutine pools, classic dynpro (CALL SCREEN), NATIVE SQL/EXEC SQL, CALL TRANSACTION/DIALOG.
- Non-released table/CDS/function-module/class/BAdI usage (anything without a confirmed "Released" API state).
- Object type/pattern: favor RAP Business Objects and released CDS over classic BAPI/report patterns.
- Namespace/packaging fit for ABAP Cloud development scope.

Output a verdict table (Object | Verdict ✅/⚠️/❌ | Blocking issues | Effort S/M/L), then Quick Wins vs Redesign Candidates, then a suggested migration sequence.

Don't call something "Ready" just because it compiles/runs today on a classic system — Ready means release-compliant.

Code / design:
${selection}
