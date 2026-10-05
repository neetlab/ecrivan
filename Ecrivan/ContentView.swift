//
//  ContentView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/07/31.
//
import SwiftUI

struct ContentView: View {
  @State private var html: String?

  var body: some View {
    if let html {
      PreviewView(html: html) {
        self.html = nil
      }
    } else {
      FileSelectionView { loaded in
        self.html = loaded
      }
    }
  }
}

#Preview {
  ContentView()
}
