// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class InstanceGeneratorExtendedTests: XCTestCase {

    let instanceGenerator = InstanceGenerator()

    func testGenerate_simpleStruct() throws {
        let result: SomeSubStruct = try instanceGenerator.generate(nil)

        XCTAssertFalse(result.text.isEmpty)
    }

    func testGenerate_innerStruct_withNestedSubStruct() throws {
        let result: InnerStruct = try instanceGenerator.generate(nil)

        XCTAssertFalse(result.subStruct.text.isEmpty)
        XCTAssertFalse(result.dict.isEmpty)
        XCTAssertFalse(result.array.isEmpty)
    }

    func testGenerate_complexStruct_withEncodables() throws {
        let result: SomeStruct = try instanceGenerator.generate(nil, [SomeEnum.case2])

        XCTAssertFalse(result.text.isEmpty)
        XCTAssertFalse(result.array.isEmpty)
        XCTAssertFalse(result.dict.isEmpty)
        XCTAssertFalse(result.inner.subStruct.text.isEmpty)
    }

    func testGenerate_complexStruct_allFieldsPopulated() throws {
        let result: SomeStruct = try instanceGenerator.generate(nil, [SomeEnum.case1("text", 42)])

        XCTAssertFalse(result.text.isEmpty)
        XCTAssertGreaterThanOrEqual(result.num, 0)
        XCTAssertGreaterThan(result.floating, 0)
        XCTAssertFalse(result.array.isEmpty)
        XCTAssertFalse(result.dict.isEmpty)
    }

    func testGenerate_withPredefinedString() throws {
        let expected = "predetermined"
        let predefined: [PartialKeyPath<SomeSubStruct>: Encodable] = [
            \SomeSubStruct.text: expected
        ]

        let result: SomeSubStruct = try instanceGenerator.generate(predefined, nil)

        XCTAssertEqual(result.text, expected)
    }

    func testGenerate_withPredefinedInt() throws {
        let predefined: [PartialKeyPath<SomeStruct>: Encodable] = [
            \SomeStruct.num: 999
        ]

        let result: SomeStruct = try instanceGenerator.generate(predefined, [SomeEnum.case2])

        XCTAssertEqual(result.num, 999)
    }

    func testGenerate_withPredefinedBool() throws {
        let predefined: [PartialKeyPath<SomeStruct>: Encodable] = [
            \SomeStruct.bool: false
        ]

        let result: SomeStruct = try instanceGenerator.generate(predefined, [SomeEnum.case2])

        XCTAssertEqual(result.bool, false)
    }

    func testGenerate_withMultiplePredefinedValues() throws {
        let predefined: [PartialKeyPath<SomeStruct>: Encodable] = [
            \SomeStruct.text: "fixed",
            \SomeStruct.num: 7,
            \SomeStruct.bool: true
        ]

        let result: SomeStruct = try instanceGenerator.generate(predefined, [SomeEnum.case2])

        XCTAssertEqual(result.text, "fixed")
        XCTAssertEqual(result.num, 7)
        XCTAssertEqual(result.bool, true)
    }

    func testGenerate_nilPredefinedValues_nilEncodables_simpleStruct() throws {
        let result: SomeSubStruct = try instanceGenerator.generate(nil, nil)

        XCTAssertFalse(result.text.isEmpty)
    }

    func testGenerate_convenienceOverload_nilEncodables() throws {
        let result: SomeSubStruct = try instanceGenerator.generate(nil)

        XCTAssertFalse(result.text.isEmpty)
    }

    func testGenerate_producesVariedResults() throws {
        let result1: SomeSubStruct = try instanceGenerator.generate(nil)
        let result2: SomeSubStruct = try instanceGenerator.generate(nil)

        XCTAssertNotEqual(result1.text, result2.text)
    }

    func testGenerate_encodableMatchesByType() throws {
        let result: SomeStruct = try instanceGenerator.generate(nil, [SomeEnum.case1("hello", 42)])

        XCTAssertNotNil(result.someEnum)
    }

    func testGenerate_multipleEncodables() throws {
        let result: SomeStruct = try instanceGenerator.generate(nil, [
            SomeEnum.case1("text", 1),
            SomeEnum.case2
        ])

        XCTAssertNotNil(result.someEnum)
    }

    func testGenerate_optionalFieldCanBeGenerated() throws {
        let result: SomeStruct = try instanceGenerator.generate(nil, [SomeEnum.case2])

        XCTAssertNotNil(result)
    }

    func testGenerate_predefinedOptionalField_isNotApplied() throws {
        let predefined: [PartialKeyPath<SomeStruct>: Encodable] = [
            \SomeStruct.optional: "notNil"
        ]

        let result: SomeStruct = try instanceGenerator.generate(predefined, [SomeEnum.case2])

        XCTAssertNil(result.optional)
    }

    struct SimplePrimitive: Decodable {
        let name: String
        let age: Int
        let active: Bool
        let score: Double
    }

    func testGenerate_structWithOnlyPrimitives() throws {
        let result: SimplePrimitive = try instanceGenerator.generate(nil, nil)

        XCTAssertFalse(result.name.isEmpty)
        XCTAssertGreaterThanOrEqual(result.age, 0)
        XCTAssertGreaterThan(result.score, 0)
    }

    struct CollectionStruct: Decodable {
        let tags: [String]
        let metadata: [String: String]
    }

    func testGenerate_structWithCollections() throws {
        let result: CollectionStruct = try instanceGenerator.generate(nil, nil)

        XCTAssertFalse(result.tags.isEmpty)
        XCTAssertFalse(result.metadata.isEmpty)
    }

    struct Level3: Decodable { let value: String }
    struct Level2: Decodable { let nested: Level3 }
    struct Level1: Decodable { let nested: Level2 }

    func testGenerate_deeplyNestedStruct() throws {
        let result: Level1 = try instanceGenerator.generate(nil, nil)

        XCTAssertFalse(result.nested.nested.value.isEmpty)
    }
}
