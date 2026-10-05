//
//  FileSelectionView.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/05.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileSelectionView: View {
  var onLoad: (String) -> Void

  @State private var isImporterPresented = false
  @State private var isTargeted = false
  @State private var errorMessage: String?

  var body: some View {
    VStack(spacing: 24) {
      Image(systemName: "doc.richtext")
        .font(.system(size: 56))
        .foregroundStyle(.secondary)

      VStack(spacing: 8) {
        Text("HTMLファイルを開く")
          .font(.title2.weight(.semibold))
        Text("ファイルを選択するか、ここにドラッグ&ドロップしてください")
          .font(.callout)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }

      Button("ファイルを選択…") {
        isImporterPresented = true
      }
      .controlSize(.large)
      .buttonStyle(.borderedProminent)

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
      }
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(
          isTargeted ? Color.accentColor : Color.secondary.opacity(0.3),
          style: StrokeStyle(lineWidth: 2, dash: [8])
        )
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(isTargeted ? Color.accentColor.opacity(0.08) : Color.clear)
        )
        .padding(20)
    )
    .frame(minWidth: 480, minHeight: 360)
    .fileImporter(
      isPresented: $isImporterPresented,
      allowedContentTypes: [.html],
      allowsMultipleSelection: false
    ) { result in
      switch result {
      case .success(let urls):
        if let url = urls.first {
          load(from: url)
        }
      case .failure(let error):
        errorMessage = error.localizedDescription
      }
    }
    .dropDestination(for: URL.self) { urls, _ in
      guard let url = urls.first else { return false }
      load(from: url)
      return true
    } isTargeted: { targeted in
      isTargeted = targeted
    }
  }

  private func load(from url: URL) {
    let needsAccess = url.startAccessingSecurityScopedResource()
    defer {
      if needsAccess { url.stopAccessingSecurityScopedResource() }
    }

    do {
      let content = try String(contentsOf: url, encoding: .utf8)
      errorMessage = nil
      onLoad(content)
    } catch {
      errorMessage = "ファイルを読み込めませんでした: \(error.localizedDescription)"
    }
  }
}

#Preview {
  FileSelectionView { _ in }
}
