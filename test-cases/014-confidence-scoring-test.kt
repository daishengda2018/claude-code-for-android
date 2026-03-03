// Test Case 014: Confidence Scoring Test
// Purpose: Verify only high-confidence findings (>90%) are reported
// Expected: Low-confidence detections are filtered out

package com.test.confidence

import android.app.Activity

class AmbiguousCase : Activity() {

    // This might be a handler, or might not be
    // LOW CONFIDENCE: Could be intentional
    private val someHandler = android.os.Handler()

    // This is clearly a hardcoded secret
    // HIGH CONFIDENCE: Definitely a security issue
    private const val API_KEY = "sk_test_12345abcdef"

    // This might need cleanup, context-dependent
    // LOW CONFIDENCE: Depends on usage
    private var tempValue: String? = null

    fun ambiguousMethod() {
        // Could be a bug or could be intentional
        // LOW CONFIDENCE: Need more context
        someHandler.post { }
    }
}

// Verification Checklist:
// [ ] API_KEY detected (HIGH confidence, >90%)
// [ ] someHandler NOT reported or reported as LOW confidence
// [ ] tempValue NOT reported without usage context
// [ ] Confidence threshold is 90%
// [ ] False positives are minimized
