//
//  CameraViewModel.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var cameraViewModel: CameraViewModel

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let previewLayer = AVCaptureVideoPreviewLayer(session: cameraViewModel.session)
        previewLayer.videoGravity = .resizeAspectFill

        viewController.view.layer.addSublayer(previewLayer)
        previewLayer.frame = viewController.view.frame

        DispatchQueue.main.async {
            cameraViewModel.startSession()
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        let viewController = uiViewController as UIViewController
        viewController.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
}

struct ClassifiedImage: Identifiable, Equatable {
    let id = UUID()
    let image: UIImage
    let classification: String
}
