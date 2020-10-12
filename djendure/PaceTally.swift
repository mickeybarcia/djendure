//
//  PaceTally.swift
//  djendure
//
//  Created by Michaela Barcia on 9/6/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation

class PaceTally {
    
    public private(set) var greenTally = 0
    public private(set) var redTally = 0
    public private(set) var yellowTally = 0
        
    func addGreen() {
        greenTally += 1
    }
    
    func addRed() {
        redTally += 1
    }
    
    func addYellow() {
        yellowTally += 1
    }
    
    func reset() {
        greenTally = 0
        redTally = 0
        yellowTally = 0
    }
    
    func updateTally(currentPace: Measurement<UnitSpeed>, goalPace: Measurement<UnitSpeed>, warningPace: Measurement<UnitSpeed>) {
        if currentPace > goalPace {
            self.addGreen()
        } else if currentPace > warningPace {
            self.addYellow()
        } else {
            self.addRed()
        }
    }
    
}
