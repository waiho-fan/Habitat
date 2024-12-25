//
//  RewardsView.swift
//  Habita
//
//  Created by Gary on 22/12/2024.
//
import SwiftUI

struct RewardsView: View {
    @State private var showBadgeDetail = false
    @State private var selectedBadge: String?

    let badges = ["🔥 Streak Master", "📚 Bookworm", "💪 Fitness Champ"]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(badges, id: \.self) { badge in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedBadge = badge
                            showBadgeDetail = true
                        }
                    }) {
                        Text(badge)
                            .padding()
                            .frame(width: 100, height: 100)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .shadow(radius: 5)
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .overlay(
            Group {
                if showBadgeDetail, let badge = selectedBadge {
                    VStack {
                        Text(badge)
                            .font(.title)
                            .foregroundStyle(.primary)
                            .padding()
                        Button("Close") {
                            withAnimation(.easeOut) {
                                showBadgeDetail = false
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.scale)
                }
            }
        )
    }
}

#Preview {
    RewardsView()
}
