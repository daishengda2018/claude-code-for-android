## Description

Briefly describe the changes made in this pull request.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Performance improvement
- [ ] Test addition/improvement

## Related Issue

Fixes # (issue number)
Related to # (issue number)

## Changes Made

List the specific changes made:

-
-
-

## Test Cases

### Test Case Added

- **File**: `test-cases/XXX-name.kt`
- **Rule**: XXX-XXX
- **Severity**: CRITICAL/HIGH/MEDIUM/LOW
- **Description**: What this test case detects

### Verification

```bash
# Test command used
/android-code-review --target file:test-cases/XXX-name.kt

# Result: PASS/FAIL
```

## Testing

### Tier 1: Standalone Files
- [ ] Tested on standalone test file
- [ ] Detection works as expected
- [ ] Severity is correct
- [ ] Fix suggestions are helpful

### Tier 2: Real Android Project
- [ ] Tested in `test-android/` project
- [ ] Build verification passes: `./scripts/verify-build.sh`
- [ ] No false positives on correct code

### Tier 3: Regression Testing
- [ ] All existing test cases still pass
- [ ] No new false positives introduced

## Screenshots (if applicable)

Add screenshots to demonstrate the changes.

## Checklist

- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my code
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation accordingly
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally
- [ ] Any dependent changes have been merged and published

## Additional Notes

Add any additional notes or context about the pull request here.

## Breaking Changes

If this PR introduces any breaking changes, please describe them here and provide migration notes for users.

---

**By submitting this PR, you agree that your contributions will be licensed under the [Apache-2.0 License](LICENSE).**
