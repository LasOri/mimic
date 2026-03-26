// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MimicMacroPlugin)
import MimicMacroPlugin

let testMacros: [String: Macro.Type] = [
    "Fakeable": FakeableMacro.self,
]
#endif

final class FakeableTests: XCTestCase {

    // MARK: - Basic method

    func testFakeable_basicMethodWithReturn() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol MyService {
                func fetch() throws -> String
            }
            """,
            expandedSource: """
            protocol MyService {
                func fetch() throws -> String
            }

            final class FakeMyService: MyService, Mimic {
                public let fnFetch = Fn<String>()

                func fetch() throws -> String {
                    return try fnFetch.invoke()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Method with parameters

    func testFakeable_methodWithParameters() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol DataStore {
                func save(id: String, value: Int) throws
            }
            """,
            expandedSource: """
            protocol DataStore {
                func save(id: String, value: Int) throws
            }

            final class FakeDataStore: DataStore, Mimic {
                public let fnSave = Fn<()>()

                func save(id: String, value: Int) throws {
                    try fnSave.invoke(params: id, value)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Async throwing method

    func testFakeable_asyncThrowingMethod() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol NetworkClient {
                func request(url: String) async throws -> Data
            }
            """,
            expandedSource: """
            protocol NetworkClient {
                func request(url: String) async throws -> Data
            }

            final class FakeNetworkClient: NetworkClient, Mimic {
                public let fnRequest = Fn<Data>()

                func request(url: String) async throws -> Data {
                    return try await fnRequest.invoke(params: url)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Void return method

    func testFakeable_voidReturnMethod() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Logger {
                func log(message: String) throws
            }
            """,
            expandedSource: """
            protocol Logger {
                func log(message: String) throws
            }

            final class FakeLogger: Logger, Mimic {
                public let fnLog = Fn<()>()

                func log(message: String) throws {
                    try fnLog.invoke(params: message)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Non-throwing method

    func testFakeable_nonThrowingMethod() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Cache {
                func clear()
            }
            """,
            expandedSource: """
            protocol Cache {
                func clear()
            }

            final class FakeCache: Cache, Mimic {
                public let fnClear = Fn<()>()

                func clear() {
                    try! fnClear.invoke()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Get-only property

    func testFakeable_getOnlyProperty() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Named {
                var name: String { get }
            }
            """,
            expandedSource: """
            protocol Named {
                var name: String { get }
            }

            final class FakeNamed: Named, Mimic {
                public let fnNameGetter = Fn<String>()

                var name: String {
                    try! fnNameGetter.invoke()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Get/set property

    func testFakeable_getSetProperty() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Configurable {
                var isEnabled: Bool { get set }
            }
            """,
            expandedSource: """
            protocol Configurable {
                var isEnabled: Bool { get set }
            }

            final class FakeConfigurable: Configurable, Mimic {
                public let fnIsEnabledGetter = Fn<Bool>()
                public let fnIsEnabledSetter = Fn<()>()

                var isEnabled: Bool {
                    get {
                        try! fnIsEnabledGetter.invoke()
                    }
                    set {
                        try! fnIsEnabledSetter.invoke(params: newValue)
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Multiple methods and properties

    func testFakeable_multipleMembersGenerated() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol UserService {
                var currentUser: String { get }
                func login(username: String, password: String) throws -> Bool
                func logout() throws
            }
            """,
            expandedSource: """
            protocol UserService {
                var currentUser: String { get }
                func login(username: String, password: String) throws -> Bool
                func logout() throws
            }

            final class FakeUserService: UserService, Mimic {
                public let fnLogin = Fn<Bool>()
                public let fnLogout = Fn<()>()
                public let fnCurrentUserGetter = Fn<String>()

                func login(username: String, password: String) throws -> Bool {
                    return try fnLogin.invoke(params: username, password)
                }
                func logout() throws {
                    try fnLogout.invoke()
                }
                var currentUser: String {
                    try! fnCurrentUserGetter.invoke()
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Optional parameter uses as Any

    func testFakeable_optionalParameterCastsToAny() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Finder {
                func find(name: String?) throws -> Int
            }
            """,
            expandedSource: """
            protocol Finder {
                func find(name: String?) throws -> Int
            }

            final class FakeFinder: Finder, Mimic {
                public let fnFind = Fn<Int>()

                func find(name: String?) throws -> Int {
                    return try fnFind.invoke(params: name as Any)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Error: applied to non-protocol

    func testFakeable_appliedToClass_emitsError() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            class NotAProtocol {}
            """,
            expandedSource: """
            class NotAProtocol {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Fakeable can only be applied to protocols", line: 1, column: 1)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - External/internal parameter names

    func testFakeable_externalAndInternalParameterNames() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Transformer {
                func transform(from source: String, to destination: String) throws -> Bool
            }
            """,
            expandedSource: """
            protocol Transformer {
                func transform(from source: String, to destination: String) throws -> Bool
            }

            final class FakeTransformer: Transformer, Mimic {
                public let fnTransform = Fn<Bool>()

                func transform(from source: String, to destination: String) throws -> Bool {
                    return try fnTransform.invoke(params: source, destination)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Underscore label

    func testFakeable_underscoreLabel() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Processor {
                func process(_ value: String) throws -> Int
            }
            """,
            expandedSource: """
            protocol Processor {
                func process(_ value: String) throws -> Int
            }

            final class FakeProcessor: Processor, Mimic {
                public let fnProcess = Fn<Int>()

                func process(_ value: String) throws -> Int {
                    return try fnProcess.invoke(params: value)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Empty protocol

    func testFakeable_emptyProtocol() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Empty {
            }
            """,
            expandedSource: """
            protocol Empty {
            }

            final class FakeEmpty: Empty, Mimic {

            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Optional return type

    func testFakeable_optionalReturnType() throws {
        #if canImport(MimicMacroPlugin)
        assertMacroExpansion(
            """
            @Fakeable
            protocol Lookup {
                func find(key: String) throws -> String?
            }
            """,
            expandedSource: """
            protocol Lookup {
                func find(key: String) throws -> String?
            }

            final class FakeLookup: Lookup, Mimic {
                public let fnFind = Fn<String?>()

                func find(key: String) throws -> String? {
                    return try fnFind.invoke(params: key)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
