// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MimicMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FakeableMacro.self,
    ]
}
