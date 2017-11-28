//
//  ConfigLoader.swift
//  LibrarianPackageDescription
//
//  Created by Alex Fayzullov on 11/28/17.
//

import Foundation
import PathKit
import Yaml

public enum ConfigLoaderError: Error, CustomStringConvertible {
    case noFile(String)
    case invalidFile(String)
    case decodingError(String)
    
    public var description: String {
        switch self {
        case let .noFile(path):
            return "Can't find config at path \"\(path)\""
        case let .invalidFile(path):
            return "Config file \"\(path)\" is not a valid .yml config"
        case let .decodingError(error):
            return "Can't parse config file: \"\(error)\""
        }
    }
}

public class ConfigLoader {
    public static func loadConfig(_ path: String) throws -> Project {
        let absolute = Path.current + path
        
        guard absolute.exists else {
             throw ConfigLoaderError.noFile(path)
        }
        
        guard let type = absolute.`extension`, type != "yml" else {
            throw ConfigLoaderError.invalidFile(path)
        }
        
        throw ConfigLoaderError.decodingError("not implemented")
    }
}
