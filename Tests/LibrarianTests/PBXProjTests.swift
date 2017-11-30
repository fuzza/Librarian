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

