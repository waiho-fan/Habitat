//
//  AddView.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name = "Walk"
    @State private var targetCountText = "1"
    @State private var targetCount = 1
    @State private var selectedIcon = "figure.walk"
    @State private var selectedColor: Color = .orange
    @State private var showIconPicker = false
    @State private var showColorPicker = false
    
    let range = Array(1...50)
    let icons = [
        "figure.walk",
        "figure.run",
        "bicycle",
//        "figure.jump",
        "figure.roll",
//        "figure.climb",
//        "figure.sit",
        "figure.yoga",
//        "figure.swim",
//        "figure.ski",
//        "figure.surf",
//        "figure.snowboard",
//        "figure.hike",
        "figure.dance",
        "figure.soccer",
        "figure.basketball",
        "figure.baseball",
        "figure.tennis",
        "figure.volleyball",
        "figure.golf",
        "figure.boxing",
        "figure.fencing",
        "figure.martial.arts",
//        "figure.ice.hockey",
//        "figure.paddle",
//        "figure.row",
//        "figure.rock.climb",
//        "figure.skateboard",
        "figure.skating",
        "figure.pilates"
    ]
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .white, .black, .gray, .brown, .cyan, .mint, .teal, .indigo
    ]
    
    var activities: Activities
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                }
                
                Section("Icon") {
                    HStack {
                        Button {
                            showIconPicker = true
                        } label: {
                            HStack {
                                IconView(icon: selectedIcon, selectedIcon: nil, color: selectedColor)
                                    .padding(.trailing)
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.title2)
                                        .foregroundStyle(selectedColor)
                                    Text("Icon")
                                        .foregroundStyle(selectedColor)
                                }
                                
                            }
                        }
                    }
                }
                Section("Color") {
                    Button {
                        showColorPicker = true
                    } label: {
                        HStack {
                            ColorView(color: selectedColor, selectedColor: nil)
                                .padding(.trailing)
                            Text("Color")
                                .foregroundStyle(selectedColor)
                        }
                    }
                }
                
                Section("Goal") {
                    Picker("\(targetCount) times", selection: $targetCount) {
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
                    let item = ActivityItem(name: name, targetCount: Int(targetCount), count: 0, icon: selectedIcon, colorName: selectedColor.description, date: Date())
                    activities.items.append(item)
                    dismiss()
                }
                .foregroundStyle(.primary)
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, icons: icons, selectedColor: $selectedColor)
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerView(selectedColor: $selectedColor, colors: colors)
            }
        }
    }
    
    struct IconPickerView: View {
        @Binding var selectedIcon: String
        let icons: [String]
        @Binding var selectedColor: Color

        static let rowCount: Int = 2
        static let gridSpacing: CGFloat = 40
        let rows: [GridItem] = Array(repeating: .init(.flexible(), spacing: gridSpacing), count: rowCount)
        
        var body: some View {
            HStack {
                Text("Select Icon")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .padding()
                Spacer()
            }
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows, spacing: IconPickerView.gridSpacing) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            HStack {
                                IconView(icon: icon, selectedIcon: selectedIcon, color: selectedColor)
                            }
                        }
                    }
                }.padding()
            }
            .flipsForRightToLeftLayoutDirection(true)
            .presentationDetents([.height(200), .medium])
            .presentationBackgroundInteraction(.disabled)
            .presentationBackground(.regularMaterial)
        }
    }
    
    
    struct ColorPickerView: View {
        @Binding var selectedColor: Color
        let colors: [Color]
        
        static let rowCount: Int = 2
        static let gridSpacing: CGFloat = 40
        let rows: [GridItem] = Array(repeating: .init(.flexible(), spacing: gridSpacing), count: rowCount)
        
        var body: some View {
            HStack {
                Text("Select Color")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .padding()
                Spacer()
            }
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
            .flipsForRightToLeftLayoutDirection(true)
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
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.8))
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedColor == color ? Color.secondary : .clear)
                )
        }
    }
    
}
#Preview {
    AddView(activities: Activities())
}
