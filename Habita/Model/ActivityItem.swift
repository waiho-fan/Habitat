//
//  Activity.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//

import Foundation
import SwiftUI

struct ActivityItem: Codable, Identifiable, Equatable, Hashable {
    init(name: String, targetCount: Int, count: Int, icon: String, colorName: String, date: Date = .now) {
        self.id = UUID()
        self.name = name
        self.targetCount = targetCount
        self.count = count
        self.icon = icon
        self.colorName = colorName
        self.date = date
    }
    
    var id = UUID()
    var name: String
    var targetCount: Int
    var count: Int {
        didSet {
            count = count >= targetCount ? targetCount : count
        }
    }
    var icon: String
    private var colorName: String // 儲存顏色名稱
    var color: Color {
        get {
            Color(colorMapping()[colorName] ?? Color.blue )
        }
        set {
            colorName = newValue.description // 儲存顏色名稱
        }
    }
    var date: Date
    
    var progress: Double {
        return !(Double(count) / Double(targetCount)).isNaN ? Double(count) / Double(targetCount) : 0.0
    }
    
    var isDone: Bool {
        count >= targetCount
    }
    
    var isValidAdd: Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return false
        }
        return true
    }
    
    mutating func countIncreament() {
        count += 1
    }
    

}

func colorMapping() -> [String: Color] {
    [
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "blue": .blue,
        "purple": .purple,
        "pink": .pink,
        "gray": .gray,
        "black": .black,
        "white": .white
    ]
}
