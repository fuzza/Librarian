import LibrarianCore
import Commander

let parser = YamlConfigParser()

let config = Option("config", "librarian.yml", description: "Path to configuration file")
let integrate = command(config) { config in
  do {
    let project = try parser.parseConfig(at: config)
    run(manifest: project)
  } catch {
    print(error)
  }
}

integrate.run()


