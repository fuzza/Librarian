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

// MARK: - AutoEquatable for Enums
// MARK: - ConfigLoaderError AutoEquatable
extension ConfigLoaderErrors: Equatable {}
public func == (lhs: ConfigLoaderErrors, rhs: ConfigLoaderErrors) -> Bool {
    switch (lhs, rhs) {
    case (.noFile(let lhs), .noFile(let rhs)):
        return lhs == rhs
    case (.invalidFile(let lhs), .invalidFile(let rhs)):
        return lhs == rhs
    case (.decodingError(let lhs), .decodingError(let rhs)):
        return lhs == rhs
    default: return false
    }
}
