// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

@testable import LibrarianCore










class ConfigLoaderMock: ConfigLoader {

    //MARK: - loadConfig

    var loadConfigThrowableError: Error?
    var loadConfigCalled = false
    var loadConfigReceivedPath: String?
    var loadConfigReturnValue: String!

    func loadConfig(_ path: String) throws -> String {
        if let error = loadConfigThrowableError {
            throw error
        }
        loadConfigCalled = true
        loadConfigReceivedPath = path
        return loadConfigReturnValue
    }

}
