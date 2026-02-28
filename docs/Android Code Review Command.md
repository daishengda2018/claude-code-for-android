# Android Code Review Command

1. Detect scope:

- auto → git diff --name-only HEAD
- commit:<id> → git show --name-only --pretty=format:"" <id>
- pr:<number> → gh pr diff <number> --name-only
- file:<path> → review specific file

2. Load:
- Android Code Review Agent
- Android Review Rulebook v3

3. For each file:
- Read full file (not diff only)
- Apply rulebook
- Apply PR-context rules if reviewing commit/PR

4. Generate structured report.

5. BLOCK if CRITICAL found.
6. WARNING if HIGH only.
7. APPROVE otherwise.

Never approve code with security vulnerabilities.