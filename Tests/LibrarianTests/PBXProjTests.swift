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
      XCTAssertEqual($0.last?.name, "Release")
    }
  }

  // MARK: Groups Lookup

  func test_rootGroup_returnProjectMainGroup() {
    let sut = makeSut()

    let root = try? sut.rootGroup()

    root.assertFlatMap {
      XCTAssertEqual($0.children, ["6FD7C2F41FC8982000971D97",
                                   "6FD7C3091FC8982000971D97",
                                   "6FD7C2F31FC8982000971D97"])
    }
  }

  func test_findGroup_returnsExistingFolderReferenceByPath() {
    let sut = makeSut()

    let root = try! sut.rootGroup()
    
    sut.findGroup("Sample", parent: root)
      .assertFlatMap { XCTAssertEqual($0.path, "Sample") }
  }

  func test_findGroup_returnsExistingGroupByName() {
    let sut = makeSut()

    let root = try! sut.rootGroup()

    sut.findGroup("Products", parent: root)
      .assertFlatMap { XCTAssertEqual($0.name, "Products") }
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

    let result = sut.objects.group(named: "Frameworks", inGroup: root)
    
    XCTAssertNotNil(result)
    XCTAssertEqual(result!.object, group)
    XCTAssertTrue(root.children.contains(result!.reference))
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

    let fileRef = PBXFileReference(name: "Test")
    
    root.children.append("2222")
    sut.objects.addObject(fileRef, reference: "2222")

    XCTAssertEqual(sut.findReference("Test", parent: root), "2222")
  }

  func test_addFramework_createsNewFrameworkReference() {
    let sut = makeSut()

    let root = try! sut.rootGroup()

    let frameworkRef = sut.addFramework("Test", in: root, path: "/var/lib")

    XCTAssertTrue(root.children.contains(frameworkRef))
    
    sut.objects.fileReferences[frameworkRef].assertFlatMap { framework in
      XCTAssertEqual(framework.name, "Test")
      XCTAssertEqual(framework.path, "/var/lib/Test")
      XCTAssertEqual(framework.lastKnownFileType, "wrapper.framework")
      XCTAssertEqual(framework.sourceTree, .group)
    }
  }

  // MARK: Build files

  func test_findBuildFile_existing_returnsBuildFile() {
    let sut = makeSut()

    let buildFile = PBXBuildFile(fileRef: "4321")
    sut.objects.addObject(buildFile, reference: "1234")

    let result = sut.findBuildFile(for: "4321")

    XCTAssertEqual(result, "1234")
  }

  func test_findBuildFile_nonExisting_returnsNil() {
    XCTAssertNil(makeSut().findBuildFile(for: "1313"))
  }

  func test_createBuildFile_returnsNewBuildFile() {
    let sut = makeSut()

    let buildFile = sut.addBuildFile(for: "4321")

    sut.objects.buildFiles[buildFile]
      .assertFlatMap {
        XCTAssertEqual($0.fileRef, "4321")
    }
  }

  // MARK Helpers
  
  func makeSut(_ fixture: String = "root-object-fixture.xcodeproj", file: StaticString = #file, line: UInt = #line) -> PBXProj {
    do {
      return try XcodeProj(pathString: fixturesPath + fixture).pbxproj
    } catch {
      XCTFail("Can't load project fixture, error: \(error)", file: file, line: line)
      return PBXProj(rootObject: "", objectVersion: 1)
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

