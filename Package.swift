// swift-tools-version: 6.0
// NOTE: This project builds via Scripts/build.sh using swiftc directly.
// SPM is not used for building due to CLT toolchain issues.
// This Package.swift is kept for reference/IDE support only.

import PackageDescription

let package = Package(
    name: "SpaceNotes",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "SpaceNotes",
            path: "Sources/SpaceNotes"
        ),
    ]
)
