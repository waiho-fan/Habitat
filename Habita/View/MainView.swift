//
//  MainView.swift
//  Habita
//
//  Created by iOS Dev Ninja on 22/12/2024.
//

import SwiftUI
import Observation

@Observable
class Activities {
    var items: [ActivityItem] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.setValue(encoded, forKey: "items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "items") {
            if let decoded = try? JSONDecoder().decode([ActivityItem].self, from: savedItems) {
                // test data
                items = Bundle.main.decode("activities.json")
//                items = decoded
                return
            }
        }
        items = []
    }
}

struct MainView: View {
    @State private var activities = Activities()
    @State private var showAddView = false
    @State private var selectedActivity: ActivityItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                ListLayout(activities: $activities, selectedActivity: $selectedActivity)
                    .navigationTitle("Habitat")
                    .sheet(isPresented: $showAddView) {
                        AddView(activities: activities)
                            .presentationDetents([.medium, .large])
                            .presentationBackgroundInteraction(.disabled)
                            .presentationBackground(.regularMaterial)
                    }
                    .toolbar {
                        Button {
                            showAddView = true
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.primary)
                        }
                    }
            }
            .blur(radius: selectedActivity != nil ? 5 : 0)
            .overlay(
                Group {
                    if let activity = selectedActivity {
                        CirclePopupProgressView(activityItem: activity)
//                        .background(.black.opacity(0.5))
                        .frame(width: .infinity, height: 250)
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        .transition(.scale)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.3)) {
                                selectedActivity = nil
                            }
                        }
                    }
                }
            )
        }
    }
    
    func removeItems(list: [ActivityItem], at offsets: IndexSet) {
        for offset in offsets {
            if let index = activities.items.firstIndex(of: list[offset]) {
                activities.items.remove(at: index)
            }
        }
    }
}

struct ListLayout: View {
    @State var showingActivity: [Bool] = []
    @Binding var activities: Activities {
        didSet {
            showingActivity = Array(repeating: false, count: activities.items.count)
        }
    }
    @Binding var selectedActivity: ActivityItem?

    
    init(activities: Binding<Activities>, selectedActivity: Binding<ActivityItem?>) {
        self._activities = activities
        self._selectedActivity = selectedActivity
        self._showingActivity = State(initialValue: Array(repeating: false, count: activities.wrappedValue.items.count))
    }
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(activities.items.indices, id: \.self) { index in
                ActivityRow(activityItem: $activities.items[index])
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedActivity = activities.items[index]
                        }
                    }
//                    .opacity(showingActivity[index] ? 1 : 0)
//                    .onAppear {
//                        withAnimation(.linear(duration: 0.1).delay(Double(index) * 0.1)) {
//                            showingActivity[index] = true
//                        }
//                    }
            }
        }
    }
}

struct CircleProgressView: View {
    let activityItem: ActivityItem
    @State private var animatedProgress: CGFloat = 0
    
    var body: some View {
        // Circle ProgressView
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3) // 背景圓
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(activityItem.isDone ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90)) // 旋轉 -90 度讓進度從頂部開始
                .animation(.easeOut(duration:  Double(activityItem.progress)), value: animatedProgress)
            Text("\(Int(animatedProgress * 100))%") //
                .font(.caption)
                
        }
        .frame(width: 50, height: 50)
        .padding(.horizontal, 10)
        .onAppear {
            animatedProgress = CGFloat(activityItem.progress) // 開始動畫
        }
        .onChange(of: activityItem.progress) { _, newValue in
            animatedProgress = CGFloat(newValue) // 當 progress 值變化時觸發動畫
        }
    }
}

struct CirclePopupProgressView: View {
    let activityItem: ActivityItem
    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10) // 背景圓
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(activityItem.isDone ? Color.green : Color.blue,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90)) // 旋轉 -90 度讓進度從頂部開始
                .animation(.easeOut(duration:  Double(activityItem.progress)), value: animatedProgress)
            VStack(alignment: .center) {
                Text(activityItem.name)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                Text("\(activityItem.count) / \(activityItem.targetCount)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("\(Int(animatedProgress * 100))%") // 顯示百分比
                    .font(.caption)
            }
            
        }
        .frame(width: 200, height: 200)
        .padding(.horizontal, 10)
        .onAppear {
            animatedProgress = CGFloat(activityItem.progress) // 開始動畫
        }
        .onChange(of: activityItem.progress) { _, newValue in
            animatedProgress = CGFloat(newValue) // 當 progress 值變化時觸發動畫
        }
    }
}

struct ActivityRow: View {
    @Binding var activityItem: ActivityItem
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.1)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
            HStack {
                CircleProgressView(activityItem: activityItem)
                
                VStack(alignment: .leading) {
                    Text(activityItem.name)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                    Text("\(activityItem.count) / \(activityItem.targetCount)")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
                Spacer()

                Button(action: {
                    withAnimation {
                        activityItem.count += 1
                    }
                }) {
                    Image(activityItem.isDone ? "doneButton" : "addButton")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)

    }
}

#Preview {
    MainView()
        .preferredColorScheme(.light)
}
