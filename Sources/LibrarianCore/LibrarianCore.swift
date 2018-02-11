import Foundation
import xcproj
import PathKit

enum CoreErrors: Error {
  case noFrameworkBuildPhase(String)
}

public func run(manifest: Project, workingDir: String) throws {
  let projectPath: Path = Path(workingDir) + manifest.project
  
  let inputFolder = "$(SRCROOT)/Carthage/Build/iOS/"
  let outputFolder = "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/"
  let scriptBody = "/usr/local/bin/carthage copy-frameworks"
  
  let projectFile = try XcodeProj(path: projectPath)
  let pbxproj = projectFile.pbxproj
  
  // MARK: Integrate framework search paths
  
  let carthageSearchPath = "$(PROJECT_DIR)/Carthage/Build/iOS"
  
  try pbxproj.projectConfigs()
    .filter {
      !$0.frameworkSearchPaths.contains(carthageSearchPath)
    }.forEach {
      $0.frameworkSearchPaths.append(carthageSearchPath)
    }
  
  // Find or create PBXGroup for frameworks in project's root group
  
  let frameworksGroupName = "Frameworks"
  
  let rootGroup = try pbxproj.rootGroup()
  let frameworksGroup = pbxproj.findGroup(frameworksGroupName, parent: rootGroup)
    ?? pbxproj.createGroup(frameworksGroupName, addTo: rootGroup)

  
  // Add file references to frameworks, add build files, attach to framework group
  
  let frameworks = manifest.resolveAllDependencies()
    .map { (dep: Dependency) -> LinkedFramework in add(dep, to: frameworksGroup, pbxproj: pbxproj) }

  let frameworkMap: [String: LinkedFramework] = frameworks.reduce(into: [:]) { dict, framework in
    dict[framework.name] = framework
  }
  
  // Filter targets included to manifest
  
  let targets = pbxproj.objects.nativeTargets.values
    .filter { manifest.contains(target: $0.name) }
  
  // Add copy-framework script to project targets, prepare scripts map
  
  let scriptsMap: [String: PBXShellScriptBuildPhase] = targets.reduce(into: [:]) { dict, target in
    dict[target.name] = pbxproj.findShellScript("Librarian", in: target)
      ?? pbxproj.addShellScript("Librarian", content: scriptBody, in: target)
  }
  
  // Prepare build framework phases map
  let buildPhasesMap: [String: PBXFrameworksBuildPhase] = try targets.reduce(into: [:]) { dict, target in
    guard let phase = pbxproj.findFrameworkPhase(in: target) else {
      throw CoreErrors.noFrameworkBuildPhase(target.name)
    }
    dict[target.name] = phase
  }
  
  // Copy and link binary with framework
  
  manifest.targets.forEach { target in
    target.dependencies.forEach { dependency in

      guard
        let framework = frameworkMap[dependency.asString],
        let shellScript = scriptsMap[target.name],
        let buildPhase = buildPhasesMap[target.name] else {
          // TODO: throw error from here
          return
      }
      
      let frameworkName = framework.name
      
      // Add input path to framework to copy-frameworks script
      let inputPath = inputFolder + frameworkName
      if !shellScript.inputPaths.contains(inputPath) {
        shellScript.inputPaths.append(inputPath)
      }
      
      // Add output path to framework to copy-frameworks script
      let outputPath = outputFolder + frameworkName
      if !shellScript.outputPaths.contains(outputPath) {
        shellScript.outputPaths.append(outputPath)
      }
      
      // Add build file uid of framework to `Link binary with libraries`
      let buildFileUid = framework.buildFileUid
      if !buildPhase.files.contains(buildFileUid) {
        buildPhase.files.append(buildFileUid)
      }
    }
  }

  try projectFile.writePBXProj(path: projectPath, override: true)
}

func add(_ dependency: Dependency, to group: PBXGroup, pbxproj: PBXProj) -> LinkedFramework {
  let name = dependency.asString
  let path = "Carthage/Build/iOS"
  
  let fileReference = pbxproj.findReference(name, parent: group) ??
    pbxproj.addFramework(name, in: group, path: Path(path))
  
  let buildFileReference = pbxproj.findBuildFile(for: fileReference) ??
    pbxproj.addBuildFile(for: fileReference)
  
  return LinkedFramework(name: name, fileReferenceUid: fileReference, buildFileUid: buildFileReference)
}
