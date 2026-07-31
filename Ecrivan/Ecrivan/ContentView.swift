//
//  ContentView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/07/31.
//

import SwiftUI

struct ContentView: View {
    @State private var content: String = "";
    
    var body: some View {
        HStack(alignment: .top) {
            TextField("HTML", text: $content, axis: .vertical)
                .lineLimit(5...20)
                .frame(minWidth: 0, maxWidth: .infinity)
            Text("My content lives here")
                .frame(minWidth: 0, maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
