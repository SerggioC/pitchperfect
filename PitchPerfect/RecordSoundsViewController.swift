//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Sergio Cruz on 19/04/2020.
//  Copyright © 2020 Sergio Cruz. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    private var audioRecorder: AVAudioRecorder?
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtons(recording: false)
    }

    @IBAction func onRecordClick(_ sender: Any) {
        updateButtons(recording: true)
        
        do {
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let recordingName = "recordedVoice.wav"
            let pathArray = [dirPath, recordingName]
            let filePath = URL(string: pathArray.joined(separator: "/"))
            
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            
            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } catch {
            print(error)
        }
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let it = UIAlertController.init(title: "Recorded", message: "Recorded succefully!", preferredStyle: .alert)
            it.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                self.performSegue(withIdentifier: "gotoRecording", sender: recorder.url)
            }))
            present(it, animated: true, completion: nil)
        } else {
            let it = UIAlertController.init(title: "Error", message: "Recording did not succeed!\nTry again.", preferredStyle: .alert)
            it.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(it, animated: true, completion: nil)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        let it = UIAlertController.init(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
        it.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(it, animated: true, completion: nil)
    }
    
    
    fileprivate func updateButtons(recording: Bool) {
        label.text = recording ? "Recording..." : "Tap to record..."
        recordButton.isEnabled = !recording
        stopRecordingButton.isEnabled = recording
    }
    
    @IBAction func onStopClick(_ sender: Any) {
        updateButtons(recording: false)
        audioRecorder?.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoRecording",
            let destination = segue.destination as? PlaySoundsViewController,
            let recordURL = sender as? URL {
                destination.recordedAudioURL = recordURL
        }
    }
    
}

