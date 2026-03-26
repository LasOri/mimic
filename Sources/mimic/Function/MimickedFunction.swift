// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
// SPDX-FileCopyrightText: 2023 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import Foundation

public protocol MimickedFunction: Resettable {

    associatedtype ReturnType

    var name: String! { get }
    var function: ((_ invocationCount: Int, _ params: Params?) throws -> (ReturnType))? { get set }
    var invocationCount: Int { get set }

    func invoke(_ fnName: String, params: Any...) throws -> ReturnType

}

public protocol Resettable: AnyObject {
    func reset()
}
