//
//  LinkedFramework.swift
//  LibrarianCore
//
//  Created by Alex Faizullov on 11/25/17.
//

import Foundation

struct LinkedFramework {
  var name: String
  var fileReferenceUid: String
  var buildFileUid: String
  
  var fileName: String {
    return name + ".framework"
  }
}
