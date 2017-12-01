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
    let sut = fixture("root-object-fixture.xcodeproj")
    
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
    let sut = fixture("root-object-fixture.xcodeproj")
    
    let root = try? sut.rootGroup()
    
    root.assertFlatMap {
      XCTAssertEqual($0.reference, "6FD7C2E91FC8982000971D97")
      XCTAssertEqual($0.children, ["6FD7C2F41FC8982000971D97",
                                   "6FD7C3091FC8982000971D97",
                                   "6FD7C2F31FC8982000971D97"])
    }
  }
  
  func test_groupNamed_returnsExistingFolderReferenceByPath() {
    let sut = fixture("root-object-fixture.xcodeproj")
    
    let root = try? sut.rootGroup()
    
    root
      .assertFlatMap { sut.findGroup("Sample", parent: $0) }
      .assertFlatMap {
        XCTAssertEqual($0.path, "Sample")
        XCTAssertEqual($0.reference, "6FD7C2F41FC8982000971D97")
    }
  }
    
  func test_groupNamed_returnsExistingGroupByName() {
    let sut = fixture("root-object-fixture.xcodeproj")
    
    let root = try! sut.rootGroup()
    
    sut.findGroup("Products", parent: root).assertFlatMap {
        XCTAssertEqual($0.name, "Products")
        XCTAssertEqual($0.reference, "6FD7C2F31FC8982000971D97")
    }
  }
  
  func test_createGroup_addsGroupAndAttachesToParent() {
    let sut = fixture("root-object-fixture.xcodeproj")
    
    let root = try! sut.rootGroup()
    let group = sut.createGroup("Frameworks", addTo: root)
    
    XCTAssertEqual(sut.objects.groups[group.reference], group)
    XCTAssertTrue(root.children.contains(group.reference))
  }
  
  // MARK Helpers
  
  func fixture(_ name: String, file: StaticString = #file, line: UInt = #line) -> PBXProj {
    do {
      return try XcodeProj(pathString: fixturesPath + name).pbxproj
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

