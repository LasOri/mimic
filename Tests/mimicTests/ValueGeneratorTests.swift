// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class ValueGeneratorTests: XCTestCase {

    func testBoolGenerator_returnsBool() {
        let generator = BoolGenerator()

        let result = generator.generate()

        XCTAssertNotNil(result)
    }

    func testBoolGenerator_producesBothValues() {
        let generator = BoolGenerator()
        var seenTrue = false
        var seenFalse = false

        for _ in 0..<100 {
            let value = generator.generate()
            if value { seenTrue = true } else { seenFalse = true }
            if seenTrue && seenFalse { break }
        }

        XCTAssertTrue(seenTrue, "BoolGenerator should produce true")
        XCTAssertTrue(seenFalse, "BoolGenerator should produce false")
    }

    func testIntGenerator_returnsNonNegative() {
        let generator = IntGenerator()

        let result = generator.generate()

        XCTAssertGreaterThanOrEqual(result, 0)
    }

    func testIntGenerator_producesVariedValues() {
        let generator = IntGenerator()
        let values = Set((0..<10).map { _ in generator.generate() })

        XCTAssertGreaterThan(values.count, 1, "IntGenerator should produce varied values")
    }

    func testDoubleGenerator_returnsPositive() {
        let generator = DoubleGenerator()

        let result = generator.generate()

        XCTAssertGreaterThan(result, 0)
    }

    func testDoubleGenerator_producesVariedValues() {
        let generator = DoubleGenerator()
        let values = Set((0..<10).map { _ in generator.generate() })

        XCTAssertGreaterThan(values.count, 1, "DoubleGenerator should produce varied values")
    }

    func testStringGenerator_returnsNonEmptyString() {
        let generator = StringGenerator()

        let result = generator.generate()

        XCTAssertFalse(result.isEmpty)
    }

    func testStringGenerator_returnsUUIDFormat() {
        let generator = StringGenerator()

        let result = generator.generate()

        XCTAssertEqual(result.count, 36, "UUID string should be 36 characters")
        XCTAssertTrue(result.contains("-"), "UUID string should contain dashes")
    }

    func testStringGenerator_producesUniqueValues() {
        let generator = StringGenerator()
        let value1 = generator.generate()
        let value2 = generator.generate()

        XCTAssertNotEqual(value1, value2)
    }
}
