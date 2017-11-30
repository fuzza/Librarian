//
//  XCBuildConfigurationTests.swift
//  LibrarianTests
//
//  Created by Alex Fayzullov on 11/30/17.
//

import XCTest
import xcproj
import Nimble

@testable import LibrarianCore

class XCBuildConfigurationTests: XCTestCase {
  
  func test_getFrameworkSearchPath_notExists_returnsEmptyArray() {
    expect { self.makeSut().frameworkSearchPaths }.to(beEmpty())
  }
  
  func test_getFrameworkSearchPath_notAStringOrArray_returnsEmptyArray() {
    let settings = ["FRAMEWORK_SEARCH_PATHS" : 1]
    expect { self.makeSut(settings).frameworkSearchPaths }.to(beEmpty())
  }
  
  func test_getFrameworkSearchPaths_string_returnsArrayWithString() {
    let settings = ["FRAMEWORK_SEARCH_PATHS" : "test_path"]
    expect { self.makeSut(settings).frameworkSearchPaths }.to(equal(["test_path"]))
  }
  
  func test_getFrameworkSearchPath_array_returnsPaths() {
    let settings = ["FRAMEWORK_SEARCH_PATHS" : ["first_path", "second_path"]]
    expect { self.makeSut(settings).frameworkSearchPaths }.to(equal(["first_path", "second_path"]))
  }
  
  func test_setFrameworkSearchPath_modifiesBuildSettings() {
    let sut = self.makeSut()
    
    sut.frameworkSearchPaths = ["path"]
    
    expect { sut.buildSettings["FRAMEWORK_SEARCH_PATHS"] as? [String] }.to(equal(["path"]))
  }
  
  // MARK: Helpers
  func makeSut(_ settings: BuildSettings = [:]) -> XCBuildConfiguration {
    return XCBuildConfiguration(reference: "01ACSDGET", name: "Debug", buildSettings: settings);
  }
}
