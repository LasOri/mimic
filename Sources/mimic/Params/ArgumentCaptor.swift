// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import Foundation

public class ArgumentCaptor<T> {

    private let matcher = CapturingMatcher<T>()

    public init() {}

    public func capture() -> CapturingMatcher<T> {
        matcher
    }

    public var values: [T] { matcher.values }
    public var lastValue: T? { matcher.lastValue }
    public var firstValue: T? { matcher.firstValue }

    public func reset() {
        matcher.reset()
    }

}
