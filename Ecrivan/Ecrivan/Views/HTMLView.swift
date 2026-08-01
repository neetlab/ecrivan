//
//  HTMLView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/08/01.
//
import SwiftUI

struct HTMLView: View {
    var html: String
    
    var body: some View {
        VStack {
            ForEach(createDOMElements(input: html)) { element in
                renderItem(element: element)
            }
        }
    }

    func renderItem(element: DOMElement) -> some View {
        switch element.kind {
        case .h1(let text):
            return Text(text).font(.system(size: 50))
        case .h2(let text):
            return Text(text).font(.system(size: 40))
        case .h3(let text):
            return Text(text).font(.system(size: 30))
        case .p(let text):
            return Text(text)
        }
    }
}
