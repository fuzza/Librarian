//
//  ConfigParserTests.swift
//  LibrarianPackageDescription
//
//  Created by Alex Faizullov on 11/28/17.
//

import XCTest
@testable import LibrarianCore

class ConfigParserTests: XCTestCase {
  
  func test_parse_callsLoaderWithParams() {
    let loader = makeLoader()

    _ = try? makeSut(loader).parseConfig(at: "config.yml")
    
    XCTAssertTrue(loader.loadConfigCalled)
    XCTAssertEqual(loader.loadConfigReceivedPath, "config.yml")
  }
  
  func test_parse_loaderThrowsNoFile_rethrows() {
    let loader = makeLoader(error: .noFile("config.yml"))
    
    XCTAssertThrowsError(try makeSut(loader).parseConfig(at: "config.yml")) { error in
      XCTAssertEqual(error as? ConfigLoaderErrors, .noFile("config.yml"))
    }
  }
  
  func test_parse_loaderThrowsInvalidFile_rethrows() {
    let loader = makeLoader(error: .invalidFile("test.yml"))

    XCTAssertThrowsError(try makeSut(loader).parseConfig(at: "test.yml")) { error in
      XCTAssertEqual(error as? ConfigLoaderErrors, ConfigLoaderErrors.invalidFile("test.yml"))
    }
  }
  
  func test_parse_loaderThrowsReadingError_rethrows() {
    let loader = makeLoader(error: .readingError("file.yml", "reason"))

    XCTAssertThrowsError(try makeSut(loader).parseConfig(at: "file.yml")) { error in
      XCTAssertEqual(error as? ConfigLoaderErrors, ConfigLoaderErrors.readingError("file.yml", "reason"))
    }
  }
  
  func test_parse_invalidConfig_throws() {
    let loader = makeLoader(returnedValue:"invalid_content");
    XCTAssertThrowsError(try makeSut(loader).parseConfig(at: "config.yml"))
  }
  
  func test_parse_validConfig_returnsProjectObject() {
    let fixture =
      """
      project: Librarian.xcodeproj
      targets:
        - name: test
          dependencies:
            - RxSwift
            - RxCocoa
        - name: app
          dependencies:
            - RxTest
            - RxBlocking
      """

    let loader = makeLoader(returnedValue: fixture);
    let project = try! makeSut(loader).parseConfig(at: "config.yml")
    
    XCTAssertEqual(project.targets.count, 2)
    XCTAssertEqual(project.project, "Librarian.xcodeproj")
    XCTAssertEqual(project.targets.first, Target(name: "test", dependencies:[.carthage("RxSwift"), .carthage("RxCocoa")]))
    XCTAssertEqual(project.targets.last, Target(name: "app", dependencies:[.carthage("RxTest"), .carthage("RxBlocking")]))
  }
  
  // MARK: Helpers
  
  func makeLoader(returnedValue: String = "", error: ConfigLoaderErrors? = nil) -> ConfigLoaderMock {
    let loaderStub = ConfigLoaderMock()
    loaderStub.loadConfigThrowableError = error
    loaderStub.loadConfigReturnValue = returnedValue
    return loaderStub
  }
  
  func makeSut(_ loader: ConfigLoader) -> YamlConfigParser {
    return YamlConfigParser(loader: loader);
  }
}
