//
//  AudioPlayer.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

final class AudioPlayer: NSObject {
    // Record
    private var audioRecorder: AVAudioRecorder?
    
    // Play in loop
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    
    
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
    
    func pause() {
        queuePlayer?.pause()
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
    
    
    // MARK: - Recorder
    
    
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
            audioRecorder?.prepareToRecord()
        } catch {
            print("AVAudioRecorder error: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        print("startRecording")
        setupRecorder()
        audioRecorder?.record()
    }
    
    func stopRecording() {
        print("stopRecording")
        audioRecorder?.stop()
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
