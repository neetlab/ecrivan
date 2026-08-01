//
//  HTMLH1View.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftUI
import AppKit

final class HTMLH1View: NSView {
    var text: String = "" {
        didSet {
            guard text != oldValue else { return }
            needsDisplay = true
            invalidateIntrinsicContentSize()
            NSAccessibility.post(element: self, notification: .valueChanged)
        }
    }

    static func attributedString(for text: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byWordWrapping

        return NSAttributedString(string: text, attributes: [
            .font: NSFont.systemFont(ofSize: 50, weight: .bold),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: style,
        ])
    }

    static func size(for text: String, fittingWidth width: CGFloat) -> NSSize {
        // .infinity を渡すと CoreText 側で NaN になることがあるので有限値に丸める
        let w = width.isFinite ? max(width, 0) : 100_000

        let rect = attributedString(for: text).boundingRect(
            with: NSSize(width: w, height: 100_000),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return NSSize(width: ceil(rect.width), height: ceil(rect.height))
    }
    
    override var isFlipped: Bool { true }   // 原点を左上に

    override var intrinsicContentSize: NSSize {
        Self.size(for: text, fittingWidth: .infinity)
    }

    override func draw(_ dirtyRect: NSRect) {
        Self.attributedString(for: text).draw(
            with: bounds,
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
    }

    override func isAccessibilityElement() -> Bool { true }
    override func accessibilityRole() -> NSAccessibility.Role? { .headingRole }
    override func accessibilitySubrole() -> NSAccessibility.Subrole? { nil }
    override func accessibilityLabel() -> String? { text }
    override func accessibilityValue() -> Any? { 1 }   // 見出しレベル (h1)
}

struct HTMLH1ViewRepresentable: NSViewRepresentable {
    var text: String

    func makeNSView(context: Context) -> HTMLH1View {
        HTMLH1View()
    }

    func updateNSView(_ nsView: HTMLH1View, context: Context) {
        nsView.text = text
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize,
        nsView: HTMLH1View,
        context: Context
    ) -> CGSize? {
        HTMLH1View.size(for: text, fittingWidth: proposal.width ?? .infinity)
    }
}
