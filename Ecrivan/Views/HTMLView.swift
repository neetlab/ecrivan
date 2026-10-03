import SwiftSoup
//
//  HTMLView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
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
    print(body.getChildNodes())

    for childNode in body.getChildNodes() {
      if let subview = render(childNode) {
        stack.addView(subview, in: .top)
      }
    }
  }

  func render(_ childNode: Node, stylesheet: Stylesheet? = nil) -> NSView? {
    if let textNode = childNode as? TextNode {
      if textNode.isBlank() {
        return nil
      }
      print("trying to text " + textNode.text())
      return createTextNode(textNode, stylesheet: stylesheet)
    }

    if let element = childNode as? Element {
      print("trying to render " + element.tagName())
      switch element.tagName() {
      case "h1":
        return createH1View(element)
      case "p":
        return createPView(element)
      case "img":
        return createImgView(element)
      case "form":
        return createFormView(element)
      case "label":
        return createLabelView(element)
      case "input":
        return createInputView(element)
      default:
        return nil
      }
    }

    return nil
  }

  private func createH1View(_ element: Element) -> NSView {
    let heading = NSStackView()
    heading.orientation = .vertical
    heading.alignment = .leading
    heading.distribution = .fill

    heading.setAccessibilityElement(true)
    heading.setAccessibilityRole(.headingRole)
    heading.setAccessibilitySubrole(nil)
    heading.setAccessibilityValue(1)

    for childNode in element.getChildNodes() {
      if let subview = render(
        childNode,
        stylesheet: Stylesheet(fontSize: 32, fontWeight: .bold)
      ) {
        heading.addArrangedSubview(subview)
      }
    }

    return heading
  }

  private func createPView(_ element: Element) -> NSView {
    let paragraph = NSStackView()
    paragraph.orientation = .vertical
    paragraph.alignment = .leading
    paragraph.distribution = .fill

    paragraph.setAccessibilityElement(true)
    paragraph.setAccessibilityRole(.group)
    paragraph.setAccessibilitySubrole(nil)

    for childNode in element.getChildNodes() {
      if let subview = render(childNode) {
        paragraph.addArrangedSubview(subview)
      }
    }

    return paragraph
  }

  private func createImgView(_ element: Element) -> NSView {
    let src = try! element.attr("src")
    let alt = try! element.attr("alt")

    let image = NSImageView()
    image.imageScaling = .scaleProportionallyUpOrDown
    if let url = URL(string: src) {
      image.image = NSImage(contentsOf: url)
    }
    image.translatesAutoresizingMaskIntoConstraints = false

    image.setAccessibilityElement(true)
    image.setAccessibilityRole(.image)
    image.setAccessibilitySubrole(nil)
    image.setAccessibilityLabel(alt)

    return image
  }

  private func createFormView(_ element: Element) -> NSView {
    let form = NSStackView()
    form.orientation = .vertical
    form.alignment = .leading
    form.distribution = .fill

    for childNode in element.getChildNodes() {
      if let subview = render(childNode) {
        form.addArrangedSubview(subview)
      }
    }

    form.setAccessibilityElement(true)
    form.setAccessibilityRole(.group)
    form.setAccessibilitySubrole(
      NSAccessibility.Subrole(rawValue: "AXLandmarkForm")
    )

    return form
  }

  private func createLabelView(_ element: Element) -> NSView {
    let label = NSStackView()
    label.orientation = .vertical
    label.alignment = .leading
    label.distribution = .fill

    for childNode in element.getChildNodes() {
      if let subview = render(childNode) {
        label.addArrangedSubview(subview)
      }
    }

    label.setAccessibilityElement(true)
    label.setAccessibilityRole(.group)
    label.setAccessibilitySubrole(nil)
    label.setAccessibilityRoleDescription("グループ")

    return label
  }

  private func createInputView(_ element: Element) -> NSView {
    let input = NSTextField(labelWithString: "hello")
    input.isEditable = true
    
    if try! element.attr("type") == "text" {
      let id = element.id();
      let document = element.ownerDocument()!
      var name = "";
      
      do {
        let labels = try document.select("label[for=\(id)]")
        for label in labels {
          let textualEquivalent = try label.text();
          name += textualEquivalent;
        }
      } catch {
      }
      
      input.setAccessibilityRole(.textField)
      input.setAccessibilityLabel(name)
    }
    
    return input
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
      """
  )
}
