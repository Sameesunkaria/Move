//
//  ActionColor.swift
//  Move-mac
//
//  Created by Samar Sunkaria on 5/27/19.
//  Copyright © 2019 samar. All rights reserved.
//

import Cocoa

extension Action {
    func color() -> NSColor {
        switch self {
        case .clap: return #colorLiteral(red: 0.4862745098, green: 0.6588235294, blue: 0.8588235294, alpha: 1)
        case .hurray: return #colorLiteral(red: 0.6588235294, green: 0.8156862745, blue: 0.4823529412, alpha: 1)
        case .punch: return #colorLiteral(red: 0.9450980392, green: 0.737254902, blue: 0.3921568627, alpha: 1)
        }
    }
}
