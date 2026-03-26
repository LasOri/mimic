// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2023 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import Foundation

public struct Arg {
    
    public static let `any` = AnyMatcher()

    public static let `nil` = NilMatcher()

    public static let notNil = NotNilMatcher()
    
    public static func eq<ValueType>(_ value: ValueType) -> EqMatcher<ValueType> where ValueType: Equatable {
        return EqMatcher(value: value)
    }
    
    public static func invokeClosure<ClosureType>(_ closure: @escaping (ClosureType) -> ()) -> ClosureMatcher<ClosureType> {
        return ClosureMatcher(value: closure )
    }

    public static func captor<T>() -> ArgumentCaptor<T> {
        return ArgumentCaptor<T>()
    }

}
