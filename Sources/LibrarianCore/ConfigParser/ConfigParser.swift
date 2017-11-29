//
//  ConfigParser.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/28/17.
//

import Foundation
import Yams

public class YamlConfigParser {
  
  private let loader: ConfigLoader
  
  public init(loader: ConfigLoader = YamlConfigLoader()) {
    self.loader = loader
  }
  
  public func parseConfig(at path: String) throws -> Project {
    let configBody = try loader.loadConfig(path)
    let decoder = YAMLDecoder()
    return try decoder.decode(from: configBody);
  }
}
