import Foundation
import xcproj
import PathKit

public func run(manifest: Project, workingDir: String) throws {
  let projectPath: Path = Path(workingDir) + manifest.project
  
  let carthageRelativePath: Path = "Carthage/Build/iOS"
  
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
  let frameworksGroup =
    pbxproj.findGroup(frameworksGroupName, parent: rootGroup) ??
    pbxproj.createGroup(frameworksGroupName, addTo: rootGroup)

  
  // Add file references to frameworks, add build files, attach to framework group
  
  let linkedFrameworks = manifest.resolveAllDependencies()
    .map { add($0, to: frameworksGroup, pbxproj: pbxproj) }
  
  // SHELL SCRIPT RUN PHASE
    
  pbxproj.objects.nativeTargets
    .map { (_, value) in value }
    .forEach { target in
      let targetModel = manifest.target(target.name)!
      let dependencies = manifest.resolveDependencies(for: targetModel).map { $0.asString }
      let inputPaths = dependencies.map { inputFolder + $0 }
      let outputPaths = dependencies.map { outputFolder + $0 }

      let reference = pbxproj.generateUUID(for: PBXShellScriptBuildPhase.self)
      let scriptPhase = PBXShellScriptBuildPhase(reference: reference,
                                                 name: "Integrator",
                                                 inputPaths: inputPaths,
                                                 outputPaths: outputPaths,
                                                 shellScript: scriptBody)

      pbxproj.objects.addObject(scriptPhase)
      target.buildPhases.append(reference)

      // Link binary with libraries
      
      /*
       Add PBXFrameworksBuildPhase

       isa = PBXFrameworksBuildPhase;
       buildActionMask = 2147483647;
       files = (
       6FD7C34D1FC8BA2800971D97 /* RxCocoa.framework in Frameworks */,
       );
       runOnlyForDeploymentPostprocessing = 0;

       */

      let frameworksBuildPhase = target.buildPhases
        .flatMap { pbxproj.objects.frameworksBuildPhases[$0] }
        .first!

      linkedFrameworks
        .filter { dependencies.contains($0.name) }
        .forEach { frameworksBuildPhase.files.append($0.buildFileUid) }
  }
  
  try! projectFile.write(path: projectPath, override: true)
}

func add(_ dependency: Dependency, to group: PBXGroup, pbxproj: PBXProj) -> LinkedFramework {
  let name = dependency.asString
  let path = "Carthage/Build/iOS"
  
  let file = pbxproj.findReference(name, parent: group) ??
    pbxproj.addFramework(name, in: group, path: Path(path))
  
  let buildFile = pbxproj.findBuildFile(for: file) ??
    pbxproj.addBuildFile(for: file)
  
  return LinkedFramework(name: name, fileReferenceUid: file.reference, buildFileUid: buildFile.reference)
}
