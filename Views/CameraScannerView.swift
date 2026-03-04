import SwiftUI
import AVFoundation

struct CameraScannerView: UIViewRepresentable {
    let onCodeScanned: (String) -> Void
    let onError: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onCodeScanned: onCodeScanned)
    }

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        context.coordinator.setupSession(previewView: view) { errorMessage in
            onError(errorMessage)
        }
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    static func dismantleUIView(_ uiView: PreviewView, coordinator: Coordinator) {
        coordinator.stopSession()
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        private let session = AVCaptureSession()
        private var didScan = false
        private let onCodeScanned: (String) -> Void

        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }

        func setupSession(previewView: PreviewView, onError: @escaping (String) -> Void) {
            guard let device = AVCaptureDevice.default(for: .video) else {
                onError("No se encontró cámara disponible.")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)

                guard session.canAddInput(input) else {
                    onError("No se pudo inicializar la cámara.")
                    return
                }
                session.addInput(input)

                let output = AVCaptureMetadataOutput()
                guard session.canAddOutput(output) else {
                    onError("No se pudo inicializar el lector de QR.")
                    return
                }
                session.addOutput(output)

                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]

                previewView.previewLayer.session = session
                previewView.previewLayer.videoGravity = .resizeAspectFill

                DispatchQueue.global(qos: .userInitiated).async {
                    self.session.startRunning()
                }
            } catch {
                onError("Error de cámara: \(error.localizedDescription)")
            }
        }

        func stopSession() {
            if session.isRunning {
                session.stopRunning()
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard !didScan,
                  let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  first.type == .qr,
                  let value = first.stringValue else { return }

            didScan = true
            onCodeScanned(value)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.didScan = false
            }
        }
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
