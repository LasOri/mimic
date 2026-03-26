// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class JsonFactoryTests: XCTestCase {

    let factory = JsonFactory(
        boolGenerator: BoolGenerator(),
        intGenerator: IntGenerator(),
        doubleGenerator: DoubleGenerator(),
        stringGenerator: StringGenerator()
    )

    func testCreate_boolType() throws {
        let result = try factory.create(Bool.self)

        if case .bool = result {
        } else {
            XCTFail("Expected Json.bool, got \(result)")
        }
    }

    func testCreate_intType() throws {
        let result = try factory.create(Int.self)

        if case .int = result {
        } else {
            XCTFail("Expected Json.int, got \(result)")
        }
    }

    func testCreate_doubleType() throws {
        let result = try factory.create(Double.self)

        if case .double = result {
        } else {
            XCTFail("Expected Json.double, got \(result)")
        }
    }

    func testCreate_stringType() throws {
        let result = try factory.create(String.self)

        if case .string = result {
        } else {
            XCTFail("Expected Json.string, got \(result)")
        }
    }

    func testCreate_arrayOfStrings() throws {
        let result = try factory.create(Array<String>.self)

        if case .array(let elements) = result {
            XCTAssertEqual(elements.count, 1)
            if case .string = elements[0] {
            } else {
                XCTFail("Expected array element to be Json.string, got \(elements[0])")
            }
        } else {
            XCTFail("Expected Json.array, got \(result)")
        }
    }

    func testCreate_arrayOfInts() throws {
        let result = try factory.create(Array<Int>.self)

        if case .array(let elements) = result {
            XCTAssertEqual(elements.count, 1)
            if case .int = elements[0] {
            } else {
                XCTFail("Expected array element to be Json.int, got \(elements[0])")
            }
        } else {
            XCTFail("Expected Json.array, got \(result)")
        }
    }

    func testCreate_dictionaryStringToString() throws {
        let result = try factory.create(Dictionary<String, String>.self)

        if case .object(let dict) = result {
            XCTAssertEqual(dict.count, 1)
            if case .string = dict.values.first {
            } else {
                XCTFail("Expected dictionary value to be Json.string")
            }
        } else {
            XCTFail("Expected Json.object, got \(result)")
        }
    }

    func testCreate_dictionaryStringToInt() throws {
        let result = try factory.create(Dictionary<String, Int>.self)

        if case .object(let dict) = result {
            XCTAssertEqual(dict.count, 1)
            if case .int = dict.values.first {
            } else {
                XCTFail("Expected dictionary value to be Json.int")
            }
        } else {
            XCTFail("Expected Json.object, got \(result)")
        }
    }

    func testCreate_unknownType_returnsObjectWithStringValues() throws {
        let result = try factory.create(SomeSubStruct.self)

        if case .object(let dict) = result {
            XCTAssertEqual(dict.count, 1)
            if case .string = dict.values.first {
            } else {
                XCTFail("Expected fallback object value to be Json.string")
            }
        } else {
            XCTFail("Expected Json.object for unknown type, got \(result)")
        }
    }

    func testGenerate_emptyTypeNames_throwsDecodingFailed() {
        XCTAssertThrowsError(try factory.generate([])) { error in
            XCTAssertEqual(error as! MimicError, .decodingFailed(message: "typeNames is empty."))
        }
    }

    func testGenerate_arrayWithoutElementType_throwsDecodingFailed() {
        XCTAssertThrowsError(try factory.generate(["Array"])) { error in
            XCTAssertEqual(error as! MimicError, .decodingFailed(message: "Array type is not available"))
        }
    }

    func testGenerate_dictionaryWithoutValueType_throwsDecodingFailed() {
        XCTAssertThrowsError(try factory.generate(["Dictionary"])) { error in
            XCTAssertEqual(error as! MimicError, .decodingFailed(message: "Dictionary type is not available"))
        }
    }

    func testGenerate_dictionaryWithOnlyKeyType_throwsDecodingFailed() {
        XCTAssertThrowsError(try factory.generate(["Dictionary", "String"])) { error in
            XCTAssertEqual(error as! MimicError, .decodingFailed(message: "Dictionary type is not available"))
        }
    }

    func testGenerate_boolTypeName() throws {
        let result = try factory.generate(["Bool"])

        if case .bool = result {
        } else {
            XCTFail("Expected Json.bool, got \(result)")
        }
    }

    func testGenerate_nestedArrayOfBool() throws {
        let result = try factory.generate(["Array", "Bool"])

        if case .array(let elements) = result {
            XCTAssertEqual(elements.count, 1)
            if case .bool = elements[0] {
            } else {
                XCTFail("Expected array element to be Json.bool, got \(elements[0])")
            }
        } else {
            XCTFail("Expected Json.array, got \(result)")
        }
    }

    func testGenerate_dictionaryStringToDouble() throws {
        let result = try factory.generate(["Dictionary", "String", "Double"])

        if case .object(let dict) = result {
            XCTAssertEqual(dict.count, 1)
            if case .double = dict.values.first {
            } else {
                XCTFail("Expected dictionary value to be Json.double")
            }
        } else {
            XCTFail("Expected Json.object, got \(result)")
        }
    }
}
