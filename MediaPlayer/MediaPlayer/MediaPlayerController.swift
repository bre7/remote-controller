import Foundation

public protocol MediaPlayerController {
    var server: URL { get }
    var volume: Int { get set }

    init(ip: String, port: Int) throws
    func status(_ callback: @escaping (MediaPlayerStatus) -> Void)
    func variables(_ callback: @escaping (MediaPlayerVariables) -> Void)
    func playPause() throws
    func toggleFullscreen() throws
    func toggleMute() throws
    func stop() throws
    func next() throws
    func seek(to timecode: Timecode) throws

}

public enum APIError: Error {
    case invalidCommand
    case invalidResponse
    case generic(String)
}
