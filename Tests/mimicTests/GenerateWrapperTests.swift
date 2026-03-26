// Copyright © 2024. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import mimic

final class GenerateWrapperTests: XCTestCase {

    @Generate(encodables: SomeEnum.case2)
    var basicStruct: SomeStruct

    func testGenerate_basicGeneration_producesValidInstance() {
        XCTAssertNotNil(basicStruct)
        XCTAssertFalse(basicStruct.text.isEmpty)
    }

    @Generate([
        \SomeStruct.text: "predefined",
        \SomeStruct.num: 42
    ], encodables: SomeEnum.case2)
    var predefinedStruct: SomeStruct

    func testGenerate_withPredefinedValues_appliesValues() {
        XCTAssertEqual(predefinedStruct.text, "predefined")
        XCTAssertEqual(predefinedStruct.num, 42)
    }

    @Generate()
    var simpleStruct: SomeSubStruct

    func testGenerate_simpleStructWithoutEncodables() {
        XCTAssertNotNil(simpleStruct)
        XCTAssertFalse(simpleStruct.text.isEmpty)
    }

    @Generate()
    var settableStruct: SomeSubStruct

    func testGenerate_setter_isOverriddenByNextGet() {
        let custom = SomeSubStruct(text: "custom")
        settableStruct = custom

        XCTAssertNotEqual(settableStruct.text, "custom")
    }

    @Generate()
    var regeneratedStruct: SomeSubStruct

    func testGenerate_eachAccess_producesNewValue() {
        let first = regeneratedStruct.text
        let second = regeneratedStruct.text

        XCTAssertNotEqual(first, second, "Each access should regenerate the instance")
    }

    @Generate(encodables: SomeEnum.case1("text", 1), SomeEnum.case2)
    var multiEncodableStruct: SomeStruct

    func testGenerate_withMultipleEncodables() {
        XCTAssertNotNil(multiEncodableStruct)
    }

    @Generate()
    var innerStruct: InnerStruct

    func testGenerate_nestedStruct() {
        XCTAssertNotNil(innerStruct)
        XCTAssertFalse(innerStruct.subStruct.text.isEmpty)
    }

    @Generate([\SomeSubStruct.text: "specific"])
    var predefinedOnly: SomeSubStruct

    func testGenerate_predefinedWithoutEncodables() {
        XCTAssertEqual(predefinedOnly.text, "specific")
    }
}
