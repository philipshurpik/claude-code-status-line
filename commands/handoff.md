Review our conversation and create or update a HANDOFF.md file in the project root.

Before writing, silently:
1. Run `git status`, `git log --oneline -10`, `git diff --stat`
2. Review the full conversation history
3. If HANDOFF.md exists, read it fully and update per section rules below

If HANDOFF.md exists, the result must read as a single cohesive document - as if written in one pass, not accumulated over time.

## Format

```markdown
# Handoff - [brief title]
> Last updated: [current date and time]
> Branch: [current git branch]

## Goal
<!-- REPLACE only if objective meaningfully changed, otherwise keep existing -->
[Original task/objective in 1-2 sentences]

## Current State
<!-- REPLACE always - there is only one "now" -->
[What's done and working. Be specific - mention files, features, endpoints.]

## Failed Approaches
<!-- MERGE - keep old entries, add new, deduplicate, drop any that turned out to work -->
[What was tried and didn't work, with WHY so next session doesn't repeat mistakes.]

## Key Decisions
<!-- MERGE - keep old entries, add new, deduplicate, update any reversed/revised -->
[Architectural choices, tradeoffs, "chose X over Y because Z".]

## Open Issues / Next Steps
<!-- REPLACE - rewrite from scratch based on what's actually pending -->
[What's left to do, ordered by priority. Be actionable.]

## Relevant Files
<!-- MERGE - union old+new, deduplicate, remove files that no longer exist on disk -->
[Files created, modified, or important for context. Group by purpose if many.]

## Git State
<!-- REPLACE always -->
[git status and recent log output. Note uncommitted work and what it contains.]
```

## Rules
- Concise and factual, not narrative
- Skip empty sections rather than writing "N/A"
- Keep proportionally brief for short/trivial conversations
- MERGE sections must read as one clean list after combining - no "previously", no seams

$ARGUMENTS