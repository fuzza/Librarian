//
//  ConfigParser.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/28/17.
//

import Foundation
import Yams
import PathKit

public class YamlConfigParser {
  
  private let loader: ConfigLoader
  private let basePath: Path
  public init(loader: ConfigLoader = YamlConfigLoader(),
              basePath: String = FileManager.default.currentDirectoryPath) {
    self.loader = loader
    self.basePath = Path(basePath)
  }
  
  public func parseConfig(at path: String) throws -> Project {
    let configPath = basePath + path
    let configBody = try loader.loadConfig(configPath.string)
    let decoder = YAMLDecoder()
    return try decoder.decode(from: configBody);
  }
}
