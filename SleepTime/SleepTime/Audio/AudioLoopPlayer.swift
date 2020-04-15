//
//  AudioLoopPlayer.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 14.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

final class AudioLoopPlayer {
    private var queuePlayer: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?
 
    /// Play file in the loop during given duration time.
    /// - Parameters:
    ///   - fileName: File name to play.
    ///   - duration: Duration time in seconds.
    ///   - completion: Completion of playing. It will not be called while on pause.
    func play(_ fileName: String, duration: TimeInterval, completion: (() -> Void)? = nil) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else { return }
        
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
    
    func resume() {
        queuePlayer?.play()
    }
    
    func stop() {
        playerLooper?.disableLooping()
        queuePlayer?.pause()
        queuePlayer?.removeAllItems()
        
        queuePlayer = nil
        playerLooper = nil
    }
    
    // MARK: - Private
    
    private func observeEndOfDuration(_ duration: TimeInterval, asset: AVAsset, completion: (() -> Void)?) {
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
                completion?()
            }
        }
    }
}
