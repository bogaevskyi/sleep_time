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
    private var startRecordingTime: TimeInterval = 0
    
    func startRecording(afterDelay delay: TimeInterval) {
        setupRecorder()
        guard let recorder = recorder else { return }
        
        startRecordingTime = recorder.deviceCurrentTime + delay
        recorder.record(atTime: startRecordingTime)
    }
    
    func pause() {
        recorder?.pause()
    }
    
    func resume() {
        guard let recorder = recorder else { return }
        
        let diff = startRecordingTime - recorder.deviceCurrentTime
        if diff > 0 {
            let startTime = recorder.deviceCurrentTime + diff
            recorder.record(atTime: startTime)
        } else {
            recorder.record()
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
