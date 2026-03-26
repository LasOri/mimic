// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2023 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import Foundation

public struct NotNilMatcher: Matcher, Sendable {
    
    public let value: () = ()
    
    public func evaluate<Argument>(arg: Argument) throws {
        let isNil: Bool = {
            let mirror = Mirror(reflecting: arg)
            if mirror.displayStyle == .optional {
                return mirror.children.isEmpty
            }
            return false
        }()
        if isNil {
            throw MimicError.argumentMismatch(message: "Argument must not be `nil`, but it was `nil`.")
        }
    }
    
}
