//
//  SceneDelegate.swift
//  djendure
//
//  Created by Michaela Barcia on 8/17/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let spotifyService = SpotifyService()
    lazy var contentView = PaceView(
        vm: PaceViewModel(spotifyService: spotifyService)
    )
    
    private func shouldInitRootView() -> Bool {
      return NSClassFromString("XCTest") == nil && ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        let parameters = spotifyService.appRemote.authorizationParameters(from: url)
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            spotifyService.accessToken = access_token
        } else if let _ = parameters?[SPTAppRemoteErrorDescriptionKey] {

        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // self.appRemote.disconnect()
    }

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if shouldInitRootView() {
                window.rootViewController = UIHostingController(rootView: contentView)
                spotifyService.connect()
            }
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}
