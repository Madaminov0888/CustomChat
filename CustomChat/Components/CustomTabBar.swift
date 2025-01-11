//
//  CustomTabBar.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 08/01/25.
//

import Foundation
import SwiftUI


enum TabSelection: Hashable, CaseIterable {
    case home, settings
    
    var symbolName: String {
        switch self {
        case .home:
            return "house.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    @ViewBuilder
    var destinationView: some View {
        switch self {
        case .home:
            ChatView()
        case .settings:
            SettingsView()
        }
    }
    
    var name: String {
        switch self {
        case .home:
            return "Home"
        case .settings:
            return "Settings"
        }
    }
}



struct CustomTabBar: View {
    
    @Binding var selectedTab: TabSelection
    @Namespace private var nameSpace
    let action: () -> Void
    
    
    init(selectedTab: Binding<TabSelection>, action: @escaping () -> Void) {
        self._selectedTab = selectedTab  // Use _ to initialize @Binding
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            TabBarItems(tab: .home)
            Text("          ")
            TabBarItems(tab: .settings)
        }
        .overlay(alignment: .center, content: {
            TabBarButton {
                action()
            }
            .padding(.bottom, 20)
        })
        .padding(.bottom, 1)
        .background(Color.white)
    }
}



extension CustomTabBar {
    @ViewBuilder private func TabBarItems(tab: TabSelection) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 1)
                .frame(height: 1)
                .opacity(0)
            
            Image(systemName: tab.symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .fontWeight(.regular)
            
            Text(tab.name)
                .font(.caption)
                .fontWeight(.regular)
                
        }
        .foregroundStyle(selectedTab != tab ? .gray.opacity(0.55) : .csWelcome)
        .onTapGesture {
            selectedTab = tab
        }
        .contentShape(Rectangle())
        .padding(.bottom,0)
        .padding(.top, 0)
    }
    
    
    @ViewBuilder private func TabBarButton(action: @escaping (() -> Void)) -> some View {
        VStack {
            Button {
                action()
            } label: {
                Circle()
                    .foregroundStyle(Color.csWelcome)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundStyle(Color.white)
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .fontWeight(.regular)
                            .padding(5)
                    }
                    .shadow(radius: 10, y: 2)
            }
            .background(Circle().foregroundStyle(Color.csWelcome.opacity(0.6)))
            .buttonStyle(.plain)
            
            
            Text("New Chat")
                .font(.caption)
                .fontWeight(.regular)
                .foregroundStyle(Color.csWelcome)
        }
    }
}




#Preview {
    @Previewable @State var selectedTab: TabSelection = .home
    
    ZStack {
        Color.gray
        
        VStack {
            Spacer()
            
            CustomTabBar(selectedTab: $selectedTab, action: { print("pressed") })
        }
    }
}
