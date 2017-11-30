// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs
// MARK: - Project AutoEquatable
extension Project: Equatable {}
public func == (lhs: Project, rhs: Project) -> Bool {
    guard lhs.project == rhs.project else { return false }
    guard lhs.targets == rhs.targets else { return false }
    return true
}
// MARK: - Target AutoEquatable
extension Target: Equatable {}
public func == (lhs: Target, rhs: Target) -> Bool {
    guard lhs.name == rhs.name else { return false }
    guard lhs.dependencies == rhs.dependencies else { return false }
    return true
}

// MARK: - AutoEquatable for Enums
// MARK: - ConfigLoaderErrors AutoEquatable
extension ConfigLoaderErrors: Equatable {}
public func == (lhs: ConfigLoaderErrors, rhs: ConfigLoaderErrors) -> Bool {
    switch (lhs, rhs) {
    case (.noFile(let lhs), .noFile(let rhs)):
        return lhs == rhs
    case (.invalidFile(let lhs), .invalidFile(let rhs)):
        return lhs == rhs
    case (.readingError(let lhs), .readingError(let rhs)):
        if lhs.0 != rhs.0 { return false }
        if lhs.1 != rhs.1 { return false }
        return true
    default: return false
    }
}
// MARK: - Dependency AutoEquatable
extension Dependency: Equatable {}
public func == (lhs: Dependency, rhs: Dependency) -> Bool {
    switch (lhs, rhs) {
    case (.carthage(let lhs), .carthage(let rhs)):
        return lhs == rhs
    }
}
// MARK: - LookupErrors AutoEquatable
extension LookupErrors: Equatable {}
internal func == (lhs: LookupErrors, rhs: LookupErrors) -> Bool {
    switch (lhs, rhs) {
    case (.rootProjectNotFound, .rootProjectNotFound):
        return true
    case (.configurationsNotFound(let lhs), .configurationsNotFound(let rhs)):
        return lhs == rhs
    default: return false
    }
}
