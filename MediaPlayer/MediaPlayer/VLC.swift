import Foundation
import Kanna

struct VLC: MediaPlayerController {
    public let server: URL

    public init(ip: String, port: Int) throws {
        if let serverUrl = URL(string: "http://" + ip + ":\(port)") {
            server = serverUrl
        } else {
            throw APIError.invalidCommand
        }
    }

    private enum Endpoints: String {
        case status   = "/requests/status.xml"
    }

    public var volume: Int {
        get {
            return 0
        }
        set {
            try! execute(command: .setVolume, args: ["val" : "\(newValue)"])
        }
    }

    public func status(_ callback: @escaping (MediaPlayerStatus) -> Void) {
        let url = URL(string: server.absoluteString + Endpoints.status.rawValue)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let doc = try? HTML(html: data, encoding: .utf8),
                let statusElement = doc.css("#mpchc_np").first?.text {

                let fixedStatus = statusElement.replacingOccurrences(of: "« ", with: "").replacingOccurrences(of: " »", with: "").components(separatedBy: " • ")
                let status = MediaPlayerStatus(filename: fixedStatus[1], time: fixedStatus[2], filesize: fixedStatus[3])
                callback(status)
            } else {
                print(error!)
            }
            }.resume()
    }

    public func variables(_ callback: @escaping (MediaPlayerVariables) -> Void) {
        let url = URL(string: server.absoluteString + Endpoints.status.rawValue)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let doc = try? HTML(html: data, encoding: .utf8) {
                let vars = MediaPlayerVariables(doc: doc)
                callback(vars)
            } else {
                print(error!)
            }
        }.resume()
    }

    public func playPause() throws {
        try execute(command: .playPause)
    }

    public func toggleFullscreen() throws {
        try execute(command: .fullscreen)
    }

    public func toggleMute() throws {
        try execute(command: .setVolume, args: ["val" : "0"])
    }

    public func stop() throws {
        try execute(command: .stop)
    }

    public func next() throws {
        try execute(command: .next)
    }

    public func seek(to timecode: Timecode) throws {
        try execute(command: .seek, args: ["val" : "\(timecode.totalSeconds)"])
    }

    private func execute(command: Command, args: [String:String]? = nil) throws {
        let commandDict = [
            "command" : "\(command.rawValue)"
        ]

        let params: [String:String]
        if let args = args, !args.isEmpty {
            params = commandDict.merging(args, uniquingKeysWith: { return $0 + $1 })
        } else {
            params = commandDict
        }

        let url = URL(string: server.absoluteString + Endpoints.status.rawValue)!
        let query = params.map({ return $0 + "=" + $1 }).joined(separator: "&")
        let request = URL(string: url.absoluteString + "?" + query)!

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
        }.resume()
    }
}

/// Commands
/// - note: Docs https://wiki.videolan.org/VLC_HTTP_requests/
private enum Command: String {
    case playPause = "pl_pause"
    case stop = "pl_stop"
    case fullscreen = "fullscreen"
    case setVolume = "volume"
    case seek = "seek"
    case next = "pl_next"
}
