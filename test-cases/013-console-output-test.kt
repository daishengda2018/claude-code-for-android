// Test Case 013: Console Output Format Test
// Purpose: Verify review results are properly formatted for console display
// Expected: Structured output with severity levels, file locations, and review summary

// Input: Any Android code file with issues

// Expected Output Format:
// ## Android Code Review Results
//
// ### 🔴 CRITICAL (N issues)
// **File:** path/to/file.kt:12
// **Issue:** Hardcoded API key detected
// **Pattern:** Security/HardcodedSecrets
// **Fix:** Use BuildConfig or EncryptedSharedPreferences
//
// ### 🟠 HIGH (N issues)
// [Findings...]
//
// ### 🟡 MEDIUM (N issues)
// [Findings...]
//
// ## Review Summary
// | Severity | Count | Status |
// |----------|-------|--------|
// | CRITICAL | 2     | ❌ fail |
// | HIGH     | 5     | ⚠️  warn |
// | MEDIUM   | 3     | ✅ pass |
//
// **Verdict:** BLOCKED (2 critical issues must be fixed)

// Verification Checklist:
// [ ] Output uses emoji indicators for severity
// [ ] File locations include line numbers
// [ ] Each issue has pattern name and fix suggestion
// [ ] Summary table shows status for each severity
// [ ] Verdict is clear (APPROVED/WARNING/BLOCKED)
// [ ] Output is readable in terminal/console
