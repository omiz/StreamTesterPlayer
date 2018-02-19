//
//  StreamPlayer.swift
//  Stream test
//
//  Created by Omar Allaham on 19.02.18.
//

import Foundation
import UIKit
import AVKit

enum StreamError: Error {
    case unknown
    case unvalidURL
    case networkError
}

protocol StreamPlayerDelegate {
    func streamPlayerFailedToPlayToEndTime()
    func streamPlayerPlaybackStalled()
}

typealias URLSetupCompletion = ((StreamError?) -> Void)

class StreamPlayer: NSObject {
    
    static let shared = StreamPlayer()
    
    let player = AVPlayer()
    
    var item: AVPlayerItem? {
        willSet {
            guard item != nil else { return }
            
            removeObserver()
        }
    }
    
    var isPlaying: Bool {
        return player.rate == 1 && player.error == nil
    }
    
    var url: URL?
    
    var delegate: StreamPlayerDelegate?
    
    override init() {
        super.init()
        
        observeErrors()
    }
    
    func setup(urlString: String, completion: @escaping URLSetupCompletion) {
        
        func complete(_ error: StreamError?) { completion(error) }
        
        let urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard urlString != url?.absoluteString else { return complete(nil) }
        
        guard let url = URL(string: urlString) else { return complete(.unvalidURL) }
        
        let asset = AVAsset(url: url)
        
        guard asset.isPlayable else { return complete(nil) }
        
        asset.cancelLoading()
        
        item = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: item)
        
        complete(nil)
    }
    
    func observeErrors() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemNewErrorLogEntry(_:)), name: .AVPlayerItemNewErrorLogEntry, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemPlaybackStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
    }
    
    func play(url: String, completion: @escaping URLSetupCompletion) {
        setup(urlString: url) {
            $0 == nil ? self.play() : ()
            completion($0)
        }
    }
    
    func play() {
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        player.volume = 1
        player.play()
    }
    
    func pause() {
        player.pause()
        
        try? AVAudioSession.sharedInstance().setActive(false)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    @objc func itemFailedToPlayToEndTime(_ notification: Notification) {
        let error = notification.userInfo?.first(where: { $0.value is Error }) as? Error
        
        print(error?.localizedDescription ?? "No error description for itemFailedToPlayToEndTime")
        
        delegate?.streamPlayerFailedToPlayToEndTime()
    }
    
    @objc func itemPlaybackStalled(_ notification: Notification) {
        let error = notification.userInfo?.first(where: { $0.value is Error }) as? Error
        
        print(error?.localizedDescription ?? "No error description for itemPlaybackStalled")
        
        delegate?.streamPlayerPlaybackStalled()
    }
    
    @objc func itemNewErrorLogEntry(_ notification: Notification) {
        let error = notification.userInfo?.first(where: { $0.value is Error }) as? Error
        
        print(error?.localizedDescription ?? "No error description for itemNewErrorLogEntry")
        
        delegate?.streamPlayerPlaybackStalled()
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeObserver()
    }
}
