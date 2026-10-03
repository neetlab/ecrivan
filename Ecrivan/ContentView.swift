//
//  ContentView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/07/31.
//

import SwiftSoup
import SwiftUI

struct ContentView: View {
  @State private var content: String = """
    <html lang="ja">
    <body>
        <h1>私のウェブサイト</h1>
        <p>これは私のウェブサイトです。ご覧いただきありがとうございます！</p>
        <img alt="Welcome" src="https://i.imgur.com/rNsyw1E.png" />
    </body>
    </html>
    """

  var body: some View {
    HStack(alignment: .top) {
      TextField("HTML", text: $content, axis: .vertical)
        .lineLimit(20...30)
        .fixedSize(horizontal: true, vertical: false)
        .font(Font.system(size: 14).monospaced())
        .frame(maxWidth: .infinity, alignment: .leading)
      HTMLView(html: content)
        .fixedSize(horizontal: true, vertical: false)
        .frame(alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
