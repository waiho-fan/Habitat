//
//  AddView.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//

import SwiftUI
import SFSymbolsPicker

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = "Walk"
    @State private var targetCountText = "1"
    @State private var targetCount = 1
    @State private var selectedIcon = "figure.walk"
    @State private var selectedColor: Color = .orange
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    @State private var selectedDate = Date()

    var activities: Activities
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 20) {
                        NameSection(name: $name)
                        
                        StyleSection(showIconPicker: $showIconPicker, showColorPicker: $showColorPicker, selectedIcon: $selectedIcon, selectedColor: $selectedColor, name: $name)
                        
                        GoalSection(targetCount: $targetCount)
                        
                        DateSection(selectedDate: $selectedDate)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Save") {
                    let item = ActivityItem(name: name, targetCount: Int(targetCount), count: 0, icon: selectedIcon, colorName: selectedColor.description, date: selectedDate)
                    activities.items.append(item)
                    dismiss()
                }
            }
            .sheet(isPresented: $showIconPicker) {
                SymbolsPicker(selection: $selectedIcon, title: "Select a icon", autoDismiss: true) {
                    Image(systemName: "xmark.circle")
                }
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.disabled)
                .presentationBackground(.regularMaterial)
            }
            .padding()
            .sheet(isPresented: $showColorPicker) {
                ColorPickerView(selectedColor: $selectedColor, showColorPicker: $showColorPicker)
            }
        }
    }
    
    struct NameSection: View {
        @Binding var name: String

        var body: some View {
            VStack(alignment: .leading) {
                Text("NAME")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                
                TextField("Name", text: $name)
                    .frame(height: 50)
                    .padding(.leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            .padding(.leading, 16)
            
        }
    }
        
    struct StyleSection: View {
        @Binding var showIconPicker: Bool
        @Binding var showColorPicker: Bool
        @Binding var selectedIcon: String
        @Binding var selectedColor: Color
        @Binding var name: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("STYLE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    HStack(spacing: 12) {
                        // Icon Button
                        Button {
                            showIconPicker = true
                        } label: {
                            HStack {
                                IconView(icon: selectedIcon, selectedIcon: nil, color: selectedColor)
                                    .padding(.trailing, 8)
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.body.bold())
                                        .fontWeight(.medium)
                                        .foregroundStyle(selectedColor)
                                    Text("Icon")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(selectedColor)
                                }
                                Spacer()
                            }
                            .frame(height: 50)
                            .frame(width: (geometry.size.width - 74) / 2)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                        }
                        
                        // Color Button
                        Button {
                            showColorPicker = true
                        } label: {
                            HStack {
                                ColorView(color: selectedColor, selectedColor: nil)
                                    .padding(.trailing, 8)
                                Text("Color")
                                    .foregroundStyle(selectedColor)
                                Spacer()
                            }
                            .frame(height: 50)
                            .frame(width: (geometry.size.width - 74) / 2)
                            .padding(15)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                            )
                        }
                    }
                }
                .frame(height: 80)
            }
            .padding(.horizontal, 16)
        }
    }
    
    struct GoalSection: View {
        @Binding var targetCount: Int
        let range = Array(1...50)

        var body: some View {
            VStack(alignment: .leading) {
                Text("GOAL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("1 / \(targetCount) TIMES", selection: $targetCount) {
                    ForEach(range, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                )
                .pickerStyle(.menu)
                .foregroundStyle(.white)
                
            }
            .padding(.leading, 16)
        }
    }
    
    struct DateSection: View {
        @Binding var selectedDate: Date

        var body: some View {
            VStack(alignment: .leading) {
                Text("DATE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                DatePicker(selectedDate.formatted(date: .abbreviated, time: .omitted), selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.automatic)
                    .frame(height: 50)
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    )
            }
            .padding(.leading, 16)
        }
    }
    
    struct ColorPickerView: View {
        @Binding var selectedColor: Color
        @Binding var showColorPicker: Bool
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .gray, .brown, .cyan, .mint, .teal, .indigo
        ]
        
        static let rowCount: Int = 2
        static let gridSpacing: CGFloat = 10
        let rows: [GridItem] = Array(repeating: .init(.flexible(), spacing: gridSpacing), count: rowCount)
        
        var body: some View {
            NavigationStack {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, spacing: ColorPickerView.gridSpacing) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                HStack {
                                    ColorView(color: color, selectedColor: selectedColor)
                                }
                            }
                        }
                    }.padding()
                }
                .navigationTitle("Select Color")
                .navigationBarTitleDisplayMode(.inline)
                .flipsForRightToLeftLayoutDirection(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showColorPicker = false
                        } label: {
                            Image(systemName: "multiply")
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .presentationDetents([.height(200)])
            .presentationBackgroundInteraction(.disabled)
            .presentationBackground(.regularMaterial)
        }
    }
    
    struct IconView: View {
        let icon: String
        let selectedIcon: String?
        let color: Color
        var body: some View {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.2)))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedIcon == icon ? Color.secondary : .clear)
                )
        }
    }
    
    struct ColorView: View {
        let color: Color
        let selectedColor: Color?
        var body: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.8))
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
//                        .stroke(selectedColor == color ? Color.secondary : .clear)
                        .fill(selectedColor == color ? Color.secondary : .clear)
                        .frame(width: 15, height: 15)

                )
        }
    }
    
}
#Preview {
    AddView(activities: Activities())
        .preferredColorScheme(.dark)
}
