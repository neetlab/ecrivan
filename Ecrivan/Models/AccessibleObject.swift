//
//  AccessibilityObject.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import AppKit

struct AccessibleObject {
  var role: Role
  var name: String? = nil
  var description: String? = nil
  var children: [AccessibleObject] = []

  //  var `aria-hidden`: Bool = false
  var `aria-level`: Int? = nil

  // CORE-AAM で対応すべき内容。でもここで書くべきではないような気もする。
  func mapToView(_ view: NSView) {
    view.setAccessibilityElement(true)

    if role == .heading, self.`aria-level` != nil {
      view.setAccessibilityRole(.headingRole)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityValue(self.`aria-level`)
    }

    if role == .paragraph {
      view.setAccessibilityRole(.group)
      view.setAccessibilitySubrole(nil)
    }

    if role == .image {
      view.setAccessibilityRole(.image)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityLabel(name)
    }

    if role == .form {
      view.setAccessibilityRole(.group)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilitySubrole(
        NSAccessibility.Subrole(rawValue: "AXLandmarkForm")
      )
    }

    if role == .textbox {
      print(self)
      view.setAccessibilityRole(.textField)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityLabel(name)
    }

    if role == .checkbox {
      view.setAccessibilityRole(.checkBox)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityValue(0)
    }

    if role == .button {
      view.setAccessibilityRole(.button)
      view.setAccessibilitySubrole(nil)
    }
  }
}
