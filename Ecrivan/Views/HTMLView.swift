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
        for el in createDOMElements(input: html) {
            stack.addArrangedSubview(view(for: el))
        }
    }

    func view(for el: DOMElement) -> NSView {
        switch el.kind {
        case .h1(let text):
            return createH1View(text: text)
        case .p(let text):
            return createPView(text: text)
        case .img(let alt, let src):
            return createImgView(src: src, alt: alt)
        }
    }
    
    private func createH1View(text: String) -> NSView {
        let heading = NSView()
        let label = appendText(text: text, parent: heading)
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return heading;
    }
    
    private func createPView(text: String) -> NSView {
        let paragraph = NSView()
        let label = appendText(text: text, parent: paragraph)
        label.font = .systemFont(ofSize: 16)
        return paragraph
    }
    
    private func createImgView(src: String, alt: String) -> NSView {
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
