import Foundation

/// Make an enum iterable (list all items). "It just works" ™
/// Original: https://stackoverflow.com/a/28341290/2124535
protocol EnumCollection: Hashable {
    static var allValues: [Self] { get }
}

extension EnumCollection {

    /// Enumerate all the cases in an enum using generics.
    ///
    /// - Returns: Returns a sequence containing all the cases of an enum
    static func cases2() -> AnySequence<Self> {
        typealias SequenceElement = Self
        return AnySequence { () -> AnyIterator<SequenceElement> in
            var raw = 0
            return AnyIterator {
                let current : Self = withUnsafePointer(to: &raw) {
                    $0.withMemoryRebound(to: SequenceElement.self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }

    /// Enumerate all the cases in an enum using generics.
    ///
    /// - Returns: Returns an iterator containing all the cases of an enum
    static func cases() -> AnyIterator<Self> {
        typealias Element = Self
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: Element.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }

    static var allValues: [Self] {
        return Array(self.cases())
    }
}
