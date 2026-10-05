//
//  HTMLView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftSoup
import SwiftUI

struct HTMLView: NSViewRepresentable {
  var html: String

  func makeNSView(context: Context) -> NSStackView {
    let stack = NSStackView()
    return stack
  }

  func updateNSView(_ stack: NSStackView, context: Context) {
    stack.views.forEach { $0.removeFromSuperview() }
    let htmlRenderer = HTMLRenderer(content: html)
    if let view = htmlRenderer.render() {
      stack.addArrangedSubview(view)
    }
  }
}

#Preview {
  HTMLView(
    html: """
      <h1>私のウェブサイト</h1>
      <p>これは私のウェブサイトです</p>
      <img alt="ようこそ" src="https://i.imgur.com/rNsyw1E.png" />
      <input type="checkbox" />
      """
  )
}
