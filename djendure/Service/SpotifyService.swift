//
//  SpotifyService.swift
//  djendure
//
//  Created by Michaela Barcia on 8/20/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation

protocol SpotifyDelegate {
    
    func connected()
    
    func connectionError(error: Error?)
    
}

protocol SpotifyServiceProtocol {
    
    var delegate: SpotifyDelegate? { get set }
    
    func connect()
    
    func playMusic(onError: @escaping () -> Void)
    
    func pauseMusic(onError: @escaping () -> Void)
    
}

class SpotifyService: NSObject, SpotifyServiceProtocol {
    
    var delegate: SpotifyDelegate?
    
    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string: "djendure://SpotifyAuthentication")!
    private let clientIdentifier = "801c164ce144428b828273ac59af6e5d"
    private var isPaused = true

    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(
            clientID: self.clientIdentifier,
            redirectURL: self.redirectUri
        )
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .error)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SpotifyService.kAccessTokenKey)
        }
    }
    
    func connect() {
        if !UIDevice.isSimulator {
            appRemote.connect()
            if (!appRemote.isConnected) {
                appRemote.authorizeAndPlayURI("")
            }
        }
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        isPaused = playerState.isPaused
    }

}

extension SpotifyService: SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                debugPrint("Error loading player state: " + error.localizedDescription)
            }
        })
        if delegate != nil {
             delegate!.connected()
         }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        appRemote.connect()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        if let errorMessage = error?.localizedDescription {
            debugPrint("Error connecting to Spotify: " + errorMessage)
        } else {
            debugPrint("Error connecting to Spotify")
        }
        if delegate != nil {
            delegate!.connectionError(error: error)
        }
    }
    
    func playMusic(onError: @escaping () -> Void) {
        if isPaused {
            appRemote.playerAPI?.resume({(playerState, error) in
                if let error = error {
                    debugPrint("Error getting player state:" + error.localizedDescription)
                    onError()
                } // else if let playerState = playerState as? SPTAppRemotePlayerState {
                    
                // }
            })
        }
    }
    
    func pauseMusic(onError: @escaping () -> Void) {
        if !isPaused {
            appRemote.playerAPI?.pause({(playerState, error) in
                if let error = error {
                    debugPrint("Error getting player state:" + error.localizedDescription)
                    onError()
                }
            })
        }
    }
    
}
