//
//  CircleView.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI
import SwiftData

struct AnimatedExitButtonView: View {
    @State private var isTapped = false

    var action: () -> Void

    func toggle() {
        isTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { isTapped = false }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.red, lineWidth: 5)
                .frame(width: 75, height: 75)

            Circle()
                .fill(Color.red)
                .frame(width: isTapped ? 60 : 65, height: isTapped ? 60 : 65)
                .animation(.easeInOut(duration: 0.20), value: isTapped)

            Image(systemName: "xmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
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
