// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription



let package = Package(
  name: "Librarian",
  dependencies: [
    .package(url: "https://github.com/fuzza/xcproj.git", .branch("fix/adding-framework-files")),
    .package(url: "https://github.com/jpsim/Yams.git", from: "0.5.0"),
    .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.8.0")),
    .package(url: "https://github.com/Quick/Nimble.git", .upToNextMinor(from: "7.0.0")),
  ],
  targets: [
    .target(
      name: "Librarian",
      dependencies: ["LibrarianCore", "Commander"]),
    .target(
      name: "LibrarianCore",
      dependencies: ["xcproj", "Yams"]),
    .testTarget(
      name: "LibrarianTests",
      dependencies: ["LibrarianCore", "xcproj", "Yams", "Nimble"])
  ]
)
