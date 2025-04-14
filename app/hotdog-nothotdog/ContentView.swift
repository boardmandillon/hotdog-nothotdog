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
            AnimatedModalView(item: $cameraViewModel.classifiedImage) {_ in
                VStack {
                    Text(cameraViewModel.classifiedImage!.classification)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))

                    Image(uiImage: cameraViewModel.classifiedImage!.image)
                        .resizable()
                        .scaledToFit()
                        .border(Color.black, width: 4)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
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
