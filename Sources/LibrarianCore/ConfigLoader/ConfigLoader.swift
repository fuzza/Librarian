//
//  ConfigLoader.swift
//  LibrarianPackageDescription
//
//  Created by Alex Fayzullov on 11/28/17.
//

import Foundation

public protocol ConfigLoader: AutoMockable {
  func loadConfig(_ path: String) throws -> String
}
