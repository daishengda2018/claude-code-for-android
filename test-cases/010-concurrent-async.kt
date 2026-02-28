// Test Case 010: Concurrent Modification - Async Context (UNSAFE)
// Expected: SHOULD trigger ConcurrentModification warning

package com.test.concurrent

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch

class UnsafeConcurrentExample : ViewModel() {

    fun processData() {
        // UNSAFE: Collection modification in coroutine context
        // SHOULD trigger ConcurrentModification warning
        // because viewModelScope.launch is async evidence
        viewModelScope.launch {
            val numbers = mutableListOf(1, 2, 3, 4, 5)
            numbers.forEach {
                if (it == 3) {
                    numbers.remove(it)  // UNSAFE: ConcurrentModificationException
                }
            }
        }
    }

    // Another example with lifecycleScope
    fun processInLifecycle() {
        // UNSAFE: async context evidence
        val items = mutableListOf<String>()
        // This would be called from a lifecycle coroutine
        items.forEach { item ->
            if (item.isEmpty()) {
                items.remove(item)  // ConcurrentModification risk
            }
        }
    }
}

// Note: This test case verifies that ConcurrentModification
// detection DOES report when async context is present.
// Both viewModelScope and coroutine usage are detected.
