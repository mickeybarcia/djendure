//
//  DJPacePicker.swift
//  djendure
//
//  Created by Michaela Barcia on 8/19/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import SwiftUI

struct DJPacePicker: View {
    
    @Binding var goalPace: Measurement<UnitSpeed>
    
    @State var goalMinutes: Int = 0
    @State var goalSeconds: Int = 0
    
    init(pace: Binding<Measurement<UnitSpeed>>) {
        _goalPace = pace
        _goalMinutes = /*State<String>*/.init(initialValue: Int(pace.wrappedValue.value / 60))
        _goalSeconds = /*State<String>*/.init(initialValue: Int(pace.wrappedValue.value) % 60)
    }
    
    func updatePace(seconds: Double) {
        if Locale.current.usesMetricSystem {
            self.goalPace = Measurement(value: Double(seconds), unit: UnitSpeed.secondsPerKilometer)
        } else {
            self.goalPace = Measurement(value: Double(seconds), unit: UnitSpeed.secondsPerMile)
        }
    }
    
    var body: some View {
        let minBinding = Binding<Int>(
        get: { self.goalMinutes },
        set: {
            self.goalMinutes = $0
            let seconds = (self.goalMinutes * 60) + self.goalSeconds
            self.updatePace(seconds: Double(seconds))
        })
        let secBinding = Binding<Int>(
        get: { self.goalSeconds },
        set: {
            self.goalSeconds = $0
            let value = (self.goalMinutes * 60) + self.goalSeconds
            self.updatePace(seconds: Double(value))
        })
        return HStack {
            Picker("min", selection: minBinding) {
                ForEach(0 ..< 60) {
                    DJText(String($0).count == 1 ? "0\($0)" : "\($0)")
                        .foregroundColor(Color.white)
                }
            }
            .frame(width: 100)
            .clipped()
            Spacer()
            DJText(":").foregroundColor(Color.white)
            Spacer()
            Picker("sec", selection: secBinding) {
                ForEach(0 ..< 60) {
                    DJText(String($0).count == 1 ? "0\($0)" : "\($0)")
                        .foregroundColor(Color.white)
                }
            }
            .frame(width: 100)
            .clipped()
        }.padding(60)
        .frame(height: 200)
    }
}

struct DJPacePicker_Previews: PreviewProvider {
    static var previews: some View {
        DJPacePicker(pace: Binding.constant(Measurement(value: 0, unit: UnitSpeed.secondsPerMile)))
    }
}
