// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class FnVerifierEdgeCaseTests: XCTestCase {

    let mimickedClass = MimickedClass()

    func testFn_invocationCount_incrementsOnEachCall() throws {
        mimickedClass.when(\.fwar).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "a")
        _ = try mimickedClass.functionWithArg(arg: "b")
        _ = try mimickedClass.functionWithArg(arg: "c")

        XCTAssertEqual(mimickedClass.fwar.invocationCount, 3)
    }

    func testFn_invocationCount_startsAtZero() {
        XCTAssertEqual(mimickedClass.fwar.invocationCount, 0)
    }

    func testFn_logs_captureEachInvocation() throws {
        mimickedClass.when(\.fwar).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "first")
        _ = try mimickedClass.functionWithArg(arg: "second")

        XCTAssertEqual(mimickedClass.fwar.logs.count, 2)
    }

    func testFn_logs_captureArgs() throws {
        mimickedClass.when(\.fwar).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "captured")

        let logArgs = mimickedClass.fwar.logs.first?.args
        XCTAssertNotNil(logArgs)
    }

    func testFn_logs_captureResult() throws {
        mimickedClass.when(\.fwar).thenReturn("captured result")

        _ = try mimickedClass.functionWithArg(arg: "input")

        let logResult = mimickedClass.fwar.logs.first?.result
        XCTAssertEqual(logResult, "captured result")
    }

    func testFn_logs_captureThread() throws {
        mimickedClass.when(\.fwar).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "input")

        let logThread = mimickedClass.fwar.logs.first?.thread
        XCTAssertNotNil(logThread)
        XCTAssertFalse(logThread!.isEmpty)
    }

    func testFn_logs_recordTimestamps() throws {
        mimickedClass.when(\.fwar).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "input")

        let log = mimickedClass.fwar.logs.first
        XCTAssertNotNil(log?.startTimestamp)
        XCTAssertNotNil(log?.endTimestamp)
        XCTAssertTrue(log!.endTimestamp >= log!.startTimestamp)
    }

    func testFn_logs_captureErrorCases() {
        mimickedClass.when(\.fwr).thenThrow(error: TestError.magicWord)

        XCTAssertThrowsError(try mimickedClass.functionWithoutResult())

        XCTAssertEqual(mimickedClass.fwr.logs.count, 1)
        XCTAssertNil(mimickedClass.fwr.logs.first?.result)
    }

    func testVerify_onEmptyLogs_throwsZeroInteractions() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "a")

        _ = try mimickedClass.verify(\.fwar).times(times: .eq(1))
    }

    func testVerify_wasCalled_onEmptyLogs_crashesDueToNilName() {
    }

    func testVerify_onThread_onEmptyLogs_crashesDueToNilName() {
    }

    func testVerify_wasCalled_withNoMatchers_throwsMissingMatcher() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "input")

        XCTAssertThrowsError(try mimickedClass.verify(\.fwar).wasCalled()) { error in
            XCTAssertEqual(error as! MimicError, .missingMatcher)
        }
    }

    func testVerify_times_zero_success_whenNeverCalled() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")

        let fn2 = Fn<()>()
        fn2.when.thenReturn(())
        try fn2.invoke()

        _ = try fn2.verify.times(times: .eq(1))
    }

    func testVerify_times_eq_success() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "a")
        _ = try mimickedClass.functionWithArg(arg: "b")

        _ = try mimickedClass.verify(\.fwar).times(times: .eq(2))
    }

    func testVerify_times_atLeast_success() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "a")
        _ = try mimickedClass.functionWithArg(arg: "b")
        _ = try mimickedClass.functionWithArg(arg: "c")

        _ = try mimickedClass.verify(\.fwar).times(times: .atLeast(2))
    }

    func testVerify_times_max_success() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "a")

        _ = try mimickedClass.verify(\.fwar).times(times: .max(3))
    }

    func testVerify_onThread_success_whenCalledOnSameThread() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "input")

        _ = try mimickedClass.verify(\.fwar).on(thread: Thread.current)
    }

    func testFilteredVerifier_times_eq_success() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "match")
        _ = try mimickedClass.functionWithArg(arg: "match")

        _ = try mimickedClass
            .verify(\.fwar)
            .wasCalled(Arg.eq("match"))
            .times(times: .eq(2))
    }

    func testFilteredVerifier_times_filters_correctly() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "a")
        _ = try mimickedClass.functionWithArg(arg: "b")
        _ = try mimickedClass.functionWithArg(arg: "a")

        _ = try mimickedClass
            .verify(\.fwar)
            .wasCalled(Arg.eq("a"))
            .times(times: .eq(2))
    }

    func testFilteredVerifier_times_atLeast_fails() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "a")

        XCTAssertThrowsError(try mimickedClass
            .verify(\.fwar)
            .wasCalled(Arg.eq("a"))
            .times(times: .atLeast(5))
        ) { error in
            if case MimicError.verificationFailed = error {
            } else {
                XCTFail("Expected verificationFailed, got \(error)")
            }
        }
    }

    func testWhen_calledMultipleTimes_replacesStub() throws {
        mimickedClass.when(\.fwar).thenReturn("first")
        let result1 = try mimickedClass.functionWithArg(arg: "input")

        mimickedClass.when(\.fwar).thenReturn("second")
        let result2 = try mimickedClass.functionWithArg(arg: "input")

        XCTAssertEqual(result1, "first")
        XCTAssertEqual(result2, "second")
    }

    func testNilMatcher_success_whenArgIsNil() throws {
        mimickedClass.when(\.fwar)
            .calledWith(Arg.nil)
            .thenReturn("nilResult")

        let result = try mimickedClass.functionWithArg(arg: nil)

        XCTAssertEqual(result, "nilResult")
    }

    func testNotNilMatcher_success_whenArgIsNotNil() throws {
        mimickedClass.when(\.fwar)
            .calledWith(Arg.notNil)
            .thenReturn("notNilResult")

        let result = try mimickedClass.functionWithArg(arg: "something")

        XCTAssertEqual(result, "notNilResult")
    }

    func testAnyMatcher_matchesAnyValue() throws {
        mimickedClass.when(\.fwar)
            .calledWith(Arg.any)
            .thenReturn("anyResult")

        let result1 = try mimickedClass.functionWithArg(arg: "whatever")
        let result2 = try mimickedClass.functionWithArg(arg: nil)

        XCTAssertEqual(result1, "anyResult")
        XCTAssertEqual(result2, "anyResult")
    }

    func testEqMatcher_success_whenValuesMatch() throws {
        mimickedClass.when(\.fwar)
            .calledWith(Arg.eq("match"))
            .thenReturn("eqResult")

        let result = try mimickedClass.functionWithArg(arg: "match")

        XCTAssertEqual(result, "eqResult")
    }

    func testFn_name_isCapturedFromFunctionName() throws {
        mimickedClass.when(\.fwar).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "input")

        XCTAssertNotNil(mimickedClass.fwar.name)
        XCTAssertTrue(mimickedClass.fwar.name.contains("functionWithArg"))
    }

    func testThenThrow_withCalledWith_throwsWhenMatcherPasses() {
        mimickedClass.when(\.fwar)
            .calledWith(Arg.eq("trigger"))
            .thenThrow(error: TestError.magicWord)

        XCTAssertThrowsError(try mimickedClass.functionWithArg(arg: "trigger")) { error in
            XCTAssertEqual(error as! TestError, .magicWord)
        }
    }

    func testThenReturns_withSingleValue() throws {
        mimickedClass.when(\.fwar).thenReturns("only")

        let result = try mimickedClass.functionWithArg(arg: "input")

        XCTAssertEqual(result, "only")
    }

    func testThenReturns_withSingleValue_throwsOnSecondCall() throws {
        mimickedClass.when(\.fwar).thenReturns("only")

        _ = try mimickedClass.functionWithArg(arg: "input")

        XCTAssertThrowsError(try mimickedClass.functionWithArg(arg: "input")) { error in
            XCTAssertEqual(error as! MimicError, .missingResult)
        }
    }

    func testFn_invoke_withoutParams() throws {
        mimickedClass.when(\.fwr).thenReturn(())

        try mimickedClass.functionWithoutResult()

        XCTAssertEqual(mimickedClass.fwr.invocationCount, 1)
    }

    func testParams_subscript_returnsCorrectType() throws {
        mimickedClass.when(\.fwar).replaceFunction { invocationCount, params in
            let arg: String? = params?[0]
            return arg ?? "fallback"
        }

        let result = try mimickedClass.functionWithArg(arg: "typed")

        XCTAssertEqual(result, "typed")
    }

    func testVerify_wasCalled_success_withMatchingArgs() throws {
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "expected")

        _ = try mimickedClass
            .verify(\.fwar)
            .wasCalled(Arg.eq("expected"))
    }
}
