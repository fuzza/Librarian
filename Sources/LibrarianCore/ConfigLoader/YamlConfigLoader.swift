//
//  YamlConfigLoader.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/28/17.
//

import Foundation
import PathKit

public class YamlConfigLoader {
  public required init() {}
}

extension YamlConfigLoader: ConfigLoader {
  public func loadConfig(_ path: String) throws -> String {
    let absolute = Path(path)
    assert(absolute.isAbsolute, "Config loader expects absolute path, got relative \(path)")
    
    guard absolute.exists else {
      throw ConfigLoaderErrors.noFile(path)
    }
    
    guard let type = absolute.`extension`, type == "yml" else {
      throw ConfigLoaderErrors.invalidFile(path)
    }
    
    do {
      return try absolute.read()
    } catch {
      throw ConfigLoaderErrors.readingError(path, error.localizedDescription)
    }
  }
}
