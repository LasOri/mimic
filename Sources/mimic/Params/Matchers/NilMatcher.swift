// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2023 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import Foundation

public struct NilMatcher: Matcher, Sendable {
    
    public let value: () = ()
    
    public func evaluate<Argument>(arg: Argument) throws {
        let mirror = Mirror(reflecting: arg)
        if mirror.displayStyle == .optional {
            if let (_, value) = mirror.children.first {
                throw MimicError.argumentMismatch(message: "Expected argument is `nil`, but was: `\(value)`")
            }
        } else {
            throw MimicError.argumentMismatch(message: "Expected argument is `nil`, but was: `\(arg)`")
        }
    }
    
}
