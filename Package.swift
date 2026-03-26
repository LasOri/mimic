// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// SPDX-FileCopyrightText: 2023 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0


import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "mimic",
    platforms: [
        .macOS(.v13),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "mimic",
            targets: ["mimic"]),
        .library(
            name: "MimicMacros",
            targets: ["MimicMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0-latest"),
    ],
    targets: [
        .target(
            name: "mimic",
            dependencies: []),
        .macro(
            name: "MimicMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "MimicMacros",
            dependencies: ["MimicMacroPlugin", "mimic"]
        ),
        .testTarget(
            name: "mimicTests",
            dependencies: ["mimic"]),
        .testTarget(
            name: "MimicMacroTests",
            dependencies: [
                "MimicMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
