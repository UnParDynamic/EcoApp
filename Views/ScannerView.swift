import SwiftUI
import AVFoundation

struct ScannerView: View {
    @EnvironmentObject private var store: EcoAppStore
    @StateObject private var vm = ScannerViewModel()

    @State private var cameraAuthorized = false
    @State private var cameraPermissionChecked = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.secondary.opacity(0.15))
                    .overlay {
                        if cameraAuthorized {
                            CameraScannerView(
                                onCodeScanned: { code in
                                    vm.scannedString = code
                                    vm.parseScannedString(code)
                                },
                                onError: { message in
                                    vm.errorMessage = message
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                Text("Se requiere acceso a cámara")
                                    .foregroundStyle(.secondary)
                                Button("Permitir cámara") {
                                    requestCameraPermission()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding()
                        }
                    }
                    .frame(height: 260)

                TextField("ecoapp://dropoff?center_id=...&container_type=...", text: $vm.scannedString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textFieldStyle(.roundedBorder)

                Button {
                    vm.parseScannedString()
                } label: {
                    Text("Procesar QR manual")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                if let errorMessage = vm.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let successMessage = vm.successMessage {
                    Text(successMessage)
                        .font(.footnote)
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Escanear")
            .onAppear {
                if !cameraPermissionChecked {
                    requestCameraPermission()
                }
            }
            .sheet(isPresented: $vm.showConfirmSheet) {
                if let payload = vm.scannedPayload {
                    DropoffConfirmSheet(
                        payload: payload,
                        isSubmitting: vm.isSubmitting,
                        errorMessage: vm.errorMessage,
                        onConfirm: { garmentsCount in
                            Task {
                                await vm.submitDropoff(garmentsCount: garmentsCount, store: store)
                            }
                        }
                    )
                }
            }
        }
    }

    private func requestCameraPermission() {
        cameraPermissionChecked = true

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.cameraAuthorized = granted
                    if !granted {
                        self.vm.errorMessage = "Permiso de cámara denegado. Actívalo en Configuración."
                    }
                }
            }
        case .denied, .restricted:
            cameraAuthorized = false
            vm.errorMessage = "Permiso de cámara denegado. Actívalo en Configuración."
        @unknown default:
            cameraAuthorized = false
            vm.errorMessage = "No fue posible acceder a la cámara."
        }
    }
}
