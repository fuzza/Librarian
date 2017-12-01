//
//  LookupTests.swift
//  LibrarianCore
//
//  Created by Alex Fayzullov on 11/30/17.
//

import XCTest
import xcproj
import Nimble

@testable import LibrarianCore

let fixturesPath = URL(fileURLWithPath: #file).deletingLastPathComponent().path + "/Fixtures/"

class PBXProjTests: XCTestCase {
  
  // MARK: Config Lookup
  
  func test_projectConfigs_returnsArrayOfConfigurations() {
    let sut = makeSut()
    
    let configs: [XCBuildConfiguration]? = try? sut.projectConfigs()
    
    configs.assertFlatMap {
      XCTAssertEqual($0.count, 2)
      XCTAssertEqual($0.first?.name, "Debug")
      XCTAssertEqual($0.first?.reference, "6FD7C30D1FC8982000971D97")
      XCTAssertEqual($0.last?.name, "Release")
      XCTAssertEqual($0.last?.reference, "6FD7C30E1FC8982000971D97")
    }
  }
  
  // MARK: Groups Lookup
  
  func test_rootGroup_returnProjectMainGroup() {
    let sut = makeSut()
    
    let root = try? sut.rootGroup()
    
    root.assertFlatMap {
      XCTAssertEqual($0.reference, "6FD7C2E91FC8982000971D97")
      XCTAssertEqual($0.children, ["6FD7C2F41FC8982000971D97",
                                   "6FD7C3091FC8982000971D97",
                                   "6FD7C2F31FC8982000971D97"])
    }
  }
  
  func test_findGroup_returnsExistingFolderReferenceByPath() {
    let sut = makeSut()
    
    let root = try? sut.rootGroup()
    
    root
      .assertFlatMap { sut.findGroup("Sample", parent: $0) }
      .assertFlatMap {
        XCTAssertEqual($0.path, "Sample")
        XCTAssertEqual($0.reference, "6FD7C2F41FC8982000971D97")
    }
  }
    
  func test_findGroup_returnsExistingGroupByName() {
    let sut = makeSut()
    
    let root = try! sut.rootGroup()
    
    sut.findGroup("Products", parent: root).assertFlatMap {
        XCTAssertEqual($0.name, "Products")
        XCTAssertEqual($0.reference, "6FD7C2F31FC8982000971D97")
    }
  }
  
  func test_findGroup_nonExisting_returnsNil() {
    let sut = makeSut()
    
    let root = try! sut.rootGroup()
    
    XCTAssertNil(sut.findGroup("NonExistingGroup", parent: root))
  }
  
  func test_createGroup_addsGroupAndAttachesToParent() {
    let sut = makeSut()
    
    let root = try! sut.rootGroup()
    let group = sut.createGroup("Frameworks", addTo: root)
    
    XCTAssertEqual(sut.objects.groups[group.reference], group)
    XCTAssertTrue(root.children.contains(group.reference))
  }
  
  // MARK: Frameworks lookup
  
  func test_findReference_nonExisting_returnsNil() {
    let sut = makeSut()
    
    let root = try! sut.rootGroup()
    
    XCTAssertNil(sut.findReference("Test.framework", parent: root))
  }
  
  func test_findReference_returnsReference() {
    let sut = makeSut()
    
    let root = try! sut.rootGroup()
    
    let reference = PBXFileReference(reference: "2222", name: "Test")
    root.children.append("2222")
    sut.objects.addObject(reference)
    
    XCTAssertEqual(sut.findReference("Test", parent: root), reference)
  }
  
  func test_addFramework_createsNewFrameworkReference() {
    let sut = makeSut()
    
    let root = try! sut.rootGroup()
    
    let framework = sut.addFramework("Test", in: root, path: "/var/lib")
    
    XCTAssertEqual(framework.name, "Test")
    XCTAssertEqual(framework.path, "/var/lib/Test")
    XCTAssertEqual(framework.lastKnownFileType, "wrapper.framework")
    XCTAssertEqual(framework.sourceTree, .group)
    
    XCTAssertTrue(root.children.contains(framework.reference))
    XCTAssertEqual(sut.objects.fileReferences[framework.reference], framework)
  }
  
  // MARK: Build files
  
  func test_findBuildFile_existing_returnsBuildFile() {
    let sut = makeSut()
    
    let file = PBXFileReference(reference: "4321", name: "Test")
    let buildFile = PBXBuildFile(reference: "1234", fileRef: "4321")
    sut.objects.addObject(buildFile)
    
    let result = sut.findBuildFile(for: file)
    
    XCTAssertEqual(result, buildFile)
  }
  
  func test_findBuildFile_nonExisting_returnsNil() {
    let sut = makeSut()
    
    let file = PBXFileReference(reference: "1313", name: "File")
    
    XCTAssertNil(sut.findBuildFile(for: file))
  }
  
  func test_createBuildFile_returnsNewBuildFile() {
    let sut = makeSut()
    
    let file = PBXFileReference(reference: "4321", name: "Test")
    let buildFile = sut.addBuildFile(for: file)
    
    XCTAssertEqual(sut.objects.buildFiles[buildFile.reference], buildFile)
  }
  
  // MARK Helpers
  
  func makeSut(_ fixture: String = "root-object-fixture.xcodeproj", file: StaticString = #file, line: UInt = #line) -> PBXProj {
    do {
      return try XcodeProj(pathString: fixturesPath + fixture).pbxproj
    } catch {
      XCTFail("Can't load project fixture, error: \(error)", file: file, line: line)
      return PBXProj(objectVersion: 1, rootObject: "")
    }
  }
}

extension Optional {
  public typealias Transformation<U> = (Wrapped) throws -> U?
  
  public func assertFlatMap<U>(file: StaticString = #file, line: UInt = #line, _ transform: Transformation<U>) rethrows -> U? {
    switch self {
    case let .some(element):
      return try transform(element)
    case .none:
      XCTFail("Expected optional to be non-nil, got nil", file: file, line: line)
      return nil
    }
  }
}

