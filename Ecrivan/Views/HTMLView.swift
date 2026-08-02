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
        case .img(_, let src):
            return createImgView(src: src)
        }
    }
    
    private func createH1View(text: String) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = NSColor.black
        return label
    }
    
    private func createPView(text: String) -> NSView {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 16)
        label.textColor = NSColor.black
        return label
    }
    
    private func createImgView(src: String) -> NSView {
        let imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        if let url = URL(string: src) {
            imageView.image = NSImage(contentsOf: url)
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
