package com.test.examples

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Example: Proper ViewModel implementation
 *
 * Demonstrates:
 * - Unidirectional Data Flow (UDF)
 * - State management
 * - Coroutine integration
 * - Lifecycle awareness
 */

class ProperViewModel : ViewModel() {

    // ========================================
    // Immutable State (UDF Pattern)
    // ========================================

    private val _uiState = MutableLiveData<UiState>()
    val uiState: LiveData<UiState> = _uiState

    data class UiState(
        val isLoading: Boolean = false,
        val data: String? = null,
        val error: String? = null
    )

    // ========================================
    // State Updates (Immutable)
    // ========================================

    fun updateData(newData: String) {
        // ✅ CORRECT: Immutable state update
        _uiState.value = _uiState.value?.copy(
            isLoading = false,
            data = newData,
            error = null
        )
    }

    fun setLoading(loading: Boolean) {
        // ✅ CORRECT: Update only loading field
        _uiState.value = _uiState.value?.copy(isLoading = loading)
    }

    // ========================================
    // Coroutine Scopes
    // ========================================

    fun fetchData() {
        viewModelScope.launch {
            // ✅ CORRECT: Use viewModelScope
            // Automatically cancelled when ViewModel is cleared
            setLoading(true)

            try {
                val result = withContext(Dispatchers.IO) {
                    // Simulate network call
                    Thread.sleep(1000)
                    "Data loaded"
                }
                updateData(result)
            } catch (e: Exception) {
                _uiState.value = _uiState.value?.copy(
                    isLoading = false,
                    error = e.message
                )
            }
        }
    }

    // ========================================
    // Proper Cleanup
    // ========================================

    override fun onCleared() {
        super.onCleared()
        // ✅ ViewModelScope automatically cancelled here
        // No manual cleanup needed for coroutines
    }
}

/**
 * Application-scoped ViewModel example
 */

class ApplicationViewModel(application: Application) : AndroidViewModel(application) {

    // ✅ CORRECT: Application context for long-lived resources
    private val appContext = application.applicationContext

    private val _globalState = MutableLiveData<String>()
    val globalState: LiveData<String> = _globalState

    fun updateGlobalState(newState: String) {
        _globalState.value = newState
    }
}

// ========================================
// UI State Pattern (UDF)
// ========================================

sealed class UiEvent {
    object NavigateToHome : UiEvent()
    object ShowError : UiEvent()
    data class ShowToast(val message: String) : UiEvent()
}

// ========================================
// Repository Pattern Example
// ========================================

class Repository(private val context: Application) {

    // ✅ CORRECT: Suspend function for async operations
    suspend fun getData(): Result<String> = withContext(Dispatchers.IO) {
        try {
            // Network/database operation
            Result.success("Data")
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
