//
//  CreateFrameworkGroup.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj

class FrameworkGroupCreateStep: BaseStep, Runnable {
  enum Errors: Error {
    case groupNotCreated(name: String)
  }
  
  func run() throws -> ObjectReference<PBXGroup> {
    guard let group = pbxproj.objects.addGroup(named: "Librarian",
                                               to: pbxproj.rootGroup,
                                               options: [GroupAddingOptions(rawValue: 1 << 0)]).first else {
      throw Errors.groupNotCreated(name: "Librarian")
    }
    return group
  }
}
