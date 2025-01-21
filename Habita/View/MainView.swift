//
//  MainView.swift
//  Habita
//
//  Created by iOS Dev Ninja on 22/12/2024.
//

import SwiftUI
import Observation

@Observable
class Activities: Codable {
    var items: [ActivityItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    // MARK: UserDefault
    private static let userDefaultsKey = "SavedActivities"
    private static let itemsKey = "items"
    
    func saveToUserDefault() {
        if let encoded = try? JSONEncoder().encode(self) {
            print("saveToUserDefault")
            UserDefaults.standard.setValue(encoded, forKey: Activities.userDefaultsKey)
        }
    }
    
    func saveItems() {
        if let encoded = try? JSONEncoder().encode(self.items) {
            print("saveItems - items \(self.items.count)")
            UserDefaults.standard.setValue(encoded, forKey: Activities.itemsKey)
            
            saveToUserDefault()
        }
    }
    
    static func loadFromUserDefault() -> Activities {
        if let savedAcivity = UserDefaults.standard.data(forKey: Activities.userDefaultsKey) {
            if let decoded = try? JSONDecoder().decode(Activities.self, from: savedAcivity) {
                decoded.items = loadItems()
                print("loadFromUserDefault - items \(decoded.items.count)")
                return decoded
            }
        }
        
        return Activities()
    }
    
    static func loadItems() -> [ActivityItem] {
        if let savedItems = UserDefaults.standard.data(forKey: Activities.itemsKey) {
            if let decoded = try? JSONDecoder().decode([ActivityItem].self, from: savedItems) {
                print("loadItems - items \(decoded.count)")
                // test data
                return Bundle.main.decode("activities.json")
//                return decoded
            }
        }
        return []
    }
}

struct MainView: View {
    @State private var activities = Activities.loadFromUserDefault()
    @State private var showAddView = false
    @State private var selectedActivity: ActivityItem?
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false
    private let calendar = Calendar.current
    @State private var dateRange: [Date] = []
    @State private var viewMode: ViewMode = .all
    @State var selectedTab = 0
    
    init() {
        let initialDate = Date()
        let calendar = Calendar.current
        
        var initialDates: [Date] = []
        for dayOffset in -3...3 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: initialDate) {
                initialDates.append(date)
            }
        }
        
        _selectedDate = State(initialValue: initialDate)
        _dateRange = State(initialValue: initialDates)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DateSelectionView(selectedDate: $selectedDate, dateRange: $dateRange)
                
                ListLayout(
                    items: $activities.items,
                    selectedActivity: $selectedActivity,
                    selectedDate: selectedDate,
                    viewMode: viewMode)
                
//                ListToggleView(viewMode: $viewMode)
//                                    .padding(.vertical, 8)
                TabView(viewMode: $viewMode)
            }
            .navigationTitle("Habitat")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddView) {
                AddView(activities: activities)
            }
            .toolbar {
                Button {
                    showDatePicker = true
                } label: {
                    Image(systemName: "calendar")
                }
                .foregroundStyle(.primary)
                
                Button {
                    showAddView = true
                } label: {
                    Image(systemName: "plus")
                }
                .foregroundStyle(.primary)

            }
        }
        .blur(radius: selectedActivity != nil ? 5 : 0)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, showDatePicker: $showDatePicker) { selectedDate in
                updateDateRange(around: selectedDate)
            }
        }
        .overlay(
            Group {
                if let activity = selectedActivity {
                    CirclePopupProgressView(activityItem: activity, selectedActivity: $selectedActivity)
                }
            }
        )
        .onAppear {
            updateDateRange(around: selectedDate)
        }
    }
    
    private func updateDateRange(around date: Date) {
        var newDates: [Date] = []
        for dayOffset in -3...3 {
            if let newDate = calendar.date(byAdding: .day, value: dayOffset, to: date) {
                newDates.append(newDate)
            }
        }
        dateRange = newDates
    }
}

