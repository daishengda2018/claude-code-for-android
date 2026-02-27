# Android Test Project for Plugin Development

This is a test Android project used for developing and testing the `android-code-reviewer` plugin.

## Purpose

- Test plugin detection capabilities
- Validate code review rules
- Iterate on plugin improvements
- Ensure no false positives/negatives

## Structure

```
test-project/
├── app/src/main/java/com/test/
│   ├── security/         # Security vulnerability test cases
│   ├── memory/           # Memory leak test cases
│   ├── performance/      # Performance issue test cases
│   └── architecture/     # Architecture violation test cases
└── app/src/test/java/    # Verification tests
```

## Usage

1. Write intentional buggy code in test cases
2. Run `/android-code-review --target file:path/to/file`
3. Verify all issues are detected
4. If not, improve plugin in `.claude/agents/`
5. Repeat until satisfied
