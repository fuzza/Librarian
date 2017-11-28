//
//  ConfigLoader.swift
//  LibrarianPackageDescription
//
//  Created by Alex Fayzullov on 11/28/17.
//

import Foundation
import PathKit
import Yaml

public class ConfigLoader {
    public static func loadConfig(_ path: String) throws -> Project {
        let absolute = Path.current + path
        
        guard absolute.exists else {
             throw ConfigLoaderErrors.noFile(path)
        }
        
        guard let type = absolute.`extension`, type != "yml" else {
            throw ConfigLoaderErrors.invalidFile(path)
        }
        
        throw ConfigLoaderErrors.decodingError("not implemented")
    }
}


