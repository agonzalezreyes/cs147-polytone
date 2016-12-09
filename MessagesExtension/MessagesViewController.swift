//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Alejandrina Gonzalez on 12/4/16.
//  Copyright © 2016 Alejandrina Gonzalez Reyes. All rights reserved.
//

import UIKit
import Messages
import Speech
import CoreAudio
import AVFoundation
import Foundation
import Photos
//import EZAudio

class MessagesViewController: MSMessagesAppViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate,LTInfiniteScrollViewDataSource, LTInfiniteScrollViewDelegate, TwicketSegmentedControlDelegate, AKPickerViewDelegate, AKPickerViewDataSource, SSRollingButtonScrollViewDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRunning = false
    private var recorder: AVAudioRecorder!
    private var levelTimer = Timer()
    private var lowPassResults: Double = 0.0
    private var levels = [Float]()
    @IBOutlet var textView: UITextView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var createView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet var scrollView: AKPickerView!
    @IBOutlet var scrollView2: SSRollingButtonScrollView!


    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet var imgView: UIView!
    var isTaken = false
    @IBOutlet weak var pic: UIButton!

    func didSelect(_ segmentIndex: Int) {
        print("Selected idex: \(segmentIndex)")
        if segmentIndex == 0 {
            self.scrollView2.isHidden = true
            self.scrollView.isHidden = false
        } else {
            self.scrollView2.isHidden = false
            self.scrollView.isHidden = true
        }
    }
    func numberOfViews() -> Int {
        return 6
    }
    func numberOfVisibleViews() -> Int {
        return 5
    }
    
    func view(at index: Int, reusing view: UIView!) -> UIView! {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        switch index {
        case 0:
            v.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        case 1:
            v.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        case 2:
            v.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        case 3:
            v.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        case 4:
            v.backgroundColor = UIColor.yellow.withAlphaComponent(0.8)
        case 5:
            v.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
        default:
            print("def")
        }
        //v.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 27.5
        let imageV = UIImageView(frame: v.frame)
        imageV.image = UIImage(named: "add.png")
        return v
    }
    
        
    
    func scrollView(_ scrollView: LTInfiniteScrollView!, didScrollTo index: Int) {
        print("\(index)")
    }
    
        var uiimagesArray = [UIImage(named:"add.png")]
    
    override func viewDidAppear(_ animated: Bool) {
       // self.viewDidAppear(animated)
         previewLayer!.frame = previewView.bounds
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
  
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity =  AVLayerVideoGravityResizeAspectFill
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(previewLayer!)
                captureSession!.startRunning()
            }
        }

    }
    @IBAction func didPressTakePhoto(_ sender: UIButton) {
        
        if (!isTaken){
            isTaken = true
            pic.setImage(UIImage(named: "retake.png"), for: .normal)

            if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
                stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                    if (sampleBuffer != nil) {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        let dataProvider = CGDataProvider(data: imageData as! CFData)
                        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                        
                        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                        self.capturedImage.image = image
                        self.imgView.isHidden = false
                        
                    }
                })
            }
        } else {
            isTaken = false
            imgView.isHidden = true
            pic.setImage(UIImage(named: "camera-icon.png"), for: .normal)
        }
        
       
    }
    
    @IBAction func didPressTakeAnother(_ sender: AnyObject) {
        captureSession!.startRunning()
    }

    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return images.count
    }
    
    let images = ["red.png", "yellow.png", "purple.png", "blue.png", "green.png"]
    func pickerView(_ pickerView: AKPickerView, imageForItem item: Int) -> UIImage {
             return UIImage(named: self.images[item])!
    
    }
    let fonts = ["Baskerville","ChalkboardSE-Regular","Avenir-Medium","Copperplate", "Courier", "Damascus", "Farah", "GillSans", "Helvetica", "AmericanTypewriter"]
   let fontNames = ["Baskerville","Chalkboard","Avenir","Copperplate", "Courier", "Damascus", "Farah", "GillSans", "Helvetica", "Typewriter"]
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {
            print(item)
            switch item {
            case 0:
                self.textView.textColor = .red // ye pink blue green
            case 1:
                self.textView.textColor = .yellow
            case 2:
                self.textView.textColor = UIColor(red:221/255.0, green:81/255.0, blue:215/255.0, alpha: 1)
            case 3:
                self.textView.textColor = .blue
            case 4:
                self.textView.textColor = .green
            default:
                print(item)
            }
    }
    func rollingScrollViewButtonPushed(_ button: UIButton!, ssRollingButtonScrollView rollingButtonScrollView: SSRollingButtonScrollView!) {
        if let s = fontSize {
            self.textView.font = UIFont(name: (button.titleLabel?.text)!, size: s)
        }
    }
    var fontSize: CGFloat!
    func tap(){
        self.view.endEditing(true)
        self.view.resignFirstResponder()
    }
    func generateImageWithText() -> UIImage {
        var imageWithText = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(capturedImage.bounds.size, false, 0)
        capturedImage.layer.render(in: UIGraphicsGetCurrentContext()!)
        textView.layer.render(in: UIGraphicsGetCurrentContext()!)
        imageWithText = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return imageWithText
    }
    @IBOutlet weak var done: UIButton!
    
    func createImage(){
        let img = generateImageWithText()
        uiimagesArray.append(img)
        if let conversation = activeConversation {
            
            guard let imageURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("polytone.png") else {
                return
            }
            
            do {
                try UIImagePNGRepresentation(img)?.write(to: imageURL)
            } catch { }
            conversation.insertAttachment(imageURL, withAlternateFilename: "polytone.png", completionHandler: nil)
            
            self.requestPresentationStyle(.compact)

            
        }
    }
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startDismissAction(_ sender: Any) {
        self.requestPresentationStyle(.expanded)
    }
    
    override func viewDidLoad() {
        done.addTarget(self, action: #selector(self.createImage), for: .touchUpInside)
        imgView.isHidden = true
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgView.addSubview(blurEffectView)
        imgView.addSubview(capturedImage)
        
        let titles = ["Color", "Font"]
        let frame = CGRect(x: 0, y: self.view.bounds.height - 150, width: 150, height: 40)
        
        let segmentedControl = TwicketSegmentedControl(frame: frame)
        segmentedControl.center.x = self.view.center.x
        
        segmentedControl.setSegmentItems(titles)
        segmentedControl.delegate = self
        segmentedControl.layer.masksToBounds = true
        segmentedControl.layer.cornerRadius = 20
        createView.addSubview(segmentedControl)
        
        self.scrollView.delegate = self;
        self.scrollView.dataSource = self
        self.scrollView.pickerViewStyle = .wheel
        self.scrollView.maskDisabled = false
        self.scrollView.tag = 1
        
        self.scrollView2.spacingBetweenButtons = 10.0
        self.scrollView2.notCenterButtonTextColor = .gray
        self.scrollView2.centerButtonTextColor = .black
        self.scrollView2.createButtonArray(withButtonTitles: fontNames, andLayoutStyle: SShorizontalLayout)
        self.scrollView2.ssRollingButtonScrollViewDelegate = self;
        self.scrollView2.tag = 2
        
        capturedImage.layer.masksToBounds = true
        previewView.layer.masksToBounds = true
        capturedImage.layer.cornerRadius = 10
        previewView.layer.cornerRadius = 10
        self.view.addSubview(createView)
        
        self.scrollView2.isHidden = true
        self.scrollView.isHidden = false
        
        createView.frame = self.view.bounds
        createView.isHidden = true 
        super.viewDidLoad()
        if textView.text == "" {
            recordButton.center = self.view.center
        }
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    //self.recordButton.isEnabled = true
                    print("Speech recognition authorized on this device")
                case .denied:
                    //self.recordButton.isEnabled = false
                    print("User denied access to speech recognition")
                case .restricted:
                    //self.recordButton.isEnabled = false
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    //self.recordButton.isEnabled = false
                    print("Speech recognition not yet authorized")
                }
            }
        }
        let tap = UISwipeGestureRecognizer()
        tap.direction = .down
        tap.addTarget(self, action: #selector(MessagesViewController.tap))
        self.textView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    // Caption audio, yay!
    private func startRecording() throws {
       // self.mic.startFetchingAudio()
        // Cancel the previous task if it's running.
        self.levels.removeAll()
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        let settings: [String: AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0 as AnyObject,
            AVNumberOfChannelsKey: 1 as AnyObject,
            ]
        
        do {
            let URL = self.directoryURL()!
            try! recorder = AVAudioRecorder(url: URL as URL, settings: settings)
        }
        recorder.delegate = self
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        //var lastStylized: NSMutableAttributedString = NSMutableAttributedString(string:"")
        let prev = textView.attributedText
        let font:UIFont? = UIFont(name: "AvenirNextCondensed-Regular", size: 18.0)
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                var segs = result.bestTranscription.segments
                
                let finalText = NSMutableAttributedString(string: "")
                finalText.append(prev!)
                let newLine = NSMutableAttributedString(string: "\n\n")
                newLine.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, newLine.length))
                finalText.append(newLine)
                if (segs.count > 0 && segs[0].timestamp != 0) {
                    print("got here")
                    for i in 0...segs.count-1 {
                        //let base = segs[i].timestamp
                        let str = NSMutableAttributedString(string: segs[i].substring+" ")
                        //In ranges, first number is start position, and second number is length of the effect
                        let currSeg = segs[i]
                        let time: Float = Float(currSeg.timestamp)
                        let idx: Int = Int(time/0.2)
                        print("Attempting Index")
                        print("Time: ", time)
                        print("Val: ",  idx)
                        let fontSize = (self.levels[0]/self.levels[idx])*18.0
                        self.fontSize = CGFloat(fontSize)
                        print("Got Index")
                        if fontSize > 32.0 {
                            let font:UIFont? = UIFont(name: "AvenirNextCondensed-DemiBold", size: CGFloat(fontSize))
                            str.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, str.length))
                        } else {
                            let font:UIFont? = UIFont(name: "AvenirNextCondensed-Medium", size: CGFloat(fontSize))
                            str.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, str.length))
                        }
                        finalText.append(str)
                    }
                    self.textView.attributedText = finalText
                } else {
                    let addition: NSMutableAttributedString = NSMutableAttributedString(string:"\n" + result.bestTranscription.formattedString)
                    let temp = NSMutableAttributedString(string: "")
                    addition.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, addition.length))
                    temp.append(prev!)
                    temp.append(addition)
                    self.textView.attributedText = temp
                }
                let range = NSMakeRange(self.textView.text.characters.count - 1, 0)
                self.textView.scrollRangeToVisible(range)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //self.recordButton.isEnabled = true
                //self.recordButton.setTitle("Start Recording", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        
        
        try audioEngine.start()
        
        recorder.record()
        
        //instantiate a timer to be called with whatever frequency we want to grab metering values
        self.levelTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.levelTimerCallback), userInfo: nil, repeats: true)
        recorder.updateMeters()
        isRunning = true
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
//        
//        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        tap.cancelsTouchesInView = false
//        
//        view.addGestureRecognizer(tap)
        
    }
    

    func levelTimerCallback() {
        //we have to update meters before we can get the metering values
        recorder.updateMeters()
        
        //print to the console if we are beyond a threshold value. Here I've used -7
        print (recorder.averagePower(forChannel: 0))
        self.levels.append(recorder.averagePower(forChannel: 0))
        //        if recorder.averagePower(forChannel: 0) > -7 {
        //            print("Dis be da level I'm hearin' you in dat mic ")
        //            print(recorder.averagePower(forChannel: 0))
        //            print("Do the thing I want, mofo")
        //        }
    }
    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL as NSURL?
    }
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
           // recordButton.isEnabled = true
            print("Recording available")
        } else {
           // recordButton.isEnabled = false
            print("Recognition not available")
        }
    }
    @IBAction func recordButtonTapped() {
        if isRunning {
            stop()
            recordButton.setImage(#imageLiteral(resourceName: "Image 6"), for: .normal)
            print("Stopping")
        } else {
            try! startRecording()
            recordButton.setImage(#imageLiteral(resourceName: "Image 7"), for: .normal)
            print("Starting")
            isRunning = true
        }
    }
    
    func stop() {
      //  self.mic.stopFetchingAudio()
        audioEngine.pause()
        recorder.stop()
        recorder.isMeteringEnabled = false
        self.levelTimer.invalidate()
        recognitionRequest?.endAudio()
        isRunning = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        switch presentationStyle {
        case .compact:
            self.createView.isHidden = true
        case .expanded:
            self.createView.isHidden = false
        default:
            print("default")
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
