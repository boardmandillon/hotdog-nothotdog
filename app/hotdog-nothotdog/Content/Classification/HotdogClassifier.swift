//
//  HotdogClassifier.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import CoreML
import Vision
import SwiftUI

enum Classification: String {
    case hotdog = "🌭 HOTDOG 🌭"
    case notHotdog = "❌ NOTHOTDOG ❌"
}

enum ClassificationError: Error, CustomStringConvertible {
    case modelFailed
    case invalidImage
    case requestFailed(Error)
    case noResult

    var description: String {
        switch self {
        case .modelFailed: return "Model loading failed"
        case .invalidImage: return "Invalid image"
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .noResult: return "No classification result"
        }
    }
}

func classifyImage(_ uiImage: UIImage, completion: @escaping (Result<Classification, ClassificationError>) -> Void) {
    guard let cgImage = uiImage.cgImage else {
        completion(.failure(.invalidImage))
        return
    }

    guard let model = try? VNCoreMLModel(for: hotdog_classifier().model) else {
        completion(.failure(.modelFailed))
        return
    }

    let request = VNCoreMLRequest(model: model) { request, error in
        if let error = error {
            completion(.failure(.requestFailed(error)))
            return
        }

        guard let results = request.results as? [VNCoreMLFeatureValueObservation],
              let probability = results.first?.featureValue.multiArrayValue?[0].floatValue else {
            completion(.failure(.noResult))
            return
        }

        let classification: Classification = probability >= 0.5 ? .notHotdog : .hotdog
        completion(.success(classification))
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(.requestFailed(error)))
        }
    }
}
