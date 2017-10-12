import Foundation
import Kanna

public struct MPCHC: MediaPlayerController {
    public let server: URL

    public init(ip: String, port: Int) throws {
        if let serverUrl = URL(string: "http://" + ip + ":\(port)") {
            server = serverUrl
        } else {
            throw APIError.invalidCommand
        }
    }

    private enum Endpoints: String {
        case command   = "/command.html"
        case info      = "/info.html"
        case variables = "/variables.html"
    }

    public var volume: Int {
        get {
            return 0
        }
        set {
            try! execute(command: .setVolume, args: ["volume" : "\(newValue)"])
        }
    }

    public func status(_ callback: @escaping (MediaPlayerStatus) -> Void) {
        let url = URL(string: server.absoluteString + Endpoints.info.rawValue)!
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
        let url = URL(string: server.absoluteString + Endpoints.variables.rawValue)!
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
        try execute(command: .volumeMute)
    }

    public func stop() throws {
        try execute(command: .stop)
    }

    public func next() throws {
        try execute(command: .next)
    }

    public func seek(to timecode: Timecode) throws {
        try execute(command: .seek, args: ["position" : timecode.timecode])
    }

    private func execute(command: Command, args: [String:String]? = nil) throws {
        let commandDict = [
            "wm_command" : "\(command.rawValue)"
        ]

        let params: [String:String]
        if let args = args, !args.isEmpty {
            params = commandDict.merging(args, uniquingKeysWith: { return $0 + $1 })
        } else {
            params = commandDict
        }

        let url = URL(string: server.absoluteString + Endpoints.command.rawValue)!
        let query = params.map({ return $0 + "=" + $1 }).joined(separator: "&")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = query.data(using: .utf8)


        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
        }.resume()
    }
}

