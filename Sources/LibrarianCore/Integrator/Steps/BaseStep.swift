//
//  Step.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj

protocol Runnable {
  associatedtype Result
  func run() throws -> Result
}

class BaseStep {
  let pbxproj: PBXProj
  
  init(pbxproj: PBXProj) {
    self.pbxproj = pbxproj
  }
}
