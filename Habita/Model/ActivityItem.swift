//
//  Activity.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//

import Foundation

struct ActivityItem: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var targetCount: Int
    var count: Int
    
}
