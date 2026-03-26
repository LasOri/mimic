// SPDX-FileCopyrightText: 2024 Emarsys-Technologies Kft.
//
// SPDX-License-Identifier: Apache-2.0

@attached(peer, names: prefixed(Fake))
public macro Fakeable() = #externalMacro(module: "MimicMacroPlugin", type: "FakeableMacro")
