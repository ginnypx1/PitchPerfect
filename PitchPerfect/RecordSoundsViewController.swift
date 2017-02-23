//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Ginny Pennekamp on 2/22/17.
//  Copyright © 2017 GhostBirdGames. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    // MARK: - View controls
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable stopRecording until recording
        stopRecordingButton.isEnabled = false
    }
    
    func changeRecordingView(to string: String, recordButtonEnabled: Bool, stopButtonEnabled: Bool) {
        recordingLabel.text = string
        recordButton.isEnabled = recordButtonEnabled
        stopRecordingButton.isEnabled = stopButtonEnabled
    }

    // MARK: - Record and Stop Recording Actions

    @IBAction func recordAudio(_ sender: Any) {
        
        // change the display to show we are recording
        changeRecordingView(to: "Recording in Progress", recordButtonEnabled: false, stopButtonEnabled: true)
        
        // create a file for recording
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // create an instance of AVPlayer
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print("There was a problem creating an instance of AVAudioSessionCategoryPlayAndRecord.")
        }
        
        // record audio
        do {
            guard let path = filePath else {
                print("The file path could not be extracted.")
                return
            }
            try audioRecorder = AVAudioRecorder(url: path, settings: [:])
        } catch {
            print("There was a problem loading the Audio Recorder.")
        }
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: Any) {
        
        // change the display to show we have stopped recording
        changeRecordingView(to: "Tap to Record", recordButtonEnabled: true, stopButtonEnabled: false)
        
        // stop the audio recording
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("There was a problem stopping the Audio Recorder.")
        }
    }
    
    // MARK: - Audio Recorder Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // if the recording was successful, initiate transfer to the PlaySoundsViewController
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("The recording was not successful.")
        }
    }
    
    // MARK: - Segue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // sends the recorded audio file to PlaySoundsViewController
        if segue.identifier == "stopRecording" {
            let playSoundsViewController = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsViewController.recordedAudioURL = recordedAudioURL
        }
    }
}

