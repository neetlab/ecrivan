//
//  HTMLRenderer.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/05.
//
import AppKit
import SwiftSoup

struct Stylesheet {
  var largeText: Bool = false
}

final class HTMLRenderer {
  let document: Document
  let accessibilityTree: AccessibilityTree
  let disableMapping: Bool

  init(content: String, disableMapping: Bool = false) {
    self.document = try! SwiftSoup.parse(content)
    self.accessibilityTree = AccessibilityTree(element: document)
    self.disableMapping = disableMapping
  }

  func render() -> NSView? {
    return renderNode(self.document)
  }

  private func renderNode(_ node: Node, _ stylesheet: Stylesheet? = nil)
    -> NSView?
  {
    if let document = node as? Document {
      return createDocumentView(document)
    }

    if let textNode = node as? TextNode {
      if textNode.isBlank() { return nil }
      return createTextNodeView(textNode, stylesheet)
    }

    if let element = node as? Element {
      switch element.tagName() {
      case "div", "p", "form":
        return createContainerView(element)
      case "h1":
        return createH1View(element)
      case "img":
        return createImageView(element)
      case "label":
        return createLabelView(element)
      case "input":
        return createInputView(element)
      case "button":
        return createButtonView(element)
      default:
        return nil
      }
    }

    return nil
  }

  private func renderChildNodesAsSubview(
    node: Node,
    view: NSStackView,
    stylesheet: Stylesheet? = nil
  ) {
    for childNode in node.getChildNodes() {
      if let subview = renderNode(childNode, stylesheet) {
        view.addArrangedSubview(subview)
      }
    }
  }

  private func createDocumentView(_ element: Document) -> NSView? {
    let view = NSStackView()
    view.orientation = .vertical
    view.alignment = .leading
    view.distribution = .fill
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.white.cgColor

    let title = try! document.title()
    view.setAccessibilityRole(.webAreaRole)
    view.setAccessibilityLabel(title)

    guard let body = document.body() else {
      return nil
    }
    renderChildNodesAsSubview(node: body, view: view)
    return view
  }

  private func createContainerView(_ element: Element) -> NSView {
    let view = NSStackView()
    view.orientation = .vertical
    view.alignment = .leading
    view.distribution = .fill
    if !self.disableMapping {
      accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
    }
    renderChildNodesAsSubview(node: element, view: view)
    return view
  }

  private func createH1View(_ element: Element) -> NSView {
    let view = NSStackView()
    view.orientation = .vertical
    view.alignment = .leading
    view.distribution = .fill
    if !self.disableMapping {
      accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
    }
    let stylesheet = Stylesheet(largeText: true)
    renderChildNodesAsSubview(node: element, view: view, stylesheet: stylesheet)
    return view
  }

  private func createImageView(_ element: Element) -> NSView {
    let src = try! element.attr("src")

    let view = NSImageView()
    view.imageScaling = .scaleProportionallyUpOrDown
    if let url = URL(string: src) {
      view.image = NSImage(contentsOf: url)
    }
    view.translatesAutoresizingMaskIntoConstraints = false

    if !self.disableMapping {
      accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
    }

    return view
  }

  private func createLabelView(_ element: Element) -> NSView {
    let view = NSStackView()
    renderChildNodesAsSubview(node: element, view: view)
    if !self.disableMapping {
      accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
      view.setAccessibilityRole(.group)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityRoleDescription("グループ")
    }
    return view
  }

  private func createInputView(_ element: Element) -> NSView? {
    let type = try! element.attr("type")
    switch type {
    case "text", "email":
      let view = NSTextField(labelWithString: "hello")
      view.isEditable = true
      view.wantsLayer = true
      view.layer?.borderWidth = 1
      view.layer?.borderColor = NSColor.gray.cgColor
      if !self.disableMapping {
        accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
      }
      return view
    case "password":
      let view = NSTextField(labelWithString: "hello")
      view.isEditable = true
      view.wantsLayer = true
      view.layer?.borderWidth = 1
      view.layer?.borderColor = NSColor.gray.cgColor
      if !self.disableMapping {
        accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
        view.setAccessibilityRole(.textField)
        view.setAccessibilitySubrole(.secureTextField)
        view.setAccessibilityRoleDescription("secure text field")
      }
      return view
    case "checkbox":
      let view = NSView()
      view.wantsLayer = true
      view.layer?.borderWidth = 1
      view.layer?.borderColor = NSColor.gray.cgColor
      view.widthAnchor.constraint(equalToConstant: 16).isActive = true
      view.heightAnchor.constraint(equalToConstant: 16).isActive = true
      if !self.disableMapping {
        accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
      }
      return view
    default:
      return nil
    }
  }

  private func createButtonView(_ element: Element) -> NSView {
    let view = NSStackView()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor(white: 0.92, alpha: 1).cgColor
    view.layer?.borderWidth = 1
    view.layer?.borderColor = NSColor.black.cgColor
    view.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    view.setHuggingPriority(.required, for: .horizontal)

    if !self.disableMapping {
      accessibilityTree.getAccessibleObject(element)?.mapToAccessibilityAPI(view)
    }
    renderChildNodesAsSubview(node: element, view: view)

    return view
  }

  private func createTextNodeView(
    _ textNode: TextNode,
    _ stylesheet: Stylesheet? = nil
  )
    -> NSView
  {
    let text = textNode.text()
    let view = NSTextField(labelWithString: text)
    view.textColor = NSColor.black

    if let stylesheet = stylesheet {
      if stylesheet.largeText {
        view.font = .systemFont(ofSize: 32, weight: .bold)
      }
    }

    return view
  }
}
