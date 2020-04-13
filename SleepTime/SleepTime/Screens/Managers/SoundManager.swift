//
//  SoundManager.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

// TODO: consider splitting into 3 separate protocols
protocol SoundManaging {
    // Session
    func setupSession()
    
    // Play in loop
    func playInLoop(_ fileName: String, duration: TimeInterval, completion: @escaping () -> Void)
    func resumeSoundInLoop()
    func pauseSoundInLoop()
    
    // Play single sound
    func play(_ fileName: String)
    func pause()
    
    // Recording
    func startRecording(forDuration duration: TimeInterval, completion: @escaping ()-> Void)
    func stopRecording()
}

// TODO: consider splitting into 3 separate classes
final class SoundManager: NSObject, SoundManaging {
    // Record
    private var audioRecorder: AVAudioRecorder?
    private var recordingCompletion: (()-> Void)?
    
    // Play in loop
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    
    // Play
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Play in loop
    
    /// - Parameters:
    ///   - duration: in seconds
    func playInLoop(_ fileName: String, duration: TimeInterval, completion: @escaping () -> Void) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") else { return }

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVQueuePlayer(playerItem: item)
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        queuePlayer = player
        
        observeEndOfDuration(duration, asset: asset, completion: completion)

        player.play()
    }
    
    func resumeSoundInLoop() {
        queuePlayer?.play()
    }
    
    func pauseSoundInLoop() {
        queuePlayer?.pause()
    }

    // MARK: - Play
    
    func play(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp4") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)

            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    // MARK: - Recorder
    
    func startRecording(forDuration duration: TimeInterval, completion: @escaping ()-> Void) {
        recordingCompletion = completion
        setupRecorder()
        
        guard let recorder = audioRecorder else { return }
        if recorder.record(forDuration: duration) {
            print("Record successfully started.")
        } else {
            print("Record start failed.")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
    }
    
    // MARK: - Session
    
    func setupSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            session.requestRecordPermission { allowed in
                // TODO: handle record permission result
                if allowed {
                    print("RequestRecordPermission allowed")
                } else {
                    print("RequestRecordPermission not allowed")
                }
            }
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private
    
    private func observeEndOfDuration(_ duration: TimeInterval, asset: AVAsset, completion: @escaping () -> Void) {
        let assetDuration = CMTimeGetSeconds(asset.duration)
        let loopCount = floor(duration / assetDuration)
        let lastLoopDuration = duration - (assetDuration * loopCount)
        
        let time = CMTimeMakeWithSeconds(lastLoopDuration, preferredTimescale: 100)
        let timeValue = NSValue(time: time)
        
        queuePlayer?.addBoundaryTimeObserver(forTimes: [timeValue], queue: DispatchQueue.main) { [weak self] in
            guard let playerLooper = self?.playerLooper, let queuePlayer = self?.queuePlayer else { return }
            
            if playerLooper.loopCount == Int(loopCount) {
                playerLooper.disableLooping()
                queuePlayer.pause()
                completion()
            }
        }
    }
    
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
            audioRecorder = try AVAudioRecorder(url: fileDirectory, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
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
        let str = formatter.string(from: Date())
        return "record-" + str + ".m4a"
    }
}

extension SoundManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingCompletion?()
    }
}
