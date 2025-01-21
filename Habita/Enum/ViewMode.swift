//
//  ViewMode.swift
//  Habita
//
//  Created by Gary on 28/12/2024.
//

import Foundation

enum ViewMode: CaseIterable {
    case all
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

