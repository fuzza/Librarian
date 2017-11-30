import Foundation
import LibrarianCore
import Commander

#if DEBUG
  let basePath = URL(fileURLWithPath: #file)
    .deletingLastPathComponent() // main.swift
    .deletingLastPathComponent() // Librarian
    .deletingLastPathComponent() // Sources
    .path
#else
  let basePath = FileManager.default.currentDirectoryPath
#endif

let parser = YamlConfigParser(basePath: basePath)

let config = Option("config", "librarian.yml", description: "Path to configuration file")
let integrate = command(config) { config in
  do {
    let project = try parser.parseConfig(at: config)
    try run(manifest: project, workingDir: basePath)
  } catch {
    print(error)
  }
}

integrate.run()