struct ListLayout: View {
    @State var showingActivity: [Bool] = []
    @Binding var items: [ActivityItem]
    @Binding var selectedActivity: ActivityItem?
    let selectedDate: Date
    let viewMode: ViewMode
    
    init(items: Binding<[ActivityItem]>, selectedActivity: Binding<ActivityItem?>, selectedDate: Date, viewMode: ViewMode) {
        self._items = items
        self._selectedActivity = selectedActivity
        self._showingActivity = State(initialValue: Array(repeating: false, count: items.wrappedValue.count))
        self.selectedDate = selectedDate
        self.viewMode = viewMode
    }
    
    var body: some View {
        //        LazyVStack(alignment: .leading) {
        List {
            let filteredItems = items.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            let todoItems = items.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) && !$0.isDone }
            let doneItems = items.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) && $0.isDone }
            
            switch viewMode {
            case .all:
                Section("ALL") {
                    displayItems(filteredItems)
                }
            case .todo:
                Section("Section") {
                    displayItems(todoItems)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
    
    func displayItems(_ filteredItems: [ActivityItem]) -> some View {
        ForEach(filteredItems.indices, id: \.self) { index in
            ActivityRow(activityItem: Binding(
                get: { filteredItems[index] },
                set: { newValue in
                    if let originalIndex = items.firstIndex(where: { $0.id == newValue.id }) {
                        items[originalIndex] = newValue
                    }
                }
            ), onEdit: {
                print("Edit item at index \(index)")
            }, onDelete: {
                if let originalIndex = items.firstIndex(where: { $0.id == filteredItems[index].id }) {
                    items.remove(at: originalIndex)
                }
            })
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            //                .contentShape(Rectangle())  // 確保整個區域可點擊
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedActivity = filteredItems[index]
                }
            }
        }
    }
}

struct ActivityRow: View {
    @Binding var activityItem: ActivityItem
    @State private var showFlash = false
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20.0)
                        .stroke(activityItem.color.opacity(0.3), lineWidth: 2.0)
                )
            
            // 閃光效果層
            FlashEffect(isActive: showFlash, activityItem: activityItem)
                .mask(RoundedRectangle(cornerRadius: 20.0))
                .animation(
                    .linear(duration: 1),
                    value: showFlash
                )
            
            HStack {
                CircleProgressView(activityItem: activityItem)
                
                VStack(alignment: .leading) {
                    Text(activityItem.name)
                        .font(.body.bold())
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Text("\(activityItem.count) / \(activityItem.targetCount) TIMES")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primaryBlack40)
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
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remove", systemImage: "trash")
            }
            
            Button {
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                withAnimation {
                    activityItem.count = activityItem.targetCount
                }
            } label: {
                Label("Done", systemImage: "checkmark.circle")
            }
        }
        .onChange(of: activityItem.isDone) { _, isDone in
            if isDone {
                showFlash = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showFlash = false
                }
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
                .stroke(activityItem.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90)) // 旋轉 -90 度讓進度從頂部開始
                .animation(.easeOut(duration:  Double(activityItem.progress)), value: animatedProgress)
//            Text("\(Int(animatedProgress * 100))%") //
//                .font(.caption)
            Image(systemName: activityItem.icon)
                .font(.headline)
                .foregroundStyle(activityItem.color)
                
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
    @Binding var selectedActivity: ActivityItem?
    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10) // 背景圓
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(activityItem.isDone ? Color.green : activityItem.color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90)) // 旋轉 -90 度讓進度從頂部開始
                .animation(.easeOut(duration:  Double(activityItem.progress)), value: animatedProgress)
            VStack(alignment: .center) {
                Image(systemName: activityItem.icon)
                    .font(.largeTitle)
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
        .padding()
        .cornerRadius(15)
        .shadow(radius: 10)
        .transition(.scale)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                selectedActivity = nil
            }
        }
        .onAppear {
            animatedProgress = CGFloat(activityItem.progress) // 開始動畫
        }
        .onChange(of: activityItem.progress) { _, newValue in
            animatedProgress = CGFloat(newValue) // 當 progress 值變化時觸發動畫
        }
    }
}

