// Test Case 011: Commented Code and Code Quality
// Expected:
// - Commented code should NOT be flagged (removed from detection)
// - Long method warning depends on layered threshold (70% for quality)

package com.test.quality

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class CodeQualityExample : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Test: Commented-out code (should NOT be flagged)
        // val oldImplementation = "deprecated code here"
        // fun oldMethod() {
        //     // Old logic that was removed
        // }

        // TODO: Refactor this method later
        // FIXME: Need to handle edge case

        processUserData()
    }

    // Test: Long method (90 lines) - Quality rule uses 70% threshold
    // May or may not be reported based on confidence score
    private fun processUserData() {
        val data1 = fetchData1()
        val data2 = fetchData2()
        val data3 = fetchData3()
        val data4 = fetchData4()
        val data5 = fetchData5()
        val data6 = fetchData6()
        val data7 = fetchData7()
        val data8 = fetchData8()
        val data9 = fetchData9()
        val data10 = fetchData10()

        processData(data1)
        processData(data2)
        processData(data3)
        processData(data4)
        processData(data5)
        processData(data6)
        processData(data7)
        processData(data8)
        processData(data9)
        processData(data10)

        validateData(data1)
        validateData(data2)
        validateData(data3)
        validateData(data4)
        validateData(data5)
        validateData(data6)
        validateData(data7)
        validateData(data8)
        validateData(data9)
        validateData(data10)

        saveData(data1)
        saveData(data2)
        saveData(data3)
        saveData(data4)
        saveData(data5)
        saveData(data6)
        saveData(data7)
        saveData(data8)
        saveData(data9)
        saveData(data10)
    }

    private fun fetchData1(): String = "data"
    private fun fetchData2(): String = "data"
    private fun fetchData3(): String = "data"
    private fun fetchData4(): String = "data"
    private fun fetchData5(): String = "data"
    private fun fetchData6(): String = "data"
    private fun fetchData7(): String = "data"
    private fun fetchData8(): String = "data"
    private fun fetchData9(): String = "data"
    private fun fetchData10(): String = "data"

    private fun processData(data: String) {}
    private fun validateData(data: String) {}
    private fun saveData(data: String) {}
}

// This test verifies:
// 1. Commented code detection is removed (no false positives)
// 2. Code quality rules use lower threshold (70%)
// 3. TODO/FIXME comments are properly recognized
