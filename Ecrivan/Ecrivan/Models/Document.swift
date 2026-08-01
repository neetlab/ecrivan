//
//  Document.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftUI
import SwiftSoup

struct DOMElement: Identifiable {
    let id = UUID()
    let kind: Kind
    
    enum Kind {
        case p(text: String)
        case h1(text: String)
        case h2(text: String)
        case h3(text: String)
    }
}

func createDOMElements(input: String) -> [DOMElement] {
    var elements: [DOMElement] = []
    
    do {
        let body = try SwiftSoup.parse(input).body()!
        
        for child in body.children() {
            switch child.tagName() {
            case "p":
                let text = try child.text()
                elements.append(DOMElement(kind: .p(text: text)))
            case "h1":
                let text = try child.text()
                elements.append(DOMElement(kind: .h1(text: text)))
            case "h2":
                let text = try child.text()
                elements.append(DOMElement(kind: .h2(text: text)))
            case "h3":
                let text = try child.text()
                elements.append(DOMElement(kind: .h3(text: text)))
            default:
                break;
            }
        }
        
        return elements
    } catch {
        return []
    }
}
