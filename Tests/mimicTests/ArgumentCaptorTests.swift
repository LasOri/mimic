// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class ArgumentCaptorTests: XCTestCase {

    func testCapture_capturesSingleValue() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<String>()
        fn.when.calledWith(captor.capture()).thenReturn("result")

        _ = try fn.invoke(params: "hello")

        XCTAssertEqual(captor.values, ["hello"])
    }

    func testCapture_capturesMultipleValues() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<String>()
        fn.when.calledWith(captor.capture()).thenReturn("result")

        _ = try fn.invoke(params: "first")
        _ = try fn.invoke(params: "second")
        _ = try fn.invoke(params: "third")

        XCTAssertEqual(captor.values, ["first", "second", "third"])
    }

    func testCapture_firstValue_returnsFirstCaptured() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<String>()
        fn.when.calledWith(captor.capture()).thenReturn("result")

        _ = try fn.invoke(params: "alpha")
        _ = try fn.invoke(params: "beta")

        XCTAssertEqual(captor.firstValue, "alpha")
    }

    func testCapture_lastValue_returnsLastCaptured() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<String>()
        fn.when.calledWith(captor.capture()).thenReturn("result")

        _ = try fn.invoke(params: "alpha")
        _ = try fn.invoke(params: "beta")

        XCTAssertEqual(captor.lastValue, "beta")
    }

    func testCapture_firstValue_returnsNilWhenNoCaptures() {
        let captor = ArgumentCaptor<String>()

        XCTAssertNil(captor.firstValue)
    }

    func testCapture_lastValue_returnsNilWhenNoCaptures() {
        let captor = ArgumentCaptor<String>()

        XCTAssertNil(captor.lastValue)
    }

    func testCapture_values_returnsEmptyArrayWhenNoCaptures() {
        let captor = ArgumentCaptor<String>()

        XCTAssertTrue(captor.values.isEmpty)
    }

    func testCapture_reset_clearsValues() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<String>()
        fn.when.calledWith(captor.capture()).thenReturn("result")
        _ = try fn.invoke(params: "hello")

        captor.reset()

        XCTAssertTrue(captor.values.isEmpty)
        XCTAssertNil(captor.firstValue)
        XCTAssertNil(captor.lastValue)
    }

    func testCapture_reset_allowsReuse() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<String>()
        fn.when.calledWith(captor.capture()).thenReturn("result")
        _ = try fn.invoke(params: "old")

        captor.reset()
        _ = try fn.invoke(params: "new")

        XCTAssertEqual(captor.values, ["new"])
    }

    func testCapture_withMimickedClass() throws {
        let mimickedClass = MimickedClass()
        let captor = ArgumentCaptor<String>()
        mimickedClass.when(\.fwar).calledWith(captor.capture()).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "test-input")

        XCTAssertEqual(captor.firstValue, "test-input")
    }

    func testCapture_withMultipleCaptorsInSingleCall() throws {
        let fn = Fn<()>()
        let captorString = ArgumentCaptor<String>()
        let captorInt = ArgumentCaptor<Int>()
        fn.when.calledWith(captorString.capture(), captorInt.capture()).thenReturn(())

        try fn.invoke(params: "hello", 42)

        XCTAssertEqual(captorString.firstValue, "hello")
        XCTAssertEqual(captorInt.firstValue, 42)
    }

    func testCapture_mixedWithEqMatcher() throws {
        let fn = Fn<()>()
        let captor = ArgumentCaptor<Int>()
        fn.when.calledWith(Arg.eq("fixed"), captor.capture()).thenReturn(())

        try fn.invoke(params: "fixed", 100)
        try fn.invoke(params: "fixed", 200)

        XCTAssertEqual(captor.values, [100, 200])
    }

    func testCapture_withIntType() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<Int>()
        fn.when.calledWith(captor.capture()).thenReturn("ok")

        _ = try fn.invoke(params: 42)
        _ = try fn.invoke(params: 99)

        XCTAssertEqual(captor.values, [42, 99])
    }

    func testCapture_withBoolType() throws {
        let fn = Fn<String>()
        let captor = ArgumentCaptor<Bool>()
        fn.when.calledWith(captor.capture()).thenReturn("ok")

        _ = try fn.invoke(params: true)
        _ = try fn.invoke(params: false)

        XCTAssertEqual(captor.values, [true, false])
    }

    func testCapture_separateInstancesMaintainSeparateState() throws {
        let fn = Fn<String>()
        let captor1 = ArgumentCaptor<String>()
        let captor2 = ArgumentCaptor<String>()
        fn.when.calledWith(captor1.capture()).thenReturn("r1")

        _ = try fn.invoke(params: "value1")

        fn.when.calledWith(captor2.capture()).thenReturn("r2")
        _ = try fn.invoke(params: "value2")

        XCTAssertEqual(captor1.values, ["value1"])
        XCTAssertEqual(captor2.values, ["value2"])
    }

    func testCapture_viaArgFactory() throws {
        let fn = Fn<String>()
        let captor: ArgumentCaptor<String> = Arg.captor()
        fn.when.calledWith(captor.capture()).thenReturn("result")

        _ = try fn.invoke(params: "via-factory")

        XCTAssertEqual(captor.firstValue, "via-factory")
    }

    func testCapture_withVerifyWasCalled() throws {
        let mimickedClass = MimickedClass()
        let captorWhen = ArgumentCaptor<String>()
        let captorVerify = ArgumentCaptor<String>()
        mimickedClass.when(\.fwar).calledWith(captorWhen.capture()).thenReturn("result")

        _ = try mimickedClass.functionWithArg(arg: "verified-input")

        _ = try mimickedClass.verify(\.fwar).wasCalled(captorVerify.capture())
        XCTAssertEqual(captorVerify.firstValue, "verified-input")
    }
}
