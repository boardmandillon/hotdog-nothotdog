//
//  HotdogClassifier.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import CoreML
import Vision
import SwiftUI

let model = try! hotdog_classifier(configuration: .init())

func classifyImage(_ uiImage: UIImage, completion: @escaping (String) -> Void) {
    guard let model = try? VNCoreMLModel(for: hotdog_classifier().model) else {
        completion("model loading failed")
        return
    }

    // create a request
    let request = VNCoreMLRequest(model: model) { request, error in
        if let error = error {
            completion("ERROR: \(error.localizedDescription)")
            return
        }

        guard let results = request.results as? [VNCoreMLFeatureValueObservation],
              let probability = results.first?.featureValue.multiArrayValue?[0].floatValue else {
            completion("No prediction found")
            return
        }

        // interpret the probability
        if probability >= 0.5 {
            completion("nothotdog")
        } else {
            completion("hotdog")
        }
    }

    // run the request on a background thread
    guard let cgImage = uiImage.cgImage else {
        completion("invalid image")
        return
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global().async {
        do {
            try handler.perform([request])
        } catch {
            completion("failed to perform request: \(error.localizedDescription)")
        }
    }
}