/// Commands
/// - note: Thanks to https://github.com/eeeeeric/mpc-hc-api for the complete commands/codes list
private enum Command: Int {
    case setVolume = -2
    case seek = -1
    case quickOpenFile = 969
    case openFile = 800
    case openDvdBd = 801
    case openDevice = 802
    case reopenFile = 976
    case moveToRecycleBin = 24044
    case saveACopy = 805
    case saveImage = 806
    case saveImageAuto = 807
    case saveThumbnails = 808
    case loadSubtitle = 809
    case saveSubtitle = 810
    case close = 804
    case properties = 814
    case exit = 816
    case playPause = 889
    case play = 887
    case pause = 888
    case stop = 890
    case framestep = 891
    case framestepBack = 892
    case goTo = 893
    case increaseRate = 895
    case decreaseRate = 894
    case resetRate = 896
    case audioDelayPlus10Ms = 905
    case audioDelayMinus10Ms = 906
    case jumpForwardSmall = 900
    case jumpBackwardSmall = 899
    case jumpForwardMedium = 902
    case jumpBackwardMedium = 901
    case jumpForwardLarge = 904
    case jumpBackwardLarge = 903
    case jumpForwardKeyframe = 898
    case jumpBackwardKeyframe = 897
    case jumpToBeginning = 996
    case next = 922
    case previous = 921
    case nextFile = 920
    case previousFile = 919
    case tunerScan = 974
    case quickAddFavorite = 975
    case toggleCaptionAndMenu = 817
    case toggleSeeker = 818
    case toggleControls = 819
    case toggleInformation = 820
    case toggleStatistics = 821
    case toggleStatus = 822
    case toggleSubresyncBar = 823
    case togglePlaylistBar = 824
    case toggleCaptureBar = 825
    case toggleNavigationBar = 33415
    case toggleDebugShaders = 826
    case viewMinimal = 827
    case viewCompact = 828
    case viewNormal = 829
    case fullscreen = 830
    case fullscreenWithoutResChange = 831
    case zoom50 = 832
    case zoom100 = 833
    case zoom200 = 834
    case zoomAutoFit = 968
    case zoomAutoFitLargerOnly = 4900
    case nextArPreset = 859
    case vidfrmHalf = 835
    case vidfrmNormal = 836
    case vidfrmDouble = 837
    case vidfrmStretch = 838
    case vidfrmInside = 839
    case vidfrmZoom1 = 841
    case vidfrmZoom2 = 842
    case vidfrmOutside = 840
    case vidfrmSwitchZoom = 843
    case alwaysOnTop = 884
    case pnsReset = 861
    case pnsIncSize = 862
    case pnsIncWidth = 864
    case pnsIncHeight = 866
    case pnsDecSize = 863
    case pnsDecWidth = 865
    case pnsDecHeight = 867
    case pnsCenter = 876
    case pnsLeft = 868
    case pnsRight = 869
    case pnsUp = 870
    case pnsDown = 871
    case pnsUpLeft = 872
    case pnsUpRight = 873
    case pnsDownLeft = 874
    case pnsDownRight = 875
    case pnsRotateXPlus = 877
    case pnsRotateXMinus = 878
    case pnsRotateYPlus = 879
    case pnsRotateYMinus = 880
    case pnsRotateZPlus = 881
    case pnsRotateZMinus = 882
    case volumeUp = 907
    case volumeDown = 908
    case volumeMute = 909
    case volumeBoostIncrease = 970
    case volumeBoostDecrease = 971
    case volumeBoostMin = 972
    case volumeBoostMax = 973
    case toggleCustomChannelMapping = 993
    case toggleNormalization = 994
    case toggleRegainVolume = 995
    case brightnessIncrease = 984
    case brightnessDecrease = 985
    case contrastIncrease = 986
    case contrastDecrease = 987
    case hueIncrease = 988
    case hueDecrease = 989
    case saturationIncrease = 990
    case saturationDecrease = 991
    case resetColorSettings = 992
    case dvdTitleMenu = 923
    case dvdRootMenu = 924
    case dvdSubtitleMenu = 925
    case dvdAudioMenu = 926
    case dvdAngleMenu = 927
    case dvdChapterMenu = 928
    case dvdMenuLeft = 929
    case dvdMenuRight = 930
    case dvdMenuUp = 931
    case dvdMenuDown = 932
    case dvdMenuActivate = 933
    case dvdMenuBack = 934
    case dvdMenuLeave = 935
    case bossKey = 944
    case playerMenuShort = 949
    case playerMenuLong = 950
    case filtersMenu = 951
    case options = 815
    case nextAudio = 952
    case prevAudio = 953
    case nextSubtitle = 954
    case prevSubtitle = 955
    case onOffSubtitle = 956
    case reloadSubtitles = 2302
    case downloadSubtitles = 812
    case nextAudioOgm = 957
    case prevAudioOgm = 958
    case nextSubtitleOgm = 959
    case prevSubtitleOgm = 960
    case nextAngleDvd = 961
    case prevAngleDvd = 962
    case nextAudioDvd = 963
    case prevAudioDvd = 964
    case nextSubtitleDvd = 965
    case prevSubtitleDvd = 966
    case onOffSubtitleDvd = 967
    case tearingTest = 32769
    case remainingTime = 32778
    case nextShaderPreset = 57382
    case prevShaderPreset = 57384
    case toggleDirect3dFullscreen = 32779
    case gotoPrevSubtitle = 32780
    case gotoNextSubtitle = 32781
    case shiftSubtitleLeft = 32782
    case shiftSubtitleRight = 32783
    case displayStats = 32784
    case resetDisplayStats = 33405
    case vsync = 33243
    case enableFrameTimeCorrection = 33265
    case accurateVsync = 33260
    case decreaseVsyncOffset = 33246
    case increaseVsyncOffset = 33247
    case subtitleDelayMinus = 24000
    case subtitleDelayPlus = 24001
    case afterPlaybackExit = 912
    case afterPlaybackStandBy = 913
    case afterPlaybackHibernate = 914
    case afterPlaybackShutdown = 915
    case afterPlaybackLogOff = 916
    case afterPlaybackLock = 917
    case afterPlaybackTurnOffTheMonitor = 918
    case afterPlaybackPlayNextFileInTheFolder = 947
    case toggleEdlWindow = 846
    case edlSetIn = 847
    case edlSetOut = 848
    case edlNewClip = 849
    case edlSave = 860
}

