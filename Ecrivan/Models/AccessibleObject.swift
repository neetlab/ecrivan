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

  var `aria-level`: Int? = nil
  var `aria-checked`: String = "false"
  var `aria-hidden`: Bool = false

  // CORE-AAM で対応すべき内容。でもここで書くべきではないような気もする。
  func mapToView(_ view: NSView) {
    if self.`aria-hidden` {
      view.setAccessibilityElement(false)
    }
    
    if role == .heading, self.`aria-level` != nil {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.headingRole)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityValue(self.`aria-level`)
    }

    if role == .paragraph {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.group)
      view.setAccessibilitySubrole(nil)
    }

    if role == .image {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.image)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityLabel(name)
    }

    if role == .form {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.group)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilitySubrole(
        NSAccessibility.Subrole(rawValue: "AXLandmarkForm")
      )
    }

    if role == .textbox {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.textField)
      view.setAccessibilitySubrole(nil)
      view.setAccessibilityLabel(name)
    }

    if role == .checkbox {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.checkBox)
      view.setAccessibilitySubrole(nil)
      switch self.`aria-checked` {
      case "true":
        view.setAccessibilityValue(1)
      case "mixed":
        view.setAccessibilityValue(2)
      default:
        view.setAccessibilityValue(0)
      }
    }

    if role == .button {
      view.setAccessibilityElement(true)
      view.setAccessibilityRole(.button)
      view.setAccessibilitySubrole(nil)
    }
  }
}
