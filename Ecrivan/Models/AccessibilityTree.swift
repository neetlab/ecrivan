//
//  AccessibilityTree.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import SwiftSoup

struct AccessibilityTree {
  private let root: AccessibilityObject
  private let domToAccessibilityObject: [Node: AccessibilityObject]

  init(element: Element) {
    var map = [Node: AccessibilityObject]()
    let child = Self.makeAccessibilityObject(element: element, map: &map)

    var root = AccessibilityObject(role: .document)
    root.children.append(child)

    self.root = root
    self.domToAccessibilityObject = map
  }
  
  func getAccessibilityObject(_ node: Node) -> AccessibilityObject? {
    return domToAccessibilityObject[node]
  }

  private static func makeAccessibilityObject(
    element: Element,
    map: inout [Node: AccessibilityObject]
  ) -> AccessibilityObject {
    var accessibilityObject = AccessibilityObject(
      role: Role(element: element),
      name: getAccessibleName(element: element),
      description: getAccessibleDescription(element: element)
    )

    if element.tagName() == "h1" {
      accessibilityObject.`aria-level` = 1
    }

    for child in element.children() {
      accessibilityObject.children.append(
        makeAccessibilityObject(element: child, map: &map)
      )
    }

    map[element] = accessibilityObject
    return accessibilityObject
  }
}

func getAccessibleName(element: Element) -> String? {
  let document = element.ownerDocument()
  let id = element.id()
  
  if element.hasAttr("aria-label") {
    let label = try? element.attr("aria-label")
    return label
  }

  if element.tagName() == "img", element.hasAttr("alt") {
    let alt = try? element.attr("alt")
    return alt
  }

  if element.hasAttr("title") {
    let title = try? element.attr("title")
    return title
  }
  
  if let label = try? document?.select("label[for=\(id)]") {
    return try? label.text()
  }

  return nil
}

func getAccessibleDescription(element: Element) -> String? {
  if let description = try? element.attr("aria-description") {
    return description
  }

  return nil
}
