//
//  Activity.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//

import Foundation

struct ActivityItem: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var targetCount: Int
    var count: Int {
        didSet {
            count = count >= targetCount ? targetCount : count
        }
    }
    
    var progress: Double {
        return !(Double(count) / Double(targetCount)).isNaN ? Double(count) / Double(targetCount) : 0.0
    }
    
    var isDone: Bool {
        count >= targetCount
    }
}
