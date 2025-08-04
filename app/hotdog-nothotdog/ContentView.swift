//
//  ContentView.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 23/12/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var cameraViewModel: CameraViewModel

    var body: some View {
        ZStack {
            if (ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1") {
                CameraPreview(cameraViewModel: cameraViewModel).edgesIgnoringSafeArea(.all)
            } else {
                MockCameraPreview().edgesIgnoringSafeArea(.all)
            }

            ZStack {
                GeometryReader { geo in
                    let screenSize = geo.size

                    let safeAreaFrame = geo.safeAreaInsets
                    let safeHeight = screenSize.height - safeAreaFrame.top - safeAreaFrame.bottom
                    let safeWidth = screenSize.width - safeAreaFrame.leading - safeAreaFrame.trailing
                    let overlaySize = min(safeWidth, safeHeight) * 0.6

                    let centerX = screenSize.width / 2
                    let centerY = screenSize.height / 2

                    ZStack {
                        Color.black.opacity(0.5)
                            .mask {
                                Rectangle()
                                    .fill(style: FillStyle(eoFill: true))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(width: overlaySize, height: overlaySize)
                                            .position(x: centerX, y: centerY)
                                            .blendMode(.destinationOut)
                                    )
                            }

                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: overlaySize, height: overlaySize)
                            .position(x: centerX, y: centerY)
                    }
                }
            }
            .ignoresSafeArea()

            // main content
            VStack {
                Text("hotdog-nothotdog")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 1)
                    .padding(.top, 20)

                Spacer()

                AnimatedCircleView() { cameraViewModel.capturePhoto() }
                    .padding(.bottom, 40)
            }

            // popup modal
            AnimatedModalView(item: $cameraViewModel.classificationResultWrapper) { wrapper in
                VStack {
                    switch wrapper.result {
                    case .failure(let error):
                        Text("Error")
                            .font(.title2)
                            .foregroundColor(.red)
                            .padding(.top, 20)

                        Text(error.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()

                    case .success(let result):
                        Text(result.label.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 20)

                        Image(uiImage: result.image)
                            .resizable()
                            .scaledToFit()
                            .border(Color.black, width: 4)
                            .padding(.horizontal, 20)

                        Text("According to our calculations, there is a \(Int(result.confidence * 100))% probability of this being a \(result.label.rawValue)")
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(20)
                    }
                }
            }
        }
        .onAppear {
            cameraViewModel.startSession()
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
    }
}

#Preview {
    ContentView(cameraViewModel: MockCameraViewModel())
}
