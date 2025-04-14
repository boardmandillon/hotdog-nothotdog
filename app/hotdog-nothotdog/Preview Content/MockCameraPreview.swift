//
//  s.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI

struct MockCameraPreview: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.yellow)
                .overlay(
                    Text("placeholder")
                        .foregroundColor(.black)
                        .font(.largeTitle)
                )
        }
    }
}
