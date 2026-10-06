//
//  Accname.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/06.
//
import SwiftSoup

extension Node {
  func getTextualEquivalent(role: Role? = nil) -> String? {
    // 2.2 LabelledBy
    if let name = self.labelledBy() {
      return name
    }

    // 2.4 AriaLabel
    if let name = self.ariaLabel() {
      return name
    }

    // 2.5 Host Language Label
    if let name = self.hostLanguageLabel() {
      return name
    }

    // 2.6 Name From Content
    if let name = self.nameFromContent(role: role) {
      return name
    }

    // 2.7 Text Node
    if let textNode = self as? TextNode {
      return textNode.text()
    }

    // 2.9 Tooltip
    if self.hasAttr("title") {
      let title = try? self.attr("title")
      return title
    }

    return nil
  }

  private func labelledBy() -> String? {
    if !self.hasAttr("aria-labelledby") {
      return nil
    }

    guard let document = self.ownerDocument() else {
      return nil
    }
    guard let labelledByAttr = try? self.attr("aria-labelledby") else {
      return nil
    }

    let labelledByIds = labelledByAttr.split(separator: " ")
    var labels: [String] = []

    for labelledById in labelledByIds {
      guard
        let labelElement = try? document.getElementById(String(labelledById))
      else {
        continue
      }
      guard let label = labelElement.getTextualEquivalent() else {
        continue
      }
      labels.append(label)
    }

    return labels.joined(separator: " ")
  }

  private func ariaLabel() -> String? {
    if self.hasAttr("aria-label") {
      let label = try? self.attr("aria-label")
      return label
    }
    return nil
  }

  private func hostLanguageLabel() -> String? {
    guard let document = self.ownerDocument() else {
      return nil
    }

    if let element = self as? Element, element.tagName() == "img",
      self.hasAttr("alt")
    {
      let alt = try? self.attr("alt")
      return alt
    }
    if let element = self as? Element,
      element.tagName() == "input" || element.tagName() == "textarea"
    {
      guard let label = try? document.select("label[for=\(element.id())]")
      else {
        return nil
      }
      return label.first()?.getTextualEquivalent()
    }

    return nil
  }

  private func nameFromContent(role: Role?) -> String? {
    if role?.nameFrom != .contentsOrAuthor, let element = self as? Element,
      element.tagName() != "label"
    {
      return nil
    }
    var accumulatedText = ""
    for node in self.getChildNodes() {
      let result = node.getTextualEquivalent()
      if let result = result {
        accumulatedText += result
      }
    }
    if accumulatedText == "" {
      return nil
    }
    return accumulatedText
  }
}

extension AccessibleObject {
  var name: String? {
    return self.node.getTextualEquivalent(role: self.role)
  }

  var description: String? {
    if let description = try? self.node.attr("aria-description") {
      return description
    }
    return nil
  }
}
