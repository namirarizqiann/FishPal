import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var startStopBtn: UIButton!
    @IBOutlet weak var segmentCtr: UISegmentedControl!
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var labelresult1: UILabel!
    @IBOutlet weak var labelyou1: UILabel!
   
   
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    var lang: String = "en-US"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startStopBtn.isEnabled = false  //2
        speechRecognizer?.delegate = self as? SFSpeechRecognizerDelegate  //3
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.startStopBtn.isEnabled = isButtonEnabled
            }
        }
    }

    
    @IBAction func startStopAct(_ sender: Any) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: lang))
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            startStopBtn.isEnabled = false
            startStopBtn.backgroundColor = .white
        } else {
            startRecording(button: startStopBtn)
            startStopBtn.backgroundColor = .green
            self.labelresult1.text = "listening"
            self.labelresult1.backgroundColor = .yellow
        }
    }

    
    func startRecording(button: UIButton) {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [self] (result, error) in
            
            var isFinal = false

            
            if self.startStopBtn.isEnabled == true
            {
                self.labelyou1.text = ""
            }

            
            if button == self.startStopBtn {
            if result != nil {
                
                self.labelyou1.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
                //self.textView1.text?.removeAll()
                
            }

                if self.labelyou1.text == "Continue" {
                self.labelresult1.text = "step 2"
                self.labelresult1.backgroundColor = .green
                self.labelyou1.text = ""
            }
            
          else if self.labelyou1.text == "Step three" {
                    self.labelresult1.text = "step 3"
                    self.labelresult1.backgroundColor = .green
                }
            
           else if self.labelyou1.text == "step 4" {
                    self.labelresult1.text = "step 4"
                    self.labelresult1.backgroundColor = .green
                }
            }
            
            else {
            if result != nil {
                
                self.labelyou1.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }

            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.startStopBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //textView1.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startStopBtn.isEnabled = true
        } else {
            startStopBtn.isEnabled = false
        }
    }
    
    

}

