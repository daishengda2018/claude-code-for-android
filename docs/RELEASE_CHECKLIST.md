
# Claude Plugin Release Checklist

> Execution Rule: If any section marked `BLOCKER` fails, terminate the process immediately; all steps must be executed in sequence.

---

#### 1. Structure Validation (BLOCKER)

* [ ] `.claude-plugin/` directory exists in the project root
* [ ] Single plugin: `plugin.json` (core release manifest) must exist under `.claude-plugin/`
* [ ] Multi-plugin bundle: `marketplace.json` may be supplemented, and its version number must exactly match that of `plugin.json`
* [ ] Only compliant runtime directories exist: `agents/` / `commands/` / `skills/` (no extraneous publish directories)
* [ ] Every subfolder under `skills/` contains an **uppercase `SKILL.md`**

> Validation Command: The result of `find skills -type f -name "SKILL.md" | wc -l` must equal the number of subfolders under `skills/`

---

#### 2. Runtime Compatibility Validation (BLOCKER)

* [ ] No absolute repository paths in skills/agents/commands; all references are relative paths

> Validation Command: `grep -r "$(pwd)" agents/ commands/ skills/` must return no output

* [ ] No runtime logic or publish-dependent content is stored in the `.claude/` directory (this directory is for local development only and will NOT be published)
* [ ] Local installation test passed:
  1. Execute `/plugin install .` with no errors
  2. Execute `/plugin list` and verify the current plugin is registered successfully

---

#### 3. Version Integrity (Required)

* [ ] Version numbers in all release manifests under `.claude-plugin/` are updated and fully consistent
* [ ] `CHANGELOG.md` is updated with the change content for the corresponding version
* [ ] `README.md` is synced with the features and usage instructions for the current version

---

#### 4. Git Sync Validation (BLOCKER)

* [ ] Working tree is clean: `git status` shows no uncommitted or untracked files
* [ ] All changes are committed to the local `main` branch
* [ ] All changes are pushed to the remote `origin/main`
* [ ] Local and remote HEAD are fully matched: `[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]`

---

#### 5. Tagging (Required)

* [ ] Pre-check: Execute only after all above sections are passed
* [ ] Check for no duplicate version Tag on remote: `git ls-remote --tags origin | grep vX.Y.Z` must return no output
* [ ] Create annotated Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
* [ ] Push Tag to remote: `git push origin vX.Y.Z`
* [ ] Verify remote Tag exists: `git ls-remote --tags origin | grep vX.Y.Z` returns corresponding output

---

#### 6. GitHub Release (Required)

* [ ] Create Release based on the pushed Tag
* [ ] Release title and version exactly match the Tag
* [ ] Release Notes are validated and match the content of `CHANGELOG.md`
* [ ] Release page is accessible normally, and the source code archive is downloadable without issues

---

#### 7. Post-Release Validation (BLOCKER)

* [ ] Verify Tag points to the latest `main` branch HEAD: `git log vX.Y.Z --oneline -1` matches the latest commit
* [ ] Remote installation validation: Execute `/plugin install <repo-release-url>` via the GitHub Release URL with no errors
* [ ] Function validation: The plugin's commands/agents/skills can be loaded and triggered normally with no errors
