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

  init(content: String) {
    self.document = try! SwiftSoup.parse(content)
    self.accessibilityTree = AccessibilityTree(element: document)
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
    let accessibilityObject = accessibilityTree.getAccessibleObject(element)
    accessibilityObject?.mapToView(view)
    renderChildNodesAsSubview(node: element, view: view)
    return view
  }

  private func createH1View(_ element: Element) -> NSView {
    let view = NSStackView()
    view.orientation = .vertical
    view.alignment = .leading
    view.distribution = .fill
    let accessibilityObject = accessibilityTree.getAccessibleObject(element)
    accessibilityObject?.mapToView(view)
    let stylesheet = Stylesheet(largeText: true)
    renderChildNodesAsSubview(node: element, view: view, stylesheet: stylesheet)
    return view
  }

  private func createImageView(_ element: Element) -> NSView {
    let src = try! element.attr("src")

    let image = NSImageView()
    image.imageScaling = .scaleProportionallyUpOrDown
    if let url = URL(string: src) {
      image.image = NSImage(contentsOf: url)
    }
    image.translatesAutoresizingMaskIntoConstraints = false

    let accessibilityObject = accessibilityTree.getAccessibleObject(element)
    accessibilityObject?.mapToView(image)

    return image
  }

  private func createLabelView(_ element: Element) -> NSView {
    let view = NSStackView()
    renderChildNodesAsSubview(node: element, view: view)
    let accessibilityObject = accessibilityTree.getAccessibleObject(element)
    accessibilityObject?.mapToView(view)
    view.setAccessibilityRole(.group)
    view.setAccessibilitySubrole(nil)
    view.setAccessibilityRoleDescription("グループ")
    return view
  }

  private func createInputView(_ element: Element) -> NSView? {
    let type = try! element.attr("type")
    switch type {
    case "text", "email":
      let input = NSTextField(labelWithString: "hello")
      input.isEditable = true
      input.wantsLayer = true
      input.layer?.borderWidth = 1
      input.layer?.borderColor = NSColor.gray.cgColor
      let accessibilityObject = accessibilityTree.getAccessibleObject(element)
      accessibilityObject?.mapToView(input)
      return input
    case "password":
      let input = NSTextField(labelWithString: "hello")
      input.isEditable = true
      input.wantsLayer = true
      input.layer?.borderWidth = 1
      input.layer?.borderColor = NSColor.gray.cgColor
      let accessibilityObject = accessibilityTree.getAccessibleObject(element)
      accessibilityObject?.mapToView(input)
      input.setAccessibilityRole(.textField)
      input.setAccessibilitySubrole(.secureTextField)
      input.setAccessibilityRoleDescription("secure text field")
      return input
    case "checkbox":
      let checkbox = NSView()
      checkbox.wantsLayer = true
      checkbox.layer?.borderWidth = 1
      checkbox.layer?.borderColor = NSColor.gray.cgColor
      checkbox.widthAnchor.constraint(equalToConstant: 16).isActive = true
      checkbox.heightAnchor.constraint(equalToConstant: 16).isActive = true
      let accessibilityObject = accessibilityTree.getAccessibleObject(element)
      accessibilityObject?.mapToView(checkbox)
      return checkbox
    default:
      return nil
    }
  }

  private func createButtonView(_ element: Element) -> NSView {
    let view = NSStackView()

    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.lightGray.cgColor
    view.layer?.borderWidth = 1
    view.layer?.borderColor = NSColor.black.cgColor
    view.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    let accessibilityObject = accessibilityTree.getAccessibleObject(element)
    accessibilityObject?.mapToView(view)
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
