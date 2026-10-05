//
//  AccessibilityObject.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import AppKit
import SwiftSoup

// Children Presentational, Name From, とかはこのへんで定義して
// Accessibility API への写像を楽に導出できるようにすべきなのかなあ？
struct AccessibleObject {
  var role: Role
  var name: String? = nil
  var description: String? = nil
  var children: [AccessibleObject] = []

  var `aria-level`: Int? = nil
  var `aria-checked`: String = "false"
  var `aria-hidden`: Bool = false
}
