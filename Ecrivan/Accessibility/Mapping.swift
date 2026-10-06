//
//  HTML-AAM.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/06.
//
import AppKit
import SwiftSoup

extension Element {
  func getImplicitRole() -> Role? {
    let tagName = self.tagName()
    switch tagName {
    case "h1":
      return .heading
    case "p":
      return .paragraph
    case "img":
      return .image
    case "form":
      return .form
    case "input":
      let type = try! self.attr("type")
      switch type {
      case "text", "email":
        return .textbox
      case "checkbox":
        return .checkbox
      default:
        return nil
      }
    case "button":
      return .button
    default:
      return nil
    }
  }
}

extension AccessibleObject {
  // ここがいちばん汚い。なんとかしたい気持ちはある。
  init(_ element: Element, _ accessibilityTree: AccessibilityTree) {
    self.node = element

    if let role = try? element.attr("role"), let role = Role(rawValue: role) {
      self.role = role
    } else {
      self.role = element.getImplicitRole() ?? .generic
    }

    /// HTML-AAM § 3.5.47
    /// https://www.w3.org/TR/html-aam-1.0/#el-h1-h6
    if element.tagName() == "h1" {
      self.`aria-level` = 1
    }

    /// HTML-AAM § 3.5.59
    /// https://www.w3.org/TR/html-aam-1.0/#el-input-checkbox
    if element.tagName() == "input", let type = try? element.attr("type"),
      type == "checkbox"
    {
      if let value = try? element.attr("value") {
        self.`aria-checked` = value
      } else {
        self.`aria-checked` = "false"
      }
    }

    /// 生の ARIA 属性たち
    if let `aria-hidden` = try? element.attr("aria-hidden"),
      `aria-hidden` == "true"
    {
      self.`aria-hidden` = true
    }
    
    accessibilityTree.setAccessibleObject(element, self)

    if !self.`aria-hidden` {
      for child in element.children() {
        self.children.append(AccessibleObject(child, accessibilityTree))
      }
    }
  }
}

extension AccessibleObject {
  func mapToAccessibilityAPI(_ view: NSView) {
    if self.`aria-hidden` {
      view.setAccessibilityElement(false)
      view.setAccessibilityChildren([])
    }
    
    if self.role.childrenPresentational {
      view.setAccessibilityChildren([])
    }

    if role == .heading {
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
      view.setAccessibilityChildren([])
      view.setAccessibilityLabel(name)
    }
  }
}
