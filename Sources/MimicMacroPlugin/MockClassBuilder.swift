// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import SwiftSyntax
import SwiftSyntaxBuilder

enum MockClassBuilder {

    static func build(from parsed: ParsedProtocol) -> DeclSyntax {
        var members: [String] = []
        members.append(contentsOf: fnDeclarations(for: parsed))

        if !parsed.methods.isEmpty || !parsed.properties.isEmpty {
            members.append("")
        }

        members.append(contentsOf: parsed.methods.map(buildMethodImplementation))
        members.append(contentsOf: parsed.properties.map(buildPropertyImplementation))

        let body = members.joined(separator: "\n")
        let source = """
        final class Fake\(parsed.name): \(parsed.name), Mimic {
        \(body)
        }
        """
        return DeclSyntax(stringLiteral: source)
    }

    private static func fnDeclarations(for parsed: ParsedProtocol) -> [String] {
        var declarations: [String] = []
        for method in parsed.methods {
            let returnType = method.returnType ?? "()"
            declarations.append("    public let \(method.fnPropertyName) = Fn<\(returnType)>()")
        }
        for prop in parsed.properties {
            declarations.append("    public let \(prop.fnGetterName) = Fn<\(prop.type)>()")
            if let setterName = prop.fnSetterName {
                declarations.append("    public let \(setterName) = Fn<()>()")
            }
        }
        return declarations
    }

    private static func buildMethodImplementation(_ method: ParsedMethod) -> String {
        let signature = buildSignature(method)
        let body = buildInvokeCall(method)
        return "\(signature) {\n\(body)\n    }"
    }

    private static func buildSignature(_ method: ParsedMethod) -> String {
        let paramList = method.parameters.map { param in
            let label = param.firstName ?? "_"
            if let secondName = param.secondName {
                return "\(label) \(secondName): \(param.type)"
            }
            return "\(label): \(param.type)"
        }.joined(separator: ", ")

        var signature = "    func \(method.name)(\(paramList))"
        if method.isAsync { signature += " async" }
        if method.isThrowing { signature += " throws" }
        if let returnType = method.returnType { signature += " -> \(returnType)" }
        return signature
    }

    private static func buildInvokeCall(_ method: ParsedMethod) -> String {
        let tryKeyword = method.isThrowing ? "try" : "try!"
        let awaitKeyword = method.isAsync ? "await " : ""
        let returnKeyword = method.returnType != nil ? "return " : ""

        let invokeArgs = method.parameters.map { param in
            param.isOptional ? "\(param.effectiveName) as Any" : param.effectiveName
        }

        let invoke: String
        if invokeArgs.isEmpty {
            invoke = "\(method.fnPropertyName).invoke()"
        } else {
            invoke = "\(method.fnPropertyName).invoke(params: \(invokeArgs.joined(separator: ", ")))"
        }

        return "        \(returnKeyword)\(tryKeyword) \(awaitKeyword)\(invoke)"
    }

    private static func buildPropertyImplementation(_ prop: ParsedProperty) -> String {
        guard let setterName = prop.fnSetterName, prop.hasSetter else {
            return """
                var \(prop.name): \(prop.type) {
                    try! \(prop.fnGetterName).invoke()
                }
            """
        }
        return """
            var \(prop.name): \(prop.type) {
                get {
                    try! \(prop.fnGetterName).invoke()
                }
                set {
                    try! \(setterName).invoke(params: newValue)
                }
            }
        """
    }
}
