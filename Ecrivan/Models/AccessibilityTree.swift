//
//  AccessibilityTree.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import SwiftSoup

class AccessibilityTree {
  private var root: AccessibleObject?
  private var mapping: [Element: AccessibleObject]

  init(element: Element) {
    self.root = nil
    self.mapping = [Element: AccessibleObject]()
    self.root = AccessibleObject(element, self)
  }
  
  func setAccessibleObject(_ element: Element, _ accessibleObject: AccessibleObject) {
    self.mapping[element] = accessibleObject
  }

  func getAccessibleObject(_ element: Element) -> AccessibleObject? {
    return mapping[element]
  }
}
