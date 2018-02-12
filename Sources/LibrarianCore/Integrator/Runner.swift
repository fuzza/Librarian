import Foundation
import xcproj
import PathKit

public func run(manifest: Project, workingDir: String) throws {
  let projectPath: Path = Path(workingDir) + manifest.project
  let sourcePath = Path(components: projectPath.components.dropLast())
  
  let projectFile = try XcodeProj(path: projectPath)
  
  try Integrator(manifest: manifest, pbxproj: projectFile.pbxproj, sourcePath: sourcePath).integrate()
  
  try projectFile.writePBXProj(path: projectPath, override: true)
}
