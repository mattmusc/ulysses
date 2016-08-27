//
//  MusicPlayer.swift
//  Ulysses
//
//  Created by Matteo Muscella on 27/08/16.
//  Copyright © 2016 The Ulysses Team. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayer: NSObject {
    var backgroundMusicPlayer = AVAudioPlayer()
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(filename, withExtension: nil)
        guard let newURL = url else {
            print("Could not find file: \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            backgroundMusicPlayer.numberOfLoops = -1
            backgroundMusicPlayer.prepareToPlay()
            backgroundMusicPlayer.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
}
