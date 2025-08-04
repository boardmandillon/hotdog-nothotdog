//
//  MockCameraViewModel.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI

class MockCameraViewModel: CameraViewModel {

    override func startSession() {
        // No-op for previews
    }

    override func stopSession() {
        // No-op for previews
    }

    override func capturePhoto() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.classificationResultWrapper = ClassificationResultWrapper(
                result: .success(ClassificationResult(image: UIImage(systemName: "photo")!, label: .hotdog, confidence: 0.95))
            )
        }
    }
}
