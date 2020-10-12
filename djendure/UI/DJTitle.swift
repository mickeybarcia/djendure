//
//  DJTitle.swift
//  djendure
//
//  Created by Michaela Barcia on 8/19/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation
import SwiftUI

struct DJTitle: View {
    
    var text: String
    
    var size: Int
    
    init(_ text: String, size: Int=40) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text).modifier(DJTitleModifier(size: size))
    }
    
}

struct DJTitleModifier: ViewModifier {
    var size: Int

    func body(content: Content) -> some View {
        content
            .font(.custom(DJFont.djBoldFont, size: CGFloat(size)))
            .foregroundColor(Color.white)
    }
}

struct DJTitle_Previews: PreviewProvider {
    static var previews: some View {
        DJTitle("hello")
    }
}
