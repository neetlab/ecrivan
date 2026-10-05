//
//  AccessibilityTree.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import SwiftSoup

struct AccessibilityTree {
  private let root: AccessibleObject
  private let domToAccessibleObject: [Node: AccessibleObject]

  init(element: Element) {
    var map = [Node: AccessibleObject]()
    let child = Self.makeAccessibleObject(element: element, map: &map)

    var root = AccessibleObject(role: .document)
    root.children.append(child)

    self.root = root
    self.domToAccessibleObject = map
  }
  
  func getAccessibleObject(_ node: Node) -> AccessibleObject? {
    return domToAccessibleObject[node]
  }

  private static func makeAccessibleObject(
    element: Element,
    map: inout [Node: AccessibleObject]
  ) -> AccessibleObject {
    var accessibleObject = AccessibleObject(
      role: Role(element: element),
      name: getAccessibleName(element: element),
      description: getAccessibleDescription(element: element)
    )

    if element.tagName() == "h1" {
      accessibleObject.`aria-level` = 1
    }

    for child in element.children() {
      accessibleObject.children.append(
        makeAccessibleObject(element: child, map: &map)
      )
    }

    map[element] = accessibleObject
    return accessibleObject
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
