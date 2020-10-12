//
//  DJText.swift
//  djendure
//
//  Created by Michaela Barcia on 8/19/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation

import SwiftUI

struct DJText: View {
    
    var text: String
    
    var size: Int
        
    init(_ text: String, size: Int=20) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .modifier(DJTextModifier(size: size))
    }
    
}

struct DJTextModifier: ViewModifier {
    var size: Int

    func body(content: Content) -> some View {
        content.font(.custom(DJFont.djFont, size: CGFloat(size)))
    }
}

struct DJText_Previews: PreviewProvider {
    static var previews: some View {
        DJText("hello")
    }
}
