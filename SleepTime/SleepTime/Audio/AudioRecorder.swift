//
//  AudioRecorder.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 14.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

final class AudioRecorder: NSObject {
    private var recorder: AVAudioRecorder?
    private var recordingCompletion: ((_ successfully: Bool) -> Void)?
    
    func startRecording(forDuration duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        recordingCompletion = completion
        setupRecorder()
        
        guard let recorder = recorder else { return }
        if recorder.record(forDuration: duration) {
            print("Recording successfully started.")
        } else {
            print("Recording start failed.")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }
    
    // MARK: - Private
    
    private func setupRecorder() {
        guard let directory = documentDirectory() else { return }
        let fileName = generateFileName()
        let fileDirectory = directory.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: fileDirectory, settings: settings)
            recorder?.delegate = self
            recorder?.prepareToRecord()
        } catch {
            print("AVAudioRecorder error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - File Utils
    
    private func documentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-HH-mm-ss"
        let dateString = formatter.string(from: Date())
        return "record-" + dateString + ".m4a"
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingCompletion?(flag)
    }
}
