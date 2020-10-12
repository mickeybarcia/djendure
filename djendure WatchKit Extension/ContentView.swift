//
//  PaceView.swift
//  djendure WatchKit Extension
//
//  Created by Michaela Barcia on 8/17/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import SwiftUI

struct PaceView: View {
    var body: some View {
        VStack {
            Text("DJ ENDURE")
            HStack {
                Text("Current Pace")
                Text("8:01")
            }
            HStack {
                Text("Goal")
                Text("8:00")
            }
            HStack {
                Text("Red Zone")
                Text("8:30")
            }
        }
    }
}

struct PaceView_Previews: PreviewProvider {
    static var previews: some View {
        PaceView()
    }
}
