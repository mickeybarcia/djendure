//
//  PaceViewModel.swift
//  djendure
//
//  Created by Michaela Barcia on 8/17/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation
import CoreLocation
import AVFoundation
import SwiftUI

enum PaceStatus {
    case green, yellow, red
}

class PaceViewModel: NSObject, ObservableObject {
    
    // Services
    var spotifyService: SpotifyServiceProtocol
    var locationService: LocationServiceProtocol
    
    // Pace Storage
    private static let kGoalPace = "goalPace"
    private static let kWarningPace = "warningPace"
    private static let defaultGoalPace = 600
    private static let defaultWarningPace = 660
    
    // Error Messages
    var errorMessage = ""
    var showError = false
    private let SPOTIFY_NOT_CONNECTED_ERR = "unable to connect to Spotify, please try again later :("
    private let SPOTIFY_PLAY_ERR = "unable to play music, please try again later :("
    private let SPOTIFY_PAUSE_ERR = "unable to pause music, please try again later :("
    private let LOCATION_ERR = "unable to load location, please try again later :("
      
    // Pace Values to Track
    @Published var cumulativePace = Measurement(value: 0, unit: UnitSpeed.metersPerSecond)
    @Published var currentPace = Measurement(value: 0, unit: UnitSpeed.metersPerSecond)
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []

    
    var goalPace: Measurement<UnitSpeed> = Measurement(
        value: Double(UserDefaults.standard.string(forKey: kGoalPace) ?? "") ?? Double(defaultGoalPace),
        unit: UnitSpeed.secondsPerKilometer
    ) {
        didSet {
            if Locale.current.usesMetricSystem {
                UserDefaults.standard.set(goalPace.value, forKey: PaceViewModel.kGoalPace)
            } else {
                let secondsPerMile = goalPace.converted(to: .secondsPerMile)
                UserDefaults.standard.set(secondsPerMile.value, forKey: PaceViewModel.kGoalPace)
            }
        }
    }
    
    var warningPace: Measurement<UnitSpeed> = Measurement(
        value: Double(UserDefaults.standard.string(forKey: kWarningPace) ?? "") ?? Double(defaultWarningPace),
        unit: UnitSpeed.secondsPerKilometer
    ) {
        didSet {
            if Locale.current.usesMetricSystem {
                UserDefaults.standard.set(warningPace.value, forKey: PaceViewModel.kWarningPace)
            } else {
                let secondsPerMile = warningPace.converted(to: .secondsPerMile)
                UserDefaults.standard.set(secondsPerMile.value, forKey: PaceViewModel.kWarningPace)
            }
        }
    }
    
    private var paceTally = PaceTally()

    var paceStatus: PaceStatus = .green {
        willSet {
            let prevStatus = paceStatus
            if prevStatus == .red
                && (newValue == .green || newValue == .yellow) {
                // if changing from red to yellow or green
                // play music again
                spotifyService.playMusic(onError: {
                    self.setError(self.SPOTIFY_PLAY_ERR)
                })
            } else if prevStatus == .yellow && newValue == .red {
                // if changing from yellow to red
                // stop music
                spotifyService.pauseMusic(onError: {
                    self.setError(self.SPOTIFY_PAUSE_ERR)
                })
            } else if newValue == .yellow {
                // if changing from green to yellow
                // warn by vibrating
                UIDevice.vibrate()
            }
        }
    }
    
    // Timers
    private static let countDownSeconds = 5
    @Published var countDownSecondsLeft = countDownSeconds
    private var countdownTimer: Timer?
    public private(set) var timer: Timer?

    // Run Status
    public private(set) var runInProgress = false
    @Published var enabled = true

    // Pace Displays
    
    var displayCurrentPace: String {
        if Locale.current.usesMetricSystem {
            return formatMinutesAndSeconds(Int(currentPace.value))
        } else {
            let secondsPerMile = currentPace.converted(to: .secondsPerMile)
            return formatMinutesAndSeconds(Int(secondsPerMile.value))
        }
    }
    
    var displayGoalPace: String {
        return formatMinutesAndSeconds(Int(goalPace.value))
    }
    
    var displayWarningPace: String {
        return formatMinutesAndSeconds(Int(warningPace.value))
    }
    
    var displayCumulativePace: String {
        let secondsPerMile = cumulativePace.converted(to: .secondsPerMile)
        return formatMinutesAndSeconds(Int(secondsPerMile.value))
    }
    
