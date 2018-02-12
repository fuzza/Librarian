//
//  FrameworkSearchPath.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj

class FrameworkSearchPathStep: BaseStep, Runnable {
  func run() throws {
    let carthageSearchPath = "$(PROJECT_DIR)/Carthage/Build/iOS"
    try pbxproj.projectConfigs()
      .filter {
        !$0.frameworkSearchPaths.contains(carthageSearchPath)
      }.forEach {
        $0.frameworkSearchPaths.append(carthageSearchPath)
    }
  }
}
