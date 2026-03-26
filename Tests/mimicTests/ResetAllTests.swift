// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class ResetAllTests: XCTestCase {

    func testResetAll_resetsSingleFnProperty() throws {
        let mimickedClass = MimickedClass()
        mimickedClass.when(\.fwar).thenReturn("result")
        _ = try mimickedClass.functionWithArg(arg: "input")

        mimickedClass.resetAll()

        XCTAssertEqual(mimickedClass.fwar.invocationCount, 0)
        XCTAssertTrue(mimickedClass.fwar.logs.isEmpty)
    }

    func testResetAll_resetsMultipleFnProperties() throws {
        let mimickedClass = MimickedClass()
        mimickedClass.when(\.fwar).thenReturn("result")
        mimickedClass.when(\.fwr).thenReturn(())
        _ = try mimickedClass.functionWithArg(arg: "input")
        try mimickedClass.functionWithoutResult()

        mimickedClass.resetAll()

        XCTAssertEqual(mimickedClass.fwar.invocationCount, 0)
        XCTAssertEqual(mimickedClass.fwr.invocationCount, 0)
    }

    func testResetAll_afterResetCanReconfigure() throws {
        let mimickedClass = MimickedClass()
        mimickedClass.when(\.fwar).thenReturn("old")
        _ = try mimickedClass.functionWithArg(arg: "input")

        mimickedClass.resetAll()
        mimickedClass.when(\.fwar).thenReturn("new")

        let result = try mimickedClass.functionWithArg(arg: "input")
        XCTAssertEqual(result, "new")
        XCTAssertEqual(mimickedClass.fwar.invocationCount, 1)
    }

    func testResetAll_clearsFunctionClosures() {
        let mimickedClass = MimickedClass()
        mimickedClass.when(\.fwar).thenReturn("result")

        mimickedClass.resetAll()

        XCTAssertNil(mimickedClass.fwar.function)
        XCTAssertNil(mimickedClass.fwr.function)
    }
}
