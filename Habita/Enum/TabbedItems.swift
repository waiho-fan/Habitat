//
//  TabbedItems.swift
//  Habita
//
//  Created by Gary on 1/1/2025.
//

import Foundation

enum TabbedItems: Int, CaseIterable{
    case all = 0
    case todo
    
    var title: String{
        switch self {
        case .all:
            return "All"
        case .todo:
            return "TODO"
        }
    }
    
    var iconName: String{
        switch self {
        case .all:
            return "list.bullet"
        case .todo:
            return "list.bullet.rectangle.portrait"
        }
    }
}
