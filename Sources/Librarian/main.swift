import LibrarianCore
import Foundation

let manifest = Project(
  name: "Sample.xcodeproj",
  targets: [
    Target(
      name: "Sample",
      dependencies: [
        .carthage("RxSwift"),
        .carthage("RxCocoa")
      ]),
    Target(
      name: "SampleTests",
      dependencies: [
        .carthage("RxSwift"),
        .carthage("RxCocoa"),
        .carthage("RxTest"),
        .carthage("RxBlocking")
      ])
  ]
)

run(manifest: manifest)