struct DateSelectionView: View {
    @Binding var selectedDate: Date
    @Binding var dateRange: [Date]
    private let calendar = Calendar.current
   
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(dateRange, id: \.self) { date in
                            DateCell(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                                .onTapGesture {
                                    withAnimation {
                                        selectedDate = date
                                    }
                                }
                                .id(date)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    // Scroll to today
                    proxy.scrollTo(Date(), anchor: .center)
                }
                .onChange(of: selectedDate) { oldDate, newDate in
                    withAnimation {
                        proxy.scrollTo(newDate, anchor: .center)
                    }
                }
                .padding(.vertical)
            }
        }

    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    var onDateSelected: (Date) -> Void

    var body: some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("Selecte Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Today") {
                        selectedDate = Date()
                        onDateSelected(selectedDate)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onDateSelected(selectedDate)
                        showDatePicker = false
                    } label: {
                        Image(systemName: "multiply")
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(20)
        .presentationBackground(.thinMaterial)
        .presentationDragIndicator(.visible)

    }
}

struct DateCell: View {
    let date: Date
    let isSelected: Bool
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text(dayOfWeek)
                .font(.caption.bold())
                .foregroundColor(.secondary)
            Text(dateString)
                .font(.headline)
        }
        .padding(10)
        .background(isSelected ? Color.blue.opacity(0.6) : Color.white.opacity(0.2))
        .cornerRadius(8)
        .foregroundColor(.primary)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? .blue : .clear)
        )
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct FlashEffect: View {
    var isActive: Bool
    let activityItem: ActivityItem
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
//            let height = geometry.size.height
//            let frame = geometry.frame(in: .local)

            return LinearGradient(
                gradient: Gradient(colors: [
                    activityItem.color.opacity(0.2),
                    activityItem.color.opacity(0.1),
                    .clear,
                    .clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * 2)
            .opacity(isActive ? 1 : 0)
            .offset(x: isActive ? width : -width)
            .scaleEffect(isActive ? 1.01 : 1)
            .onAppear {
                print("Initial offset: \(isActive ? width : -width)")
            }
            .onChange(of: isActive) { _, newValue in
                print("isActive \(isActive), Offset changed to: \(newValue ? width : -width)")
            }
        }
    }
}

// MARK: TabView
struct ListToggleView: View {
    @Binding var viewMode: ViewMode
    
    var body: some View {
        HStack(spacing: 0) {
            // 全部列表按鈕
            Toggle(viewMode: .all)
            
            // 分類列表按鈕
            Toggle(viewMode: .todo)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color(.systemGray6))
        .cornerRadius(22)
        .padding(.horizontal)
    }
    
    // 內部的 Toggle 按鈕視圖
    @ViewBuilder
    private func Toggle(viewMode toggleMode: ViewMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewMode = toggleMode
            }
        } label: {
            Text(toggleMode == .all ? "All List" : "Sections")
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(viewMode == toggleMode ?
                             Color(.systemBackground) :
                             Color.clear)
                        .shadow(color: .black.opacity(0.1),
                               radius: viewMode == toggleMode ? 2 : 0)
                )
                .foregroundColor(viewMode == toggleMode ?
                               .primary :
                               .secondary)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }
}


#Preview {
    MainView()
        .preferredColorScheme(.dark)
}

struct TabView: View {
    @Binding var viewMode: ViewMode

    var body: some View {
        ZStack{
            HStack{
                ForEach((ViewMode.allCases), id: \.self){ item in
                    Button{
                        viewMode = item
                    } label: {
                        CustomTabItem(imageName: item.iconName, title: item.title, isActive: (viewMode == item))
                    }
                }
            }
            .padding(6)
        }
        .frame(height: 70)
        .background(.primary.opacity(0.2))
        .cornerRadius(35)
        .padding(.horizontal, 26)
    }
}
