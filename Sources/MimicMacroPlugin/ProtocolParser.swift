// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import SwiftSyntax

struct ParsedProtocol {
    let name: String
    let methods: [ParsedMethod]
    let properties: [ParsedProperty]
}

struct ParsedMethod {
    let name: String
    let parameters: [ParsedParameter]
    let returnType: String?
    let isAsync: Bool
    let isThrowing: Bool
    let fnPropertyName: String
}

struct ParsedParameter {
    let firstName: String?
    let secondName: String?
    let type: String
    let isOptional: Bool
    let isClosure: Bool
    let isEscaping: Bool

    var effectiveLabel: String {
        (firstName == "_" ? nil : firstName) ?? secondName ?? "_"
    }

    var effectiveName: String {
        secondName ?? firstName ?? "_"
    }
}

struct ParsedProperty {
    let name: String
    let type: String
    let hasGetter: Bool
    let hasSetter: Bool
    let fnGetterName: String
    let fnSetterName: String?
}

enum ProtocolParser {

    static func parse(_ protocolDecl: ProtocolDeclSyntax) -> ParsedProtocol {
        var methods: [ParsedMethod] = []
        var properties: [ParsedProperty] = []

        for member in protocolDecl.memberBlock.members {
            if let funcDecl = member.decl.as(FunctionDeclSyntax.self) {
                methods.append(parseMethod(funcDecl))
            } else if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                if let prop = parseProperty(varDecl) {
                    properties.append(prop)
                }
            }
        }

        return ParsedProtocol(name: protocolDecl.name.text, methods: methods, properties: properties)
    }

    private static func parseMethod(_ funcDecl: FunctionDeclSyntax) -> ParsedMethod {
        let name = funcDecl.name.text
        let parameters = funcDecl.signature.parameterClause.parameters.map(parseParameter)
        let returnType = funcDecl.signature.returnClause.map { $0.type.trimmedDescription }
        let effectSpec = funcDecl.signature.effectSpecifiers

        return ParsedMethod(
            name: name,
            parameters: parameters,
            returnType: returnType,
            isAsync: effectSpec?.asyncSpecifier != nil,
            isThrowing: effectSpec?.throwsClause != nil,
            fnPropertyName: fnName(from: name)
        )
    }

    private static func parseParameter(_ param: FunctionParameterSyntax) -> ParsedParameter {
        ParsedParameter(
            firstName: param.firstName.text,
            secondName: param.secondName?.text,
            type: param.type.trimmedDescription,
            isOptional: param.type.is(OptionalTypeSyntax.self)
                || param.type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self),
            isClosure: isFunctionType(param.type),
            isEscaping: hasEscapingAttribute(param.type)
        )
    }

    private static func parseProperty(_ varDecl: VariableDeclSyntax) -> ParsedProperty? {
        guard let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation else {
            return nil
        }

        let name = pattern.identifier.text
        let (hasGetter, hasSetter) = accessors(from: binding)
        let capitalizedName = name.prefix(1).uppercased() + name.dropFirst()

        return ParsedProperty(
            name: name,
            type: typeAnnotation.type.trimmedDescription,
            hasGetter: hasGetter,
            hasSetter: hasSetter,
            fnGetterName: "fn\(capitalizedName)Getter",
            fnSetterName: hasSetter ? "fn\(capitalizedName)Setter" : nil
        )
    }

    private static func accessors(from binding: PatternBindingSyntax) -> (hasGetter: Bool, hasSetter: Bool) {
        guard let accessorBlock = binding.accessorBlock else {
            return (true, false)
        }
        switch accessorBlock.accessors {
        case .accessors(let list):
            let texts = list.map { $0.accessorSpecifier.text }
            return (texts.contains("get"), texts.contains("set"))
        case .getter:
            return (true, false)
        }
    }

    private static func fnName(from methodName: String) -> String {
        "fn\(methodName.prefix(1).uppercased())\(methodName.dropFirst())"
    }

    private static func isFunctionType(_ type: TypeSyntax) -> Bool {
        if type.is(FunctionTypeSyntax.self) { return true }
        if let attributed = type.as(AttributedTypeSyntax.self) {
            return isFunctionType(attributed.baseType)
        }
        return false
    }

    private static func hasEscapingAttribute(_ type: TypeSyntax) -> Bool {
        guard let attributed = type.as(AttributedTypeSyntax.self) else { return false }
        return attributed.attributes.contains { attr in
            attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "escaping"
        }
    }
}
