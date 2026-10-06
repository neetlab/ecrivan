//
//  Role.swift
//  Ecrivan
//
//  Created by Ryo Igarashi on 2026/10/04.
//
import SwiftSoup

enum Role: String {
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
  case none
}

enum NameFrom {
  case author
  case contentsOrAuthor
  case prohibited
}

extension Role {
  var nameFrom: NameFrom {
    switch self {
    case .document, .group, .image, .form, .textbox:
      return .author
    case .heading, .checkbox, .button:
      return .contentsOrAuthor
    case .paragraph, .generic, .none:
      return .prohibited

    }
  }
  
  var childrenPresentational: Bool {
    switch self {
    case .image, .button, .checkbox:
      return true
    default:
      return false
    }
  }
}
