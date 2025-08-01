//
//  CameraViewModel.swift
//  hotdog-nothotdog
//
//  Created by boardmandillon on 30/12/2024.
//

import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var classifiedImage: ClassifiedImage?

    var previewLayer: AVCaptureVideoPreviewLayer?
    private let output = AVCapturePhotoOutput()

    override init() {
        super.init()
        setupCamera()
    }

    func setupCamera() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to set up camera input.")
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data),
              let previewLayer = previewLayer,
              let croppedImage = image.cropToVisibleSquare(previewLayer: previewLayer)
        else {
            return
        }

        classifyImage(croppedImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let classification):
                    self.classifiedImage = ClassifiedImage(image: croppedImage, classification: classification.rawValue)
                case .failure(let error):
                    self.classifiedImage = ClassifiedImage(image: croppedImage, classification: "Error: \(error.description)")
                }
            }
        }
    }
}
