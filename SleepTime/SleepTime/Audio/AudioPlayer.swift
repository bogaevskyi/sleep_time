//
//  AudioPlayer.swift
//  SleepTime
//
//  Created by Andrew Bogaevskyi on 14.04.2020.
//  Copyright © 2020 Andrew Bogaevskyi. All rights reserved.
//

import AVFoundation

final class AudioPlayer {
    private var player: AVAudioPlayer?
    
    func play(_ fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("AVAudioPlayer error \(error.localizedDescription)")
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func resume() {
        player?.play()
    }
    
    func stop() {
        player?.stop()
        player = nil
    }
}
