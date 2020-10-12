//
//  MockSpotifyService.swift
//  djendureTests
//
//  Created by Michaela Barcia on 9/29/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

@testable import djendure
import Foundation

public class MockSpotifyService: SpotifyServiceProtocol {
    
    public var delegate: SpotifyDelegate?
    
    public func connect() { }
    
    public func playMusic(onError: @escaping () -> Void) { }
    
    public func pauseMusic(onError: @escaping () -> Void) { }

}
