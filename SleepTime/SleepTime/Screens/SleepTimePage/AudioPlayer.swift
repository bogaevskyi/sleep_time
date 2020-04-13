//
//  AudioPlayer.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 12.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

final class AudioPlayer {
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
    
    init() {
        setupSession()
    }
    
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
    
    private func setupSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
}
