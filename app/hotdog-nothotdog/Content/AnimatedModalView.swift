//
//  AnimatedModal.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI

struct AnimatedModalView<Item: Identifiable & Equatable, Content: View>: View {
    @Binding var item: Item?

    var animationDuration: Double
    var content: (Item) -> Content

    init(item: Binding<Item?>,
         animationDuration: Double = 0.60,
         @ViewBuilder content: @escaping (Item) -> Content) {
        self._item = item
        self.animationDuration = animationDuration
        self.content = content
    }

    var body: some View {
        ZStack {
            if let item = item {
                VStack {
                    content(item)
                    Spacer()

                    AnimatedExitButtonView {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            self.item = nil
                        }
                    }.padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 1)
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeOut(duration: animationDuration), value: item)
    }
}
