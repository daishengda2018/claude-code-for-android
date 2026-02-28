// Test Case 006: ViewModel Coroutine Leak
// Expected Detection: HIGH (QUAL-003)
// Category: Memory / Lifecycle

package com.test.quality

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * This file demonstrates ViewModel coroutine leaks that the plugin should detect.
 *
 * Issues to detect:
 * [ ] Plugin detects custom CoroutineScope in ViewModel
 * [ ] Plugin detects missing viewModelScope usage
 * [ ] Plugin severity is HIGH
 * [ ] Plugin suggests using viewModelScope
 */

class LeakyViewModel : ViewModel() {

    // ========================================
    // Issue 1: Custom CoroutineScope instead of viewModelScope
    // ========================================

    // ❌ BUG: Creating custom CoroutineScope in ViewModel
    // This scope is NOT tied to ViewModel lifecycle and will leak
    private val customScope = CoroutineScope(Dispatchers.Main)

    fun loadDataBad() {
        // ❌ BUG: Using custom scope instead of viewModelScope
        // Work continues after ViewModel is cleared
        customScope.launch {
            // Long-running work that leaks
            kotlinx.coroutines.delay(5000)
            println("Data loaded")
        }
    }

    // ========================================
    // Issue 2: GlobalScope usage in ViewModel
    // ========================================

    fun loadGlobalData() {
        // ❌ BUG: Using GlobalScope in ViewModel
        // Work runs for entire application lifetime
        kotlinx.coroutines.GlobalScope.launch {
            kotlinx.coroutines.delay(5000)
            println("Global data loaded")
        }
    }

    // ========================================
    // Issue 3: Missing cleanup in onCleared()
    // ========================================

    override fun onCleared() {
        super.onCleared()
        // ❌ CRITICAL BUG: Not cancelling customScope!
        // Should call: customScope.cancel()
    }

    // ========================================
    // Correct Examples (for reference)
    // ========================================

    fun loadDataGood() {
        // ✅ CORRECT: Using viewModelScope
        // Automatically cancelled when ViewModel is cleared
        viewModelScope.launch {
            kotlinx.coroutines.delay(5000)
            println("Data loaded safely")
        }
    }

    class FixedViewModel : ViewModel() {

        // ✅ CORRECT: Use viewModelScope (built-in)
        fun loadData() {
            viewModelScope.launch {
                // Work automatically cancelled on clear
                kotlinx.coroutines.delay(5000)
                println("Safe data load")
            }
        }

        // ✅ CORRECT: If custom scope needed, cancel in onCleared()
        private val customScope = CoroutineScope(Dispatchers.Main)

        fun loadWithCustomScope() {
            customScope.launch {
                kotlinx.coroutines.delay(5000)
                println("Custom scope data")
            }
        }

        override fun onCleared() {
            super.onCleared()
            customScope.cancel() // Proper cleanup
        }
    }
}

// Verification Checklist:
// [ ] Plugin detects custom CoroutineScope in ViewModel (Issue 1)
// [ ] Plugin detects GlobalScope usage in ViewModel (Issue 2)
// [ ] Plugin detects missing onCleared() cleanup (Issue 3)
// [ ] Plugin severity is HIGH
// [ ] Plugin suggests using viewModelScope
