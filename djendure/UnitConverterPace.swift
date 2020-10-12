//
//  UnitConverterPacr.swift
//  djendure
//
//  Created by Michaela Barcia on 8/18/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation

class UnitConverterPace: UnitConverter {
  private let coefficient: Double
  
  init(coefficient: Double) {
    self.coefficient = coefficient
  }
  
  override func baseUnitValue(fromValue value: Double) -> Double {
    return reciprocal(value * coefficient)
  }
  
  override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
    return reciprocal(baseUnitValue * coefficient)
  }
  
  private func reciprocal(_ value: Double) -> Double {
    guard value != 0 else { return 0 }
    return 1.0 / value
  }
}

extension UnitSpeed {
  class var secondsPerMeter: UnitSpeed {
    return UnitSpeed(symbol: "sec/m", converter: UnitConverterPace(coefficient: 1))
  }
  
  class var secondsPerKilometer: UnitSpeed {
    return UnitSpeed(symbol: "s/km", converter: UnitConverterPace(coefficient: 1 / 1000.0))
  }
  
  class var secondsPerMile: UnitSpeed {
    return UnitSpeed(symbol: "s/mi", converter: UnitConverterPace(coefficient: 1 / 1609.34))
  }
}
