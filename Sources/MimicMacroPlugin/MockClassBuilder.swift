// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import SwiftSyntax
import SwiftSyntaxBuilder

enum MockClassBuilder {

    static func build(from parsed: ParsedProtocol) -> DeclSyntax {
        let className = "Fake\(parsed.name)"
        var members: [String] = []

        // Fn properties for methods
        for method in parsed.methods {
            let returnType = method.returnType ?? "()"
            members.append("    public let \(method.fnPropertyName) = Fn<\(returnType)>()")
        }

        // Fn properties for properties
        for prop in parsed.properties {
            members.append("    public let \(prop.fnGetterName) = Fn<\(prop.type)>()")
            if let setterName = prop.fnSetterName {
                members.append("    public let \(setterName) = Fn<()>()")
            }
        }

        if !parsed.methods.isEmpty || !parsed.properties.isEmpty {
            members.append("")
        }

        // Method implementations
        for method in parsed.methods {
            members.append(buildMethodImplementation(method))
        }

        // Property implementations
        for prop in parsed.properties {
            members.append(buildPropertyImplementation(prop))
        }

        let membersStr = members.joined(separator: "\n")

        let source = """
        final class \(className): \(parsed.name), Mimic {
        \(membersStr)
        }
        """

        return DeclSyntax(stringLiteral: source)
    }

    private static func buildMethodImplementation(_ method: ParsedMethod) -> String {
        var parts: [String] = []

        // Build parameter list
        let paramList = method.parameters.map { param -> String in
            let label = param.firstName ?? "_"
            if let secondName = param.secondName {
                return "\(label) \(secondName): \(param.type)"
            } else {
                return "\(label): \(param.type)"
            }
        }.joined(separator: ", ")

        // Build function signature
        var signature = "    func \(method.name)(\(paramList))"
        if method.isAsync {
            signature += " async"
        }
        if method.isThrowing {
            signature += " throws"
        }
        if let returnType = method.returnType {
            signature += " -> \(returnType)"
        }

        parts.append(signature + " {")

        // Build invoke call
        let invokeParams = method.parameters.map { param -> String in
            let name = param.effectiveName
            if param.isOptional {
                return "\(name) as Any"
            }
            return name
        }

        let tryKeyword = method.isThrowing ? "try" : "try!"
        let awaitKeyword = method.isAsync ? "await " : ""

        if invokeParams.isEmpty {
            if method.returnType != nil {
                parts.append("        return \(tryKeyword) \(awaitKeyword)\(method.fnPropertyName).invoke()")
            } else {
                parts.append("        \(tryKeyword) \(awaitKeyword)\(method.fnPropertyName).invoke()")
            }
        } else {
            let paramsStr = invokeParams.joined(separator: ", ")
            if method.returnType != nil {
                parts.append("        return \(tryKeyword) \(awaitKeyword)\(method.fnPropertyName).invoke(params: \(paramsStr))")
            } else {
                parts.append("        \(tryKeyword) \(awaitKeyword)\(method.fnPropertyName).invoke(params: \(paramsStr))")
            }
        }

        parts.append("    }")
        return parts.joined(separator: "\n")
    }

    private static func buildPropertyImplementation(_ prop: ParsedProperty) -> String {
        var parts: [String] = []
        parts.append("    var \(prop.name): \(prop.type) {")

        if prop.hasSetter {
            parts.append("        get {")
            parts.append("            try! \(prop.fnGetterName).invoke()")
            parts.append("        }")
            parts.append("        set {")
            parts.append("            try! \(prop.fnSetterName!).invoke(params: newValue)")
            parts.append("        }")
        } else {
            parts.append("        try! \(prop.fnGetterName).invoke()")
        }

        parts.append("    }")
        return parts.joined(separator: "\n")
    }
}
