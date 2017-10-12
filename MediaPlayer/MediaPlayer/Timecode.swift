import Foundation

public struct Timecode: ExpressibleByStringLiteral {
    public let hours, minutes, seconds: Int

    public var totalSeconds: Int {
        return (hours * 3600) + (minutes * 60) + seconds
    }

    public var timecode: String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    public init(totalSeconds seconds: Int) {
        hours = seconds / 3600
        var remainingSeconds = seconds % 3600
        minutes = seconds / 60
        remainingSeconds = seconds % 60
        self.seconds = remainingSeconds
    }

    public init(stringLiteral value: StringLiteralType) {
        let parts = value.components(separatedBy: ":")

        hours = Int(parts[0]) ?? 0
        minutes = Int(parts[1]) ?? 0
        seconds = Int(parts[2]) ?? 0
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}
