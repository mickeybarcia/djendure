//
//  HostingController.swift
//  djendure WatchKit Extension
//
//  Created by Michaela Barcia on 8/17/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<PaceView> {
    override var body: PaceView {
        return PaceView()
    }
}
