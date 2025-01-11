//
//  BackgroundViews.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 29/02/24.
//

import SwiftUI

enum BlurType: String, CaseIterable {
    case clipped = "Clipped"
    case freestyle = "Free Style"
}




struct BackgroundView: View {
    @State var start = UnitPoint(x: 0,y: -2)
    @State var end = UnitPoint(x:4, y: 0)
    @Binding var changeOfView: Bool

    
    let timer = Timer.publish(every: 5, on: .main, in: .default).autoconnect()
    
    let colors: [Color] = [
        Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.4441776872, green: 0.9885492921, blue: 0.8311395049, alpha: 1)).opacity(0.5), Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)).opacity(0.5), Color(#colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)),
    ]
    
    
    var body: some View {
        VStack {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
                .onReceive(timer, perform: { _ in
                    withAnimation(.spring(duration: 5)) {
                        backgroundChanger()
                    }
                })
                .onAppear {
                    withAnimation(.spring) {
                        backgroundChanger()
                    }
                }
                .onChange(of: changeOfView) { oldValue, newValue in
                    withAnimation(.easeInOut(duration: 1.5)) {
                        backgroundChanger()
                    }
                }
        }
    }
}

extension BackgroundView {
    private func backgroundChanger() {
        if self.start == UnitPoint(x: 4, y: 0) {
            self.start = UnitPoint(x: 0,y: -2)
            self.end = UnitPoint(x:4, y: 0)
        } else {
            self.start = UnitPoint(x: 4, y: 0)
            self.end = UnitPoint(x: 0, y: 2)
            self.start = UnitPoint(x: -4, y: 20)
            self.start = UnitPoint(x: 4, y: 0)
        }
    }
}

#Preview {
    BackgroundView(changeOfView: .constant(true))
        .ignoresSafeArea()
}
