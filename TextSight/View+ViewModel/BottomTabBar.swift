//
//  BottomTabBar.swift
//  TextSight
//
//  Created by Kavindu Dissanayake on 2023-10-29.
//

import SwiftUI
import SwiftData


struct BottomTabBar: View {
    @State private var activeTab: Int = 0
    
    var body: some View {
        TabView(selection: $activeTab) {
            NavigationStack {
                HomeView()
            }//:NavigationStack
            .tag(0)
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }

            NavigationStack {
                HistoryView()
            }//:NavigationStack
            .tag(1)
            .tabItem {
                Image(systemName: "arrow.counterclockwise")
                Text("History")
            }
        }
        .accentColor(Theme.primaryColor)
        .overlay(alignment: .topTrailing) {
            DarkModeButton()
                .padding()
        }
    }
}



#Preview {
    BottomTabBar()
        .modelContainer(for: Item.self, inMemory: true)
}
