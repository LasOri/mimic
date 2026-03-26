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
        let name = protocolDecl.name.text
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

        return ParsedProtocol(name: name, methods: methods, properties: properties)
    }

    private static func parseMethod(_ funcDecl: FunctionDeclSyntax) -> ParsedMethod {
        let name = funcDecl.name.text

        let parameters = funcDecl.signature.parameterClause.parameters.map { param -> ParsedParameter in
            let firstName = param.firstName.text
            let secondName = param.secondName?.text
            let typeString = param.type.trimmedDescription
            let isOptional = param.type.is(OptionalTypeSyntax.self)
                || param.type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self)
            let isClosure = isFunctionType(param.type)
            let isEscaping = hasEscapingAttribute(param.type)

            return ParsedParameter(
                firstName: firstName,
                secondName: secondName,
                type: typeString,
                isOptional: isOptional,
                isClosure: isClosure,
                isEscaping: isEscaping
            )
        }

        let returnType = funcDecl.signature.returnClause.map { clause in
            clause.type.trimmedDescription
        }

        let effectSpec = funcDecl.signature.effectSpecifiers
        let isAsync = effectSpec?.asyncSpecifier != nil
        let isThrowing = effectSpec?.throwsClause != nil

        let fnPropertyName = "fn\(name.prefix(1).uppercased())\(name.dropFirst())"

        return ParsedMethod(
            name: name,
            parameters: parameters,
            returnType: returnType,
            isAsync: isAsync,
            isThrowing: isThrowing,
            fnPropertyName: fnPropertyName
        )
    }

    private static func parseProperty(_ varDecl: VariableDeclSyntax) -> ParsedProperty? {
        guard let binding = varDecl.bindings.first,
              let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
              let typeAnnotation = binding.typeAnnotation else {
            return nil
        }

        let name = pattern.identifier.text
        let type = typeAnnotation.type.trimmedDescription

        var hasGetter = false
        var hasSetter = false

        if let accessorBlock = binding.accessorBlock {
            switch accessorBlock.accessors {
            case .accessors(let accessorList):
                for accessor in accessorList {
                    if accessor.accessorSpecifier.text == "get" {
                        hasGetter = true
                    } else if accessor.accessorSpecifier.text == "set" {
                        hasSetter = true
                    }
                }
            case .getter:
                hasGetter = true
            }
        } else {
            hasGetter = true
        }

        let capitalizedName = name.prefix(1).uppercased() + name.dropFirst()
        let fnGetterName = "fn\(capitalizedName)Getter"
        let fnSetterName = hasSetter ? "fn\(capitalizedName)Setter" : nil

        return ParsedProperty(
            name: name,
            type: type,
            hasGetter: hasGetter,
            hasSetter: hasSetter,
            fnGetterName: fnGetterName,
            fnSetterName: fnSetterName
        )
    }

    private static func isFunctionType(_ type: TypeSyntax) -> Bool {
        if type.is(FunctionTypeSyntax.self) {
            return true
        }
        if let attributed = type.as(AttributedTypeSyntax.self) {
            return isFunctionType(attributed.baseType)
        }
        return false
    }

    private static func hasEscapingAttribute(_ type: TypeSyntax) -> Bool {
        if let attributed = type.as(AttributedTypeSyntax.self) {
            return attributed.attributes.contains { attr in
                attr.as(AttributeSyntax.self)?.attributeName.trimmedDescription == "escaping"
            }
        }
        return false
    }
}
