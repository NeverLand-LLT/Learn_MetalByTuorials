//
//  ContentView.swift
//  03-Pipeline
//
//  Created by Liangyz on 2024/7/27.
//

import SwiftUI



struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
                .border(Color.black, width: 2)
            
            Text("Hello, Metal!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
