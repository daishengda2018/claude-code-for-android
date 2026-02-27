package com.test.bugs.npe

import android.app.Activity
import android.os.Bundle

/**
 * Test Case 001: Null Pointer Exceptions (NPE)
 *
 * Expected Detection: MEDIUM
 * Category: Code Quality / Safety
 *
 * This file demonstrates various NPE risks that the plugin should detect.
 *
 * Issues to detect:
 * [ ] Plugin detects force unwrap operator (!!)
 * [ ] Plugin severity is MEDIUM
 * [ ] Plugin suggests safe alternatives
 */

class ForceUnwrapActivity : Activity() {

    // ========================================
    // Issue 1: Force unwrap on nullable field
    // ========================================

    private var nullableString: String? = null

    fun demonstrateForceUnwrap() {
        // ❌ BUG: Force unwrap on nullable field
        // Risk: NPE if nullableString is null
        val length = nullableString!!.length
        println("Length: $length")
    }

    // ========================================
    // Issue 2: Force unwrap on method parameter
    // ========================================

    fun processInput(input: String?): Int {
        // ❌ BUG: Force unwrap on parameter
        // Risk: NPE if input is null
        return input!!.length
    }

    // ========================================
    // Issue 3: Force unwrap in chain
    // ========================================

    private lateinit var lateInitString: String

    fun demonstrateLateInitIssue() {
        // ❌ BUG: Using lateinit before initialization
        // Risk: UninitializedPropertyException
        try {
            println(lateInitString.length)
        } catch (e: Exception) {
            // This will crash if not initialized
        }
    }

    // ========================================
    // Issue 4: Unsafe method call on nullable
    // ========================================

    private fun getNullableName(): String? {
        return null
    }

    fun demonstrateUnsafeMethodCall() {
        // ❌ BUG: Method call on nullable without check
        // Risk: NPE if getNullableName() returns null
        val name = getNullableName()
        val upper = name.uppercase()  // NPE risk!
        println(upper)
    }

    // ========================================
    // Correct Examples (for reference)
    // ========================================

    fun demonstrateSafeCall() {
        // ✅ CORRECT: Safe call operator
        val length = nullableString?.length ?: 0
        println("Length: $length")
    }

    fun demonstrateExplicitCheck() {
        // ✅ CORRECT: Explicit null check
        val input = nullableString
        if (input != null) {
            println(input.length)
        }
    }

    fun demonstrateEarlyReturn() {
        // ✅ CORRECT: Early return pattern
        val text = nullableString ?: return
        println(text.length)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        demonstrateForceUnwrap()
        demonstrateLateInitIssue()
        demonstrateUnsafeMethodCall()
    }
}
