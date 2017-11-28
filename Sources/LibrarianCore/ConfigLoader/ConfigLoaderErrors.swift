//
//  File.swift
//  LibrarianCore
//
//  Created by Alex Faizullov on 11/28/17.
//

import Foundation

public enum ConfigLoaderErrors: Error {
  case noFile(String)
  case invalidFile(String)
  case readingError(String, String) // path, reason
}

extension ConfigLoaderErrors: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .noFile(path):
      return "Can't find config at path \"\(path)\""
    case let .invalidFile(path):
      return "Config file \"\(path)\" is not a valid .yml config"
    case let .readingError(path, reason):
      return "Can't open config at \"\(path)\": \(reason)"
    }
  }
}

extension ConfigLoaderErrors: AutoEquatable {}
