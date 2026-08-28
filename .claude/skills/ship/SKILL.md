---
name: ship
description: Push a change through the paved road (branch → gates → dev → human-approved prod) without leaving the console.
---

# ship

Drives a local change through the real pipeline (`plan.yml` → `deploy.yml` → `agents.yml`),
narrating each stage instead of making the developer open GitHub.

## Steps

1. Check for a diff to ship (`git status`). If on `main`, branch first: `git switch -c <name>`.
2. Commit and push: `git add <files> && git commit -m "..." && git push -u origin HEAD`.
3. Open the PR: `gh pr create --fill`. Report the PR URL.
4. Poll gates: `gh pr checks --watch --interval 15`. Report each gate pass/fail as it
   lands — not a raw log dump.
5. **On failure**: `gh pr view --comments` and surface the ReviewBot/Triage comment
   (labelled AI-generated) instead of raw CI logs. Propose a fix, apply it only with
   the developer's go-ahead, push, and re-poll. Never retry blindly.
6. **On green**: ask the developer to confirm before merging. Only after their explicit
   yes, `gh pr merge --squash`. Never merge unprompted.
7. After merge, `gh run watch` the deploy run. Report the dev smoke-test result and URL.
8. Prod waits on the `prod` GitHub Environment reviewer. **Present this gate, never
   approve it**: report that the run is parked on prod approval, give the run URL, and
   wait. Only a human clicking Approve in GitHub advances it — this skill has no path
   to approve prod itself, by design (PRD §8.2).
9. Once prod deploys, report the prod URL and smoke-test result.

## Boundaries (never do these)

- Never merge without an explicit human yes for that specific PR.
- Never approve, or ask another agent to approve, the `prod` Environment gate.
- Never bypass a failing gate (no admin-merge override, no disabling a required check).
- No preview step — previews are cut (`paved-road`'s DECISIONS.md §2). The flow is
  branch → gates → dev → human approval → prod.

Spec: PRD §11 (console DX), G1 (ship without leaving the console).
