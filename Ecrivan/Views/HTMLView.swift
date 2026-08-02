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
        VStack(alignment: .leading) {
            ForEach(createDOMElements(input: html)) { element in
                renderItem(element: element)
            }
        }
    }

    @ViewBuilder
    func renderItem(element: DOMElement) -> some View {
        switch element.kind {
        case .h1(let text):
            HTMLH1ViewRepresentable(text: text)
        case .h2(let text):
            Text(text).font(.system(size: 40))
        case .h3(let text):
            Text(text).font(.system(size: 30))
        case .p(let text):
            Text(text)
        }
    }
}

#Preview {
    HTMLView(
        html: """
        <h1>this is my blog</h1>
        <h2>this is the content</h2>
        <p>hello world</p>
        """
    )
}
