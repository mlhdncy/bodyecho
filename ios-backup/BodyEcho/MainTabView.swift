//
//  MainTabView.swift
//  BodyEcho
//
//  Created on 2025-11-10
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Anasayfa")
                }
                .tag(0)

            TrendsView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "chart.line.uptrend.xyaxis" : "chart.line.uptrend.xyaxis")
                    Text("Trendler")
                }
                .tag(1)

            ActivityLogView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "plus.circle.fill" : "plus.circle")
                    Text("Senaryo")
                }
                .tag(2)

            Text("Sohbet")
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "message.fill" : "message")
                    Text("Sohbet")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.primaryTeal)
    }
}

#Preview {
    MainTabView()
}
