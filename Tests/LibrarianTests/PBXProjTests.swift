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

