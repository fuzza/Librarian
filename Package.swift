// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Librarian",
  dependencies: [
    .package(url: "https://github.com/xcodeswift/xcproj.git", from: "1.0.0")
  ],
  targets: [
    .target(
      name: "Librarian",
      dependencies: ["LibrarianCore"]),
    .target(
      name: "LibrarianCore",
      dependencies: ["xcproj"]),
    .testTarget(
      name: "LibrarianTests",
      dependencies: ["LibrarianCore", "xcproj"])
  ]
)
