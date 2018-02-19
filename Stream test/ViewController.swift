//
//  ViewController.swift
//  Stream test
//
//  Created by Omar Allaham on 19.02.18.
//

import UIKit

class ViewController: UIViewController, StreamPlayerDelegate {
    
    let url = "http://mp3ad.egofm.c.nmdn.net/ps-egofm_192/livestream.mp3"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        StreamPlayer.shared.delegate = self
    }

    @IBAction func togglePlayAction(_ sender: UIButton) {
        let isPlaying = StreamPlayer.shared.isPlaying
        
        StreamPlayer.shared.setup(urlString: url) {
            guard $0 == nil else { return self.alertError() }
            
            isPlaying ? StreamPlayer.shared.pause() : StreamPlayer.shared.play()
            
            sender.setTitleColor(isPlaying ? self.view.tintColor : .red, for: .normal)
        }
    }
    
    @objc func alertError() {
        let alert = UIAlertController(title: "Error", message: "can not play because of an error", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true)
    }
    
    func streamPlayerFailedToPlayToEndTime() {
        performSelector(onMainThread: #selector(alertError), with: nil, waitUntilDone: false)
    }
    
    func streamPlayerPlaybackStalled() {
        performSelector(onMainThread: #selector(alertError), with: nil, waitUntilDone: false)
    }
}

