// Test Case 012: Skill Triggering Test
// Purpose: Verify android-code-review skill is invoked correctly
// Expected Behavior: When user mentions "review android" or reviews Android project, skill should load

// Scenario 1: Direct trigger phrase
// User input: "review this android code"
// Expected: android-code-review skill loads

// Scenario 2: Project detection
// User input: "review my code" (in project with build.gradle or AndroidManifest.xml)
// Expected: android-code-review skill loads

// Scenario 3: Severity filtering
// User input: "/android-code-review --severity critical"
// Expected: Only security patterns load (~1,500 tokens)

// Verification Checklist:
// [ ] Skill loads when "review android" mentioned
// [ ] Skill loads when reviewing files in Android project
// [ ] Skill respects --severity parameter
// [ ] Output is formatted for console display
// [ ] Results are structured with severity levels
