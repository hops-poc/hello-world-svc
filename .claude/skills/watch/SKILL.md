---
name: watch
description: Tail a running pipeline and surface agent narration (ReviewBot/Triage) in the console.
---

# watch

Tails an in-flight `plan.yml`/`deploy.yml` run and narrates it, so the developer never
needs to open GitHub. ReviewBot and Triage are live: `paved-road`'s `agents.yml` runs them
on Bedrock and posts AI-generated comments on gate failure, writing each action to the
`hello-world-svc-agent-ledger` DynamoDB table. This skill surfaces that in the console.

## Steps

1. Find the run: `gh run list --limit 5` (or use a run/PR the developer named).
2. Tail status: `gh run watch <run-id>` — report one line per job (name: queued/running/
   pass/fail), not the raw log stream.
3. Pull narration as it posts: `gh pr view <pr> --comments` — surface ReviewBot/Triage
   comments, labelled AI-generated, as soon as they appear.
4. On a gate failure, show the Triage comment's diagnosis inline; don't dump the failing
   job's raw log unless the developer asks for it.
5. When the run parks on the `prod` Environment gate, say so explicitly and give the
   approval URL — this skill only ever *reports* that state, never advances it.

Not available to surface, because they are documented design-only and not built:
Release/Incident agent narration, and preview URLs (previews are cut —
`paved-road`'s DECISIONS.md §2).

Spec: PRD §11 (console DX).
