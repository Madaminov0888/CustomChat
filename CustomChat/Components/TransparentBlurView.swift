//
//  TransparentBlurView.swift
//  AdvancedBootCamp
//
//  Created by Muhammadjon Madaminov on 29/11/23.
//

import SwiftUI

struct TransparentBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let vc = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial ))
        return vc
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            if let dropLayer = uiView.layer.sublayers?.first {
//                dropLayer.filters = []
                dropLayer.filters?.removeAll(where: { filter in
                    String(describing: filter) != "gaussianBlur"
                })
            }
        }
    }
}

//Optional([luminanceCurveMap, colorSaturate, colorBrightness, gaussianBlur])

#Preview {
    TransparentBlurView()
        .padding(15)
}
