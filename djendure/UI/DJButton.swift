//
//  DJButton.swift
//  djendure
//
//  Created by Michaela Barcia on 8/19/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import SwiftUI

struct DJButton: View {
    
    var text: String
    
    var action: () -> Void
    
    var color: Color
    
    init(_ text: String, _ action: @escaping () -> Void, color: Color=Color.green) {
        self.text = text
        self.action = action
        self.color = color
    }
    
    var body: some View {
        Button(action: action) {
            Text(text.uppercased()).modifier(DJButtonText())
        }.buttonStyle(DJButtonStyle(color: color))
    }

}

struct DJButtonStyle: ButtonStyle {
    
    var color: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(40)
            .padding(.horizontal, 50)
            .padding(.vertical, 10)
    }
    
}


struct DJButtonText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.custom(DJFont.djBoldFont, size: 20))
    }
}

struct DJButton_Previews: PreviewProvider {
    static var previews: some View {
        DJButton("test", { print("test") })
    }
}
