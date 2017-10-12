import UIKit
import TGPControls

func TODO() {
    fatalError()
}

class ViewController : UIViewController {

    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var nextTitle: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var fullscreen: UIButton!
    @IBOutlet weak var currentVolume: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var runtime: UILabel!
    @IBOutlet weak var isMuted: UIButton!
    
    var isFirstTime = true
    var playerVariables: MediaPlayerVariables? = nil {
        didSet {
            guard let playerVariables = playerVariables
                else { return }

            let currentSec = Float(playerVariables.position.totalSeconds)
            let totalSec = Float(playerVariables.duration.totalSeconds)
            DispatchQueue.main.async {
                self.progress.text = playerVariables.position.timecode
                self.runtime.text  = playerVariables.duration.timecode
                if self.isFirstTime {
                    self.timeSlider.maximumValue = totalSec
                    self.isFirstTime = false
                }
                self.timeSlider.setValue(currentSec, animated: true)
                self.volumeSlider.setValue(Float(playerVariables.volumeLevel), animated: true)
                self.currentVolume.text = "\(playerVariables.volumeLevel)%"

                if playerVariables.isMuted {
                    self.isMuted.setTitle("🔇", for: .normal)
                } else {
                    self.isMuted.setTitle("🔊", for: .normal)
                }
                if playerVariables.isPlaying {
                    self.resetFakeTimer()
                } else {
                    self.fakeProgressTimer.invalidate()
                }
            }
        }
    }
    var timer: Timer!
    var fakeProgressTimer: Timer!

    var server: MediaPlayerController = try! MPCHC(ip: "192.168.1.111", port: 13000)

    override func viewDidLoad() {
        super.viewDidLoad()

        timeSlider.minimumValue = 0
        timeSlider.maximumValue = 10
        timeSlider.isContinuous = true
        timeSlider.setValue(0, animated: false)
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 100
        volumeSlider.isContinuous = false
        currentVolume.text = "0%"

        fetchVariables()
        resetTimer()
        resetFakeTimer()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer.invalidate()
        fakeProgressTimer.invalidate()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTimer()
        self.isFirstTime = true
    }

    /// Used to fetch real data from the media player
    func resetTimer() {
        if timer != nil { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.fetchVariables), userInfo: nil, repeats: true)
    }

    /// Used to simulate progress on the slider
    func resetFakeTimer() {
        if fakeProgressTimer != nil { fakeProgressTimer.invalidate() }
        fakeProgressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.simulateTimeSlider), userInfo: nil, repeats: true)
    }

    @objc func fetchVariables() {
        server.variables { result in
            self.playerVariables = result
        }
    }

    @objc func simulateTimeSlider() {
        timeSlider.setValue(timeSlider.value + 1.0, animated: true)
        let updatedCurrentTimer = Timecode(totalSeconds: Int(timeSlider.value))
        progress.text = updatedCurrentTimer.timecode
    }

    @IBAction func playPausePressed(_ sender: UIButton) {
        try! server.playPause()
    }

    @IBAction func progressChanged(_ sender: UISlider) {
        let step: Float = 1.0
        let steppedValue = (sender.value / step).rounded() * step
        sender.setValue(steppedValue, animated: true)

//        let sss = Timecode(totalSeconds: Int(sender.value)).timecode
        // TODO: Add visual queue to let the user know the timecode before triggering progressSliderDeselected
        // Tooltip ? Modal VC that is auto-dismissed ?
    }

    @IBAction func progressSliderDeselected(_ sender: UISlider) {
        timer.invalidate()
        fakeProgressTimer.invalidate()

        let currentTimecode = Timecode(totalSeconds: Int(sender.value))
        try! server.seek(to: currentTimecode)
        resetTimer()
    }
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        let step: Float = 5
        let steppedValue = (sender.value / step).rounded() * step
        sender.setValue(steppedValue, animated: true)

        server.volume = Int(steppedValue)
        currentVolume.text = "\(server.volume)%"
    }

    @IBAction func nextPressed(_ sender: UIButton) {
        try! server.next()
    }

    @IBAction func stopPressed(_ sender: UIButton) {
        try! server.stop()
    }

    @IBAction func fullscreenPressed(_ sender: UIButton) {
        try! server.toggleFullscreen()
    }

    @IBAction func mutedPressed(_ sender: UIButton) {
        try! server.toggleMute()
    }
    
}

