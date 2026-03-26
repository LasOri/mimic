// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import SwiftSyntax
import SwiftSyntaxMacros

public struct FakeableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
            throw FakeableMacroError.notAProtocol
        }

        let parsed = ProtocolParser.parse(protocolDecl)
        let mockClass = MockClassBuilder.build(from: parsed)

        return [mockClass]
    }
}

enum FakeableMacroError: Error, CustomStringConvertible {
    case notAProtocol

    var description: String {
        switch self {
        case .notAProtocol:
            return "@Fakeable can only be applied to protocols"
        }
    }
}
