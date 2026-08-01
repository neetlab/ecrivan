//
//  ContentView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/07/31.
//

import SwiftUI
import SwiftSoup

struct ContentView: View {
    @State private var content: String = "";
    
    var body: some View {
        VStack {
            TextField("HTML", text: $content, axis: .vertical)
                .lineLimit(5...20)
                .frame(minWidth: 0, maxWidth: .infinity)
            Divider()
            HTMLView(html: content)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
