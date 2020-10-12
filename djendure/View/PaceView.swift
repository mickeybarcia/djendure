//
//  PaceView.swift
//  djendure
//
//  Created by Michaela Barcia on 9/28/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation
import SwiftUI

struct PaceView: View {
    
    @ObservedObject var vm: PaceViewModel
    
    @State var showGoalPacePicker = false
    @State var showWarningPacePicker = false
    
    @State var newGoalPace = Measurement(value: 0, unit: UnitSpeed.secondsPerKilometer)
    @State var newWarningPace = Measurement(value: 0, unit: UnitSpeed.secondsPerKilometer)
    
    var paceStatusColor: Color {
        if vm.paceStatus == .green {
            return .green
        } else if vm.paceStatus == .yellow {
            return .yellow
        } else {
            return .red
        }
    }
    
    init (vm: PaceViewModel) {
        self.vm = vm
        _newGoalPace = /*State<String>*/.init(initialValue: vm.goalPace)
        _newWarningPace = /*State<String>*/.init(initialValue: vm.warningPace)
    }

    var body: some View {
        let logo = Image("logo")
            .resizable()
            .scaledToFit()
            .frame(width: 40)
        return ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    logo
                    DJTitle("DJ ENDURE")
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    logo
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.green)
                Spacer()
                if vm.showError {
                    DJText(vm.errorMessage)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.red)
                        .padding()
                } else if vm.countDownSecondsLeft != 0 {
                    DJText(String(vm.countDownSecondsLeft), size: 40)
                        .accessibility(identifier: "countdown")
                        .foregroundColor(Color.white)
                        .padding()
                }
                HStack{
                    VStack(alignment: .trailing) {
                        DJText("Cumulative Pace")
                            .foregroundColor(Color.gray)
                        DJText("Current Pace", size: 25)
                            .foregroundColor(paceStatusColor)
                        DJText("Goal Pace")
                            .foregroundColor(Color.white)
                        DJText("Warning Zone")
                            .foregroundColor(Color.white)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        DJText(vm.displayCumulativePace)
                            .foregroundColor(Color.gray)
                        DJText(vm.displayCurrentPace, size: 25)
                            .foregroundColor(paceStatusColor)
                            .accessibility(identifier: "current pace value")
                        DJText(vm.displayGoalPace)
                            .foregroundColor(Color.white)
                        DJText(vm.displayWarningPace)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(35)
                .padding(.leading, 30)
                .padding(.trailing, 30)
                Spacer()
                VStack {
                    if showGoalPacePicker {
                        DJButton("done", saveGoalPace)
                        DJPacePicker(pace: $newGoalPace)
                        Spacer()
                    } else if showWarningPacePicker {
                        DJButton("done", saveWarningPace)
                        DJPacePicker(pace: $newWarningPace)
                        Spacer()
                    } else {
                        DJButton("set goal",  { self.showGoalPacePicker = true })
                        DJButton("set warning zone",  { self.showWarningPacePicker = true })
                        Spacer()
                        if vm.enabled {
                            DJButton(
                                "disable",
                                { self.vm.disable() },
                                color: Color.red
                            ).padding(.bottom, 15)
                        } else {
                            DJButton(
                                "enable",
                                { self.vm.enable() }
                            ).padding(.bottom, 15)
                        }
                    }
                }
            }
        }.onAppear {
            self.vm.startRun()
        }
    }
    
    func saveGoalPace() {
        showGoalPacePicker = false
        vm.goalPace = newGoalPace
    }
    
    func saveWarningPace() {
        showWarningPacePicker = false
        vm.warningPace = newWarningPace
    }

}

struct PaceView_Previews: PreviewProvider {
    static var previews: some View {
        PaceView(vm: PaceViewModel(spotifyService: SpotifyService()))
    }
}