    required init(
        spotifyService: SpotifyServiceProtocol,
        locationService: LocationServiceProtocol=LocationService()
    ){
        self.spotifyService = spotifyService
        self.locationService = locationService
        super.init()
        self.locationService.delegate = self
        self.spotifyService.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Format pace for display
    /// - Parameter numSeconds: number of seconds per 1 unit of distance
    /// - Returns: MM:SS formatted string
    private func formatMinutesAndSeconds(_ numSeconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        var paceStr = formatter.string(from: TimeInterval(numSeconds)) ?? ""
        if paceStr[paceStr.startIndex] == "0" {
            paceStr = String(paceStr[paceStr.index(after: paceStr.startIndex)..<paceStr.endIndex])
        }
        return paceStr
    }
    
    /// Start run and enable pace calculator UI
    func enable() {
        enabled = true
        startRun()
    }
    
    /// Stop run and disable pace calculator UI
    func disable() {
        enabled = false
        stopRun()
    }
    
    /// Reset errors, pace timer, run, countdown, locations, pace
    func reset() {
        resetError()
        timer?.invalidate()
        runInProgress = false
        stopCountdown()
        locationService.stopLocationUpdates()
        resetPace()
    }
    
    /// Set pace to 0 and reset status
    private func resetPace() {
        cumulativePace = Measurement(value: 0, unit: UnitSpeed.metersPerSecond)
        currentPace = Measurement(value: 0, unit: UnitSpeed.metersPerSecond)
        locationList.removeAll()
        distance = Measurement(value: 0, unit: UnitLength.meters)
        paceStatus = .green
        paceTally.reset()
    }
    
    private func resetError() {
        showError = false
        errorMessage = ""
    }
    
    private func setError(_ message: String) {
        showError = true
        errorMessage = message
    }

    /// Reset in case, start countdown, location updates, run, pace timer
    func startRun(
        queue: DispatchQueue=DispatchQueue.main,
        completion: @escaping () -> Void={}
    ) {
        reset()
        spotifyService.playMusic(onError: {
            self.setError(self.SPOTIFY_PLAY_ERR)
        })
        startCountdown()
        locationService.startLocationUpdates()
        let countDownTime = DispatchTime.now() + DispatchTimeInterval.seconds(PaceViewModel.countDownSeconds)
        queue.asyncAfter(deadline: countDownTime) {
            self.stopCountdown()
            self.runInProgress = true
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.updatePace()
            }
            completion()
        }
    }
    
    /// Reset and pause music
    func stopRun() {
        reset()
        spotifyService.pauseMusic(onError: {
            self.setError(self.SPOTIFY_PAUSE_ERR)
        })
    }
    
    /// Check tally  and previous status, and update status
    private func updateStatus() {
        if paceTally.greenTally >= 3 {
            // Meeting or over green tally
            // Status is green
            paceStatus = .green
            paceTally.reset()
        } else if paceTally.redTally + paceTally.yellowTally >= 3
            && paceStatus == .green {
            // If current status green
            // If combo of red and yellow tally met
            // Status is yellow
            paceStatus = .yellow
        } else if paceTally.greenTally + paceTally.yellowTally >= 3
            && paceStatus == .red {
            // If current status red
            // If combo of green and yellow tally met
            // Status is yellow
            paceStatus = .yellow
        } else if paceTally.yellowTally >= 3 {
            // Meeting or over yellow tally
            // Status is yellow
            paceStatus = .yellow
            paceTally.reset()
        } else if paceTally.redTally >= 3 {
            // Meeting or over red tally
            // Status is red
            paceStatus = .red
            paceTally.reset()
        }
    }
    
    /// Read pace from the location service and update status
    private func updatePace() {
        paceTally.updateTally(
            currentPace: currentPace,
            goalPace: goalPace,
            warningPace: warningPace
        )
        updateStatus()
    }
    
    /// Countdown to display
    private func startCountdown() {
        countDownSecondsLeft = PaceViewModel.countDownSeconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.countDownSecondsLeft -= 1
        }
    }
    
    /// Reset countdown
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countDownSecondsLeft = 0
    }
        
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension PaceViewModel: LocationServiceDelegate {
    
    func locationChanged(locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            if let lastLocation = locationList.last {
                // current pace = distance delta / time delta from new location to last location
                let distanceDelta = newLocation.distance(from: lastLocation)
                let timeDelta = newLocation.timestamp.timeIntervalSinceReferenceDate
                    - lastLocation.timestamp.timeIntervalSinceReferenceDate
                let speedMagnitude = distanceDelta / abs(timeDelta)
                currentPace = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
                
                // cumulative pace = total distance / total time from first location to new location
                distance = distance + Measurement(value: distanceDelta, unit: UnitLength.meters)
                let totalTime = newLocation.timestamp.timeIntervalSinceReferenceDate
                    - locationList[0].timestamp.timeIntervalSinceReferenceDate
                let totalSpeedMagnitude = distance.value / abs(totalTime)
                cumulativePace = Measurement(value: totalSpeedMagnitude, unit: UnitSpeed.metersPerSecond)
            }
            locationList.append(newLocation)
        }
    }
    
    func locationError(error: Error) {
        setError(LOCATION_ERR)
    }
    
}

extension PaceViewModel: SpotifyDelegate {
    
    func connected() { }
    
    func connectionError(error: Error?) {
        setError(SPOTIFY_NOT_CONNECTED_ERR)
    }
    
}

extension UIDevice {
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}
