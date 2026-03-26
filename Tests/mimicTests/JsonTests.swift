// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class JsonTests: XCTestCase {

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func testEncodeDecode_string() throws {
        let json = Json.string("hello")

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_int() throws {
        let json = Json.int(42)

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_double() throws {
        let json = Json.double(3.14)

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_bool() throws {
        let json = Json.bool(true)

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_boolFalse() throws {
        let json = Json.bool(false)

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_object() throws {
        let json = Json.object(["key": .string("value"), "num": .int(1)])

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_array() throws {
        let json = Json.array([.string("a"), .int(1), .bool(true)])

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_nil() throws {
        let json = Json.nil

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_emptyObject() throws {
        let json = Json.object([:])

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_emptyArray() throws {
        let json = Json.array([])

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_nestedObject() throws {
        let json = Json.object([
            "outer": .object([
                "inner": .string("deep")
            ])
        ])

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEncodeDecode_nestedArray() throws {
        let json = Json.array([.array([.int(1), .int(2)]), .array([.int(3)])])

        let data = try encoder.encode(json)
        let decoded = try decoder.decode(Json.self, from: data)

        XCTAssertEqual(decoded, json)
    }

    func testEquatable_sameValues() {
        XCTAssertEqual(Json.string("a"), Json.string("a"))
        XCTAssertEqual(Json.int(1), Json.int(1))
        XCTAssertEqual(Json.double(1.5), Json.double(1.5))
        XCTAssertEqual(Json.bool(true), Json.bool(true))
        XCTAssertEqual(Json.nil, Json.nil)
    }

    func testEquatable_differentValues() {
        XCTAssertNotEqual(Json.string("a"), Json.string("b"))
        XCTAssertNotEqual(Json.int(1), Json.int(2))
        XCTAssertNotEqual(Json.bool(true), Json.bool(false))
    }

    func testEquatable_differentCases() {
        XCTAssertNotEqual(Json.string("1"), Json.int(1))
        XCTAssertNotEqual(Json.int(1), Json.bool(true))
    }

    func testSubscriptGet_singleKey_objectValue() {
        let json = Json.object(["name": .string("test")])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        let result = json[[Key(stringValue: "name")]]

        XCTAssertEqual(result, .string("test"))
    }

    func testSubscriptGet_nestedKeys_objectValue() {
        let json = Json.object([
            "outer": .object([
                "inner": .string("deep")
            ])
        ])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        let result = json[[Key(stringValue: "outer"), Key(stringValue: "inner")]]

        XCTAssertEqual(result, .string("deep"))
    }

    func testSubscriptGet_missingKey_returnsNil() {
        let json = Json.object(["name": .string("test")])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        let result = json[[Key(stringValue: "missing")]]

        XCTAssertNil(result)
    }

    func testSubscriptGet_emptyKeys_returnsNil() {
        let json = Json.object(["name": .string("test")])
        let keys: [CodingKey] = []

        let result = json[keys]

        XCTAssertNil(result)
    }

    func testSubscriptGet_arrayWithIntKey() {
        let json = Json.array([.string("first"), .string("second")])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int?
            init(stringValue: String, intValue: Int) {
                self.stringValue = stringValue
                self.intValue = intValue
            }
            init?(intValue: Int) {
                self.stringValue = "\(intValue)"
                self.intValue = intValue
            }
            init?(stringValue: String) { nil }
        }

        let result = json[[Key(intValue: 1)!]]

        XCTAssertEqual(result, .string("second"))
    }

    func testSubscriptSet_singleKey_setsValue() {
        var json = Json.object([:])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        json[[Key(stringValue: "name")]] = .string("test")

        XCTAssertEqual(json, .object(["name": .string("test")]))
    }

    func testSubscriptSet_nestedKeys_setsValue() {
        var json = Json.object([
            "outer": .object([:])
        ])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        json[[Key(stringValue: "outer"), Key(stringValue: "inner")]] = .string("deep")

        XCTAssertEqual(json, .object(["outer": .object(["inner": .string("deep")])]))
    }

    func testSubscriptSet_overwriteExistingValue() {
        var json = Json.object(["name": .string("old")])

        struct Key: CodingKey {
            var stringValue: String
            var intValue: Int? { nil }
            init(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }
        }

        json[[Key(stringValue: "name")]] = .string("new")

        XCTAssertEqual(json, .object(["name": .string("new")]))
    }

}
