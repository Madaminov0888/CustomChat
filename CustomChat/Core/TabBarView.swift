//
//  TabBarView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 01/03/24.
//

import SwiftUI

struct TabBarView: View {
    @State var selectedTab: TabSelection = .home
    @StateObject private var vm = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .home:
                    selectedTab.destinationView
                case .settings:
                    selectedTab.destinationView
                }
            }
            .animation(nil, value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(vm)
            
            CustomTabBar(selectedTab: $selectedTab) {
                vm.showUsersSheet = true
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    TabBarView()
}
