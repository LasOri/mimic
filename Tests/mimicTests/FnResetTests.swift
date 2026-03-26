// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class FnResetTests: XCTestCase {

    func testReset_setsInvocationCountToZero() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")
        _ = try fn.invoke()
        _ = try fn.invoke()

        fn.reset()

        XCTAssertEqual(fn.invocationCount, 0)
    }

    func testReset_clearsLogs() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")
        _ = try fn.invoke()

        fn.reset()

        XCTAssertTrue(fn.logs.isEmpty)
    }

    func testReset_clearsFunctionClosure() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")

        fn.reset()

        XCTAssertNil(fn.function)
    }

    func testReset_clearsName() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")
        _ = try fn.invoke()

        fn.reset()

        XCTAssertNil(fn.name)
    }

    func testReset_afterResetInvokeThrowsIncompleteMimicking() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")
        _ = try fn.invoke()

        fn.reset()

        XCTAssertThrowsError(try fn.invoke()) { error in
            XCTAssertEqual(error as! MimicError, .incompleteMimicking)
        }
    }

    func testReset_afterResetCanReconfigureViaWhen() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("first")
        _ = try fn.invoke()

        fn.reset()
        fn.when.thenReturn("second")

        let result = try fn.invoke()
        XCTAssertEqual(result, "second")
    }

    func testReset_afterResetInvocationCountStartsFresh() throws {
        let fn = Fn<String>()
        fn.when.thenReturn("result")
        _ = try fn.invoke()
        _ = try fn.invoke()
        _ = try fn.invoke()

        fn.reset()
        fn.when.thenReturn("result")
        _ = try fn.invoke()

        XCTAssertEqual(fn.invocationCount, 1)
    }

    func testReset_onFreshFnDoesNotCrash() {
        let fn = Fn<String>()

        fn.reset()

        XCTAssertEqual(fn.invocationCount, 0)
        XCTAssertTrue(fn.logs.isEmpty)
        XCTAssertNil(fn.function)
    }

    func testReset_onFnWithDefaultReturnClearsFunction() {
        let fn = Fn<String>("default")

        fn.reset()

        XCTAssertNil(fn.function)
    }

    func testReset_voidFn() throws {
        let fn = Fn<()>()
        fn.when.thenReturn(())
        try fn.invoke()

        fn.reset()

        XCTAssertEqual(fn.invocationCount, 0)
        XCTAssertTrue(fn.logs.isEmpty)
    }
}
