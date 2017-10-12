import Foundation
import Kanna

public struct MediaPlayerStatus {
    let filename: String
    let currentTime, totalTime: Timecode
    let filesize: String

    init(filename: String, time: String, filesize: String) {
        self.filename = filename
        let timers = time.components(separatedBy: "/")
        self.currentTime = Timecode(stringLiteral: timers[0])
        self.totalTime = Timecode(stringLiteral: timers[1])
        self.filesize = filesize

    }
}

public struct MediaPlayerVariables {
    let filePathArg, filePath, fileDirArg, fileDir: String
    let state: State
    let position: Timecode
    let duration: Timecode
    let volumeLevel: Int
    let isMuted: Bool
    let playbackRate, reloadTime: String

    var isPlaying: Bool {
        switch state {
        case .playing:
            return true
        default:
            return false
        }
    }

    var isPaused: Bool {
        switch state {
        case .paused:
            return true
        default:
            return false
        }
    }

    public enum State: String {
        case playing = "Playing"
        case paused = "Paused"
        case stopped = "Stopped"
    }

    private enum HTMLIdSelector: String, EnumCollection {
        case filePathArg = "filepatharg"
        case filePath = "filepath"
        case fileDirArg = "filedirarg"
        case fileDir = "filedir"
        case state = "state"
        case stateString = "statestring"
        case position = "position"
        case positionString = "positionstring"
        case duration = "duration"
        case durationString = "durationstring"
        case volumeLevel = "volumelevel"
        case muted = "muted"
        case playbackRate = "playbackrate"
        case reloadTime = "reloadtime"
    }

    init(doc: HTMLDocument) {
        filePathArg = doc.css("#\(HTMLIdSelector.filePathArg.rawValue)").first!.text!
        filePath = doc.css("#\(HTMLIdSelector.filePath.rawValue)").first!.text!
        fileDirArg = doc.css("#\(HTMLIdSelector.fileDirArg.rawValue)").first!.text!
        fileDir = doc.css("#\(HTMLIdSelector.fileDir.rawValue)").first!.text!
        let stateString = doc.css("#\(HTMLIdSelector.stateString.rawValue)").first!.text!
        state = State(rawValue: stateString) ?? .stopped
        let positionString = doc.css("#\(HTMLIdSelector.positionString.rawValue)").first!.text!
        position = Timecode(stringLiteral: positionString)
        let durationString = doc.css("#\(HTMLIdSelector.durationString.rawValue)").first!.text!
        duration = Timecode(stringLiteral: durationString)
        volumeLevel = Int(doc.css("#\(HTMLIdSelector.volumeLevel.rawValue)").first!.text!) ?? 0
        let muted = doc.css("#\(HTMLIdSelector.muted.rawValue)").first!.text!
        isMuted = muted == "1" ? true : false
        playbackRate = doc.css("#\(HTMLIdSelector.playbackRate.rawValue)").first!.text!
        reloadTime = doc.css("#\(HTMLIdSelector.reloadTime.rawValue)").first!.text!
    }
}
