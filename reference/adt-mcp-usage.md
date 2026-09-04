# ADT MCP Usage Contract

The `adt-mcp` server (abap-adt-api based, read + write) gives skills a live bridge
to the ABAP system. Any skill that reasons about ABAP objects should use it when
it is connected, and degrade gracefully when it is not.

> **Note on SAP's own ABAP MCP Server.** SAP's MCP Server reached GA at Sapphire
> 2026 — built on the ABAP Language Server, exposing object management, transport
> handling, syntax checks and documentation as MCP tools in Eclipse and VS Code.
> **We do not have the entitlement for it** (it sits behind the same Joule for
> Developers licensing, consumption-priced in AI Units), so the community
> abap-adt-api based `adt-mcp` server remains our path. Verified 2026-09-04;
> revisit only if entitlement is purchased. The rules below apply either way.

---

## Capability categories

Tool names vary by server build — match by capability, not exact name.

**Read (use freely, no confirmation needed):**
- Read object source (classes, CDS, BDEF, service def/binding, programs, function modules)
- DDIC / metadata lookup (table structure, data elements, domains, CDS fields & annotations)
- Object search / resolve by name or pattern
- Where-used list
- Release contract / API state of an object
- Syntax check
- ATC run (read results) for an object or package
- ABAP Unit run (read results)
- Transport / task listing (read)

**Write (NEVER without the user's explicit go-ahead in the same turn):**
- Create / change / delete objects
- Activate objects
- Create or release transports / tasks
- Assign objects to transports
- Run mass operations

---

## Rules

1. **Read is free.** Grounding a review or design in real system state is always
   preferable to guessing. Prefer an ADT read over asking the user to paste code.
2. **Write is gated.** Before any create/change/activate/transport action:
   - Show exactly what will be created or changed (object names, types, target
     package, target transport).
   - State it plainly: "This will create/activate the following in the system.
     Confirm?" and wait.
   - One confirmation covers one described batch, not "all future writes".
3. **Read-only by default for review skills.** `clean-abap-code-reviewer`,
   `abap-cloud-readiness-checker`, and `architecture-reviewer` never write.
4. **Released-API checks** (per `sap-project-standards.md` §7) should use the
   release-contract read tool first when the MCP is up.
5. **ATC / ABAP Unit**: prefer running them via the MCP and reporting real
   findings over reasoning about what they *would* say.

---

## Fallback when the MCP is not connected

Say so once, plainly, then continue offline:

> ADT MCP is not connected this session — working from the code/docs provided.
> Released-API status is stated as *[CONFIRM in ADT]* where I can't verify it live.

- Do not stall or repeatedly retry.
- Mark every released-API claim `[CONFIRM in ADT]`.
- For generation skills, still produce the full object set; add a closing note
  listing which released APIs the user must verify before activation.
