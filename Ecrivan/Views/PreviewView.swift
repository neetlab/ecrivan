//
//  PreviewView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/05.
//

import SwiftUI

struct PreviewView: View {
  var html: String
  var onBack: () -> Void

  var body: some View {
    HTMLView(html: html)
      .fixedSize(horizontal: true, vertical: true)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .padding()
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button {
            onBack()
          } label: {
            Label("戻る", systemImage: "chevron.left")
          }
        }
      }
  }
}

#Preview {
  PreviewView(
    html: """
      <h1>私のウェブサイト</h1>
      <p>これは私のウェブサイトです</p>
      """
  ) {}
}
