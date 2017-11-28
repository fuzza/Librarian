//
//  ConfigParser.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/28/17.
//

import Foundation
import Yaml

public class YamlConfigParser {
  
  private let loader: ConfigLoader
  
  public init(loader: ConfigLoader = YamlConfigLoader()) {
    self.loader = loader
  }
  
  public func parseConfig(at path: String) throws -> Project {
    let configBody = try loader.loadConfig(path)
    print(configBody)
    let yaml = try Yaml.load(configBody)
    print(yaml)
    
    return try Project(yaml: yaml)
  }
}

enum ConfigParserErrors: Error {
  case missingKey(String)
  case unknownDependency(String)
}

extension Project {
  init(yaml: Yaml) throws {
    guard let name = yaml["project"].string else { throw ConfigParserErrors.missingKey("name") }
    guard let targets = yaml["targets"].array else { throw ConfigParserErrors.missingKey("targets") }
    
    self.name = name
    self.targets = try targets.map { try Target(yaml: $0) }
  }
}

extension Target {
  init(yaml: Yaml) throws {
    guard let name = yaml["name"].string else { throw ConfigParserErrors.missingKey("name") }
    guard let dependencies = yaml["dependencies"].array else { throw ConfigParserErrors.missingKey("dependencies") }
    
    self.name = name
    self.dependencies = try dependencies.map { try Dependency(yaml: $0) }
  }
}

extension Dependency {
  init(yaml: Yaml) throws {
    guard let type = yaml["type"].string else { throw ConfigParserErrors.missingKey("type") }
    guard let name = yaml["name"].string else { throw ConfigParserErrors.missingKey("name") }
    switch type {
    case "carthage":
      self = .carthage(name)
    default:
      throw ConfigParserErrors.unknownDependency(type)
    }
  }
}
