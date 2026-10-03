import SwiftSoup
//
//  HTMLView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftUI

struct HTMLView: NSViewRepresentable {
  var html: String

  func makeNSView(context: Context) -> NSStackView {
    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading

    stack.wantsLayer = true
    stack.layer?.backgroundColor = NSColor.white.cgColor
    stack.setAccessibilityElement(true)
    stack.setAccessibilityRole(.webAreaRole)

    return stack
  }

  func updateNSView(_ stack: NSStackView, context: Context) {
    stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

    let document = try! SwiftSoup.parse(html)
    let body = document.body()!

    for child in body.children() {
      stack.addArrangedSubview(render(element: child))
    }
  }

  func render(element: Element) -> NSView {
    switch element.tagName() {
    case "h1":
      return createH1View(element: element)
    case "p":
      return createPView(element: element)
    case "img":
      return createImgView(element: element)
    default:
      return NSView()
    }
  }

  private func createH1View(element: Element) -> NSView {
    let heading = NSView()
    let text = try! element.text()
    let label = appendText(text: text, parent: heading)
    label.font = .systemFont(ofSize: 32, weight: .bold)
    return heading
  }

  private func createPView(element: Element) -> NSView {
    let paragraph = NSView()
    let text = try! element.text()
    let label = appendText(text: text, parent: paragraph)
    label.font = .systemFont(ofSize: 16)
    return paragraph
  }

  private func createImgView(element: Element) -> NSView {
    let src = try! element.attr("src")
    let alt = try! element.attr("alt")

    let imageView = NSImageView()
    imageView.imageScaling = .scaleProportionallyUpOrDown
    if let url = URL(string: src) {
      imageView.image = NSImage(contentsOf: url)
    }
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }

  // これ難しすぎてよくわかっていません
  private func appendText(text: String, parent: NSView) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.translatesAutoresizingMaskIntoConstraints = false
    parent.addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
      label.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
      label.topAnchor.constraint(equalTo: parent.topAnchor),
      label.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
    ])
    return label
  }
}

#Preview {
  HTMLView(
    html: """
      <h1>私のウェブサイト</h1>
      <p>これは私のウェブサイトです</p>
      <img alt="ようこそ" src="https://i.imgur.com/rNsyw1E.png" />
      """
  )
}
