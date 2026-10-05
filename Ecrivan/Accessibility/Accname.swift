//
//  Accname.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/06.
//
import SwiftSoup

func getTextualEquivalent(_ element: Element) -> String? {
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

  return try? element.text()
}

extension Element {
  func getAccessibleName() -> String? {
    return getTextualEquivalent(self)
  }
  
  func getAccessibleDescription() -> String? {
    if let description = try? self.attr("aria-description") {
      return description
    }
    return nil
  }
}
