//
//  HTMLView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftSoup
import SwiftUI

struct Stylesheet {
  let fontSize: CGFloat
  let fontWeight: NSFont.Weight
}

struct HTMLView: NSViewRepresentable {
  var html: String

  func makeNSView(context: Context) -> NSStackView {
    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading

    stack.setAccessibilityElement(true)
    stack.setAccessibilityRole(.webAreaRole)

    return stack
  }

  func updateNSView(_ stack: NSStackView, context: Context) {
    stack.views.forEach { $0.removeFromSuperview() }

    let document = try! SwiftSoup.parse(html)
    let body = document.body()!
    let accessibilityTree = AccessibilityTree(element: document)

    for childNode in body.getChildNodes() {
      if let subview = render(childNode, accessibilityTree) {
        stack.addArrangedSubview(subview)
      }
    }
  }

  func render(
    _ childNode: Node,
    _ accessibilityTree: AccessibilityTree,
    stylesheet: Stylesheet? = nil
  ) -> NSView? {
    if let textNode = childNode as? TextNode {
      if textNode.isBlank() {
        return nil
      }
      return createTextNode(textNode, stylesheet: stylesheet)
    }

    if let element = childNode as? Element {
      switch element.tagName() {
      case "h1":
        return createH1View(element, accessibilityTree)
      case "p":
        return createPView(element, accessibilityTree)
      case "img":
        return createImgView(element, accessibilityTree)
      case "form":
        return createFormView(element, accessibilityTree)
      case "label":
        return createLabelView(element, accessibilityTree)
      case "input":
        return createInputView(element, accessibilityTree)
      case "button":
        return createButtonView(element, accessibilityTree)
      default:
        return nil
      }
    }

    return nil
  }

  private func createH1View(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let heading = NSStackView()
    heading.orientation = .vertical
    heading.alignment = .leading
    heading.distribution = .fill

    let accessibilityObject = accessibilityTree.getAccessibilityObject(element)
    accessibilityObject?.mapToView(heading)

    for childNode in element.getChildNodes() {
      if let subview = render(
        childNode,
        accessibilityTree,
        stylesheet: Stylesheet(fontSize: 32, fontWeight: .bold)
      ) {
        heading.addArrangedSubview(subview)
      }
    }

    return heading
  }

  private func createPView(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let paragraph = NSStackView()
    paragraph.orientation = .vertical
    paragraph.alignment = .leading
    paragraph.distribution = .fill

    let accessibilityObject = accessibilityTree.getAccessibilityObject(element)
    accessibilityObject?.mapToView(paragraph)

    for childNode in element.getChildNodes() {
      if let subview = render(childNode, accessibilityTree) {
        paragraph.addArrangedSubview(subview)
      }
    }

    return paragraph
  }

  private func createImgView(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let src = try! element.attr("src")

    let image = NSImageView()
    image.imageScaling = .scaleProportionallyUpOrDown
    if let url = URL(string: src) {
      image.image = NSImage(contentsOf: url)
    }
    image.translatesAutoresizingMaskIntoConstraints = false

    let accessibilityObject = accessibilityTree.getAccessibilityObject(element)
    accessibilityObject?.mapToView(image)

    return image
  }

  private func createFormView(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let form = NSStackView()
    form.orientation = .vertical
    form.alignment = .leading
    form.distribution = .fill

    for childNode in element.getChildNodes() {
      if let subview = render(childNode, accessibilityTree) {
        form.addArrangedSubview(subview)
      }
    }

    let accessibilityObject = accessibilityTree.getAccessibilityObject(element)
    accessibilityObject?.mapToView(form)

    return form
  }

  private func createLabelView(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let label = NSStackView()

    for childNode in element.getChildNodes() {
      if let subview = render(childNode, accessibilityTree) {
        label.addArrangedSubview(subview)
      }
    }

    let accessibilityObject = accessibilityTree.getAccessibilityObject(element)
    accessibilityObject?.mapToView(label)
    label.setAccessibilityRole(.group)
    label.setAccessibilitySubrole(nil)
    label.setAccessibilityRoleDescription("グループ")

    return label
  }

  private func createInputView(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let type = try! element.attr("type")
    switch type {

    case "text", "email":
      let input = NSTextField(labelWithString: "hello")
      input.isEditable = true
      input.wantsLayer = true
      input.layer?.borderWidth = 1
      input.layer?.borderColor = NSColor.gray.cgColor
      let accessibilityObject = accessibilityTree.getAccessibilityObject(
        element
      )
      accessibilityObject?.mapToView(input)
      return input

    case "checkbox":
      let checkbox = NSView()
      checkbox.wantsLayer = true
      checkbox.layer?.borderWidth = 1
      checkbox.layer?.borderColor = NSColor.gray.cgColor
      checkbox.widthAnchor.constraint(equalToConstant: 16).isActive = true
      checkbox.heightAnchor.constraint(equalToConstant: 16).isActive = true
      let accessibilityObject = accessibilityTree.getAccessibilityObject(
        element
      )
      accessibilityObject?.mapToView(checkbox)
      return checkbox

    default:
      return NSView()
    }
  }

  private func createButtonView(
    _ element: Element,
    _ accessibilityTree: AccessibilityTree
  ) -> NSView {
    let button = NSStackView()

    button.wantsLayer = true
    button.layer?.backgroundColor = NSColor.gray.cgColor
    button.layer?.borderWidth = 1
    button.layer?.borderColor = NSColor.black.cgColor
    button.edgeInsets = NSEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    let accessibilityObject = accessibilityTree.getAccessibilityObject(element)
    accessibilityObject?.mapToView(button)
    
    for childNode in element.getChildNodes() {
      if let subview = render(childNode, accessibilityTree) {
        button.addArrangedSubview(subview)
      }
    }

    return button
  }

  private func createTextNode(
    _ textNode: TextNode,
    stylesheet: Stylesheet? = nil
  )
    -> NSView
  {
    let text = textNode.text()
    let label = NSTextField(labelWithString: text)

    if let stylesheet = stylesheet {
      label.font = .systemFont(
        ofSize: stylesheet.fontSize,
        weight: stylesheet.fontWeight,
      )
    }

    return label
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
