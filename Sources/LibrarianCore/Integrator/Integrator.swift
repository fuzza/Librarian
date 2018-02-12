//
//  Integrator.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 2/12/18.
//

import Foundation
import xcproj
import PathKit

class Integrator {
  let pbxproj: PBXProj
  let sourcePath: Path
  let manifest: Project
  
  init(manifest: Project,
       pbxproj: PBXProj,
       sourcePath: Path) {
    self.manifest = manifest
    self.pbxproj = pbxproj
    self.sourcePath = sourcePath
  }
  
  func integrate() throws {
    try FrameworkSearchPathStep(pbxproj: pbxproj).run()
    let frameworksGroup = try FrameworkGroupCreateStep(pbxproj: pbxproj).run().object
    
    try manifest.targets.forEach { target in
      let nativeTarget = pbxproj.objects.nativeTargets.values.filter { $0.name == target.name }.first!
      try target.dependencies.map { dependency -> ObjectReference<PBXFileReference> in
        return try CreateFileReference(pbxproj: pbxproj,
                                       group: frameworksGroup,
                                       sourcePath: sourcePath,
                                       dependency: dependency).run()
        }.map { fileRef -> ObjectReference<PBXFileReference> in
          return try CopyLibrariesScript(pbxproj: pbxproj,
                                         fileRef: fileRef,
                                         target: nativeTarget).run()
        }.forEach { fileReference in
          _ = try CreateBuildFileReference(pbxproj: pbxproj,
                                           target: nativeTarget,
                                           fileRef: fileReference).run()
      }
    }
  }
}
