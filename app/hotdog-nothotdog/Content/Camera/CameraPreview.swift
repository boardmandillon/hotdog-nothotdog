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
            cameraViewModel.previewLayer = previewLayer
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

extension UIImage {
    func cropToVisibleSquare(previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        // define visible square area in previewLayer coordinates
        let squareWidth = previewLayer.bounds.width * 0.6
        let squareX = (previewLayer.bounds.width - squareWidth) / 2
        let squareY = (previewLayer.bounds.height - squareWidth) / 2

        let visibleRect = CGRect(x: squareX, y: squareY, width: squareWidth, height: squareWidth)
        let normalizedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: visibleRect)

        // convert to image coordinates
        var cropRect = CGRect(
            x: normalizedRect.origin.x * imageSize.width,
            y: normalizedRect.origin.y * imageSize.height,
            width: normalizedRect.size.width * imageSize.width,
            height: normalizedRect.size.height * imageSize.height
        ).integral

        // force cropRect to be square
        let side = min(cropRect.width, cropRect.height)
        cropRect = CGRect(
            x: cropRect.midX - side / 2,
            y: cropRect.midY - side / 2,
            width: side,
            height: side
        ).integral

        // crop the image
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
