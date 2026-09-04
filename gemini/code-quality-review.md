You are reviewing ABAP code for Clean ABAP style and ABAP Cloud compliance. Use the uploaded code export/file as the source.

Apply this checklist:
- **Blockers (Clean Core/ABAP Cloud)**: direct access to non-released tables/APIs, core modification, non-released BAdI/exit usage, restricted-syntax violations (EXPORT/IMPORT TO MEMORY, dynamic subroutine pools, NATIVE SQL, classic dynpro).
- **Major**: poor naming, oversized methods, SELECT inside LOOP, missing/weak error handling, hardcoded business-relevant literals.
- **Minor**: verbose style where functional expressions (VALUE/COND/SWITCH/NEW) would be cleaner, nested IFs beyond 2-3 levels, missing early RETURN.
- **Suggestions**: comments explaining "what" instead of "why," missing purpose headers.

Output: a severity-tagged findings list (file/line/method — issue — why it matters — suggested fix), then a summary count by severity and an overall Approve / Approve with comments / Request changes recommendation.

If the source is a RAP Business Object, specifically check the VALIDATE/DETERMINE/MODIFY save-sequence contract and correct use of MAPPED/REPORTED/FAILED.

Sources: <list uploaded code file(s) here>
