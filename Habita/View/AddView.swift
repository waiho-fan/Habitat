//
//  AddView.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var targetCountText = "1"
    @State private var targetCount = 1
    let range = Array(1...50)
    
    var activities: Activities
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }
                Section("Target") {
                    Picker("\(targetCount)", selection: $targetCount) {
                        ForEach(range, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    .pickerStyle(.menu)
                }


            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Save") {
                    let item = ActivityItem(name: name, targetCount: Int(targetCount), count: 0)
                    activities.items.append(item)
                    dismiss()
                }
                .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    AddView(activities: Activities())
}
