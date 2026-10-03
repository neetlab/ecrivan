import SwiftSoup
//
//  DOMElement.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftUI

struct DOMElement: Identifiable {
  let id = UUID()
  let kind: Kind

  enum Kind {
    case p(text: String)
    case h1(text: String)
    case img(alt: String, src: String)
  }
}

func createDOMElements(input: String) -> [DOMElement] {
  var elements: [DOMElement] = []

  do {
    let body = try! SwiftSoup.parse(input).body()!

    for child in body.children() {
      switch child.tagName() {
      case "p":
        let text = try! child.text()
        elements.append(DOMElement(kind: .p(text: text)))
      case "h1":
        let text = try! child.text()
        elements.append(DOMElement(kind: .h1(text: text)))
      case "img":
        let src = try! child.attr("src")
        let alt = try! child.attr("alt")
        elements.append(DOMElement(kind: .img(alt: alt, src: src)))
      default:
        break
      }
    }

    return elements
  } catch {
    return []
  }
}
