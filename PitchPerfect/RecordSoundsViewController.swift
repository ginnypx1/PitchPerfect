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

    // MARK: - Record and Stop Recording Actions

    @IBAction func recordAudio(_ sender: Any) {
        
        // recording started: change text label, disable recording button, enable stop button
        recordingLabel.text = "Recording in Progress"
        stopRecordingButton.isEnabled = true
        recordButton.isEnabled = false
        
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
        
        // recording ended: enable record button, disable stop recording and change the text label
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordingLabel.text = "Tap to Record"
        
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

