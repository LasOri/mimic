// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import Foundation

public class CapturingMatcher<T>: Matcher {

    public let value: () = ()

    private var capturedValues: [T] = []

    public var values: [T] { capturedValues }
    public var lastValue: T? { capturedValues.last }
    public var firstValue: T? { capturedValues.first }

    public func evaluate<Argument>(arg: Argument) throws {
        guard let typedArg = arg as? T else {
            assertionFailure("Expected type: \(T.self) doesn't match with value type: \(Argument.self)")
            return
        }
        capturedValues.append(typedArg)
    }

    public func reset() {
        capturedValues = []
    }

}
