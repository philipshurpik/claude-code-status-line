# Working Style
- When I ask a question, ANSWER it — do not edit any file, plan, code, or settings unless I explicitly tell you to change something.

# Writing Style
- All prose (docs, READMEs, commits, PRs, explanations): ASD-STE100 Simplified Technical English — active voice, present tense, one instruction per sentence, short sentences, one word = one meaning, no noun stacks, keep articles.
- Follow Zinsser's four principles: simplicity, brevity, clarity, humanity.

# Git
- NEVER `git commit` or `git push` unless I explicitly ask in the current conversation. Make the edits, run validation, show `git status`/diff, then stop and let me commit.
- Refactoring a file into a renamed successor: always `git mv old new` then edit — never delete + create. Preserves rename detection and `git log --follow` history.

# Verifying Names and APIs
- When the user mentions a specific model, library, API endpoint, package, or function and I am not certain about the exact current name/identifier, WebFetch authoritative docs (or WebSearch) FIRST before writing a response.
- Never preemptively "correct" the user from training-cutoff knowledge — my knowledge of model names, SDK versions, and API surfaces is often stale. Trust the user's naming until docs say otherwise, and verify the user's naming when in doubt rather than substituting a name I remember.
- If the user provides a docs URL, fetch it before responding — don't paraphrase from memory.

# Python Code Style
- Python 3.12+ - use `list[str]`, `dict[str, int]`, `str | None`. Never import from `typing` for these.
- Single quotes everywhere except docstrings (double).
- Line limit: 120 chars.
- Short, readable code - one-liners when they help. Minimal comments; no obvious narration.
- Comments max 1-2 lines — state the non-obvious "why", not narration; if it needs more, the code/docstring should carry it.
- Docstrings: one-line intent only (modules/classes ≤3 lines). Don't re-derive architecture that lives in docs/code — state the non-obvious why, link the rest. Skip on trivial functions.
- Touch a file → leave its docs cleaner: trim stale/verbose docstrings + comments as you go, never grow them. Removing a feature/param means deleting its docs, not adding any that explain the now-default behavior.
- Two near-identical code paths → one parameterized helper; pass the differing bits (accessors/funcs) in. Never copy a loop to vary one call.
- Logger calls: prefer f-strings on a single line; use `logger.info(f'x={x} y={y}')` format.
- Pydantic v2.9+: `ConfigDict()` not `class Config`, `field_validator` not `validator`.
- Deps: `uv sync` with `pyproject.toml` + `uv.lock` for pinning.
- Linting: ruff. Run `make lint` (or the project's lint command) after changes.

# Python Project Setup
- New project: `uv init`, add `[dependency-groups] dev` for pytest/ruff.
- Ruff config goes in `pyproject.toml` (not separate ruff.toml).
- Makefile with `install`, `lint`, `test` targets. `make lint`: `ruff format . && ruff check . --fix`.

# Testing
- Test business logic, not config wiring or framework validation.
- Shared helpers, parametrized tests over repetitive setup.
- Merge related small tests into one when it reads clearly.
- Module-level constants for reusable data; fixtures for per-test isolation.
- Don't run tests via `make test` / `make test-unit`. Open the Makefile, find the underlying command, and run it directly (e.g. `uv run python -m pytest tests/*.py`)
