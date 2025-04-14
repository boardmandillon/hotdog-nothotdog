//
//  CircleView.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI
import SwiftData

struct AnimatedCircleView: View {
    @State private var isTapped = false

    var action: () -> Void

    func toggle() {
        isTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { isTapped = false }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white, lineWidth: 5)
                .frame(width: 75, height: 75)

            Circle()
                .fill(Color.white)
                .frame(width: isTapped ? 60 : 65, height: isTapped ? 60 : 65)
                .animation(.easeInOut(duration: 0.20), value: isTapped)
        }
        .geometryGroup()
        .contentShape(Circle())
        .onTapGesture {
            if !isTapped {
                toggle()
                action()
            }
        }
    }
}
