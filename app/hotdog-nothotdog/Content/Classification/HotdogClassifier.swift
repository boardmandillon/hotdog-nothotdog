//
//  HotdogClassifier.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import CoreML
import Vision
import SwiftUI


struct ClassificationResultWrapper: Identifiable, Equatable {
    let id = UUID()
    let result: Result<ClassificationResult, ClassificationError>

    static func ==(lhs: ClassificationResultWrapper, rhs: ClassificationResultWrapper) -> Bool {
        lhs.id == rhs.id
    }
}

struct ClassificationResult: Equatable {
    enum Label: String {
        case hotdog = "hotdog"
        case notHotdog = "nothotdog"
    }

    let image: UIImage
    let label: Label
    let confidence: Float
}

enum ClassificationError: Error, CustomStringConvertible, Equatable {
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

    static func ==(lhs: ClassificationError, rhs: ClassificationError) -> Bool {
        lhs.description == rhs.description // Simplified comparison
    }
}

func classifyImage(_ uiImage: UIImage, completion: @escaping (ClassificationResultWrapper) -> Void) {
    guard let cgImage = uiImage.cgImage else {
        completion(.init(result: .failure(.invalidImage)))
        return
    }

    guard let model = try? VNCoreMLModel(for: hotdog_classifier().model) else {
        completion(.init(result: .failure(.modelFailed)))
        return
    }

    let request = VNCoreMLRequest(model: model) { request, error in
        if let error = error {
            completion(.init(result: .failure(.requestFailed(error))))
            return
        }

        guard let results = request.results as? [VNCoreMLFeatureValueObservation],
              let probability = results.first?.featureValue.multiArrayValue?[0].floatValue else {
            completion(.init(result: .failure(.noResult)))
            return
        }

        let label: ClassificationResult.Label = probability >= 0.5 ? .notHotdog : .hotdog
        let confidence = label == .notHotdog ? probability : 1 - probability

        let result = ClassificationResult(image: uiImage, label: label, confidence: confidence)
        completion(.init(result: .success(result)))
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try handler.perform([request])
        } catch {
            completion(.init(result: .failure(.requestFailed(error))))
        }
    }
}
