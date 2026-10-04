//
//  Role.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import SwiftSoup

enum Role {
  case document
  case heading
  case paragraph
  case group
  case image
  case form
  case textbox
  case checkbox
  case button
  case generic

  init(element: Element) {
    let tagName = element.tagName()
    switch tagName {
    case "h1":
      self = .heading
    case "p":
      self = .paragraph
    case "img":
      self = .image
    case "form":
      self = .form
    // case "label":
    // self = .group
    case "input":
      let type = try! element.attr("type")
      switch type {
      case "text", "email":
        self = .textbox
      case "checkbox":
        self = .checkbox
      default:
        self = .generic
      }
    case "button":
      self = .button
    default:
      self = .generic
    }
  }
}
