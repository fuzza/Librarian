import LibrarianCore
import Commander

let config = Option("config", "librarian.yml", description: "The number of times to print.")
let integrate = command(config) { config in
   _ = try ConfigLoader.loadConfig(config)
    
}

integrate.run()

//let manifest = Project(
//  name: "Sample.xcodeproj",
//  targets: [
//    Target(
//      name: "Sample",
//      dependencies: [
//        .carthage("RxSwift"),
//        .carthage("RxCocoa")
//      ]),
//    Target(
//      name: "SampleTests",
//      dependencies: [
//        .carthage("RxSwift"),
//        .carthage("RxCocoa"),
//        .carthage("RxTest"),
//        .carthage("RxBlocking")
//      ])
//  ]
//)
//
//run(manifest: manifest)


