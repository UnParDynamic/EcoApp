//
//  ScannerView.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import SwiftUI

struct ScannerView: View {
    @EnvironmentObject private var store: EcoAppStore
    @StateObject private var vm = ScannerViewModel()

    @State private var showConfirm = false
    @State private var garmentsText = "5"
    @State private var selectedCenter = "Centro Tec"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.secondary.opacity(0.15))
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 48))
                            Text("Vista previa de escáner QR")
                                .foregroundStyle(.secondary)
                            Text("Aquí irá la cámara (AVFoundation)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                    .frame(height: 320)

                Text("Escanea el QR del centro y registra tus prendas.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    vm.lastScannedCenterName = selectedCenter
                    showConfirm = true
                } label: {
                    Text("Simular escaneo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Escanear")
            .sheet(isPresented: $showConfirm) {
                confirmSheet
            }
        }
    }

    private var confirmSheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Confirmar entrega").font(.title2).bold()
            Text("Centro: \(vm.lastScannedCenterName ?? "—")")
                .foregroundStyle(.secondary)

            Divider()

            Text("Número de prendas").font(.headline)

            TextField("Ej. 5", text: $garmentsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            let garments = Int(garmentsText) ?? 0
            let earned = garments * store.pointsPerGarment

            Text("Puntos a ganar: \(earned)")
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                store.addDropOff(centerName: vm.lastScannedCenterName ?? "Centro", garments: garments)
                showConfirm = false
            } label: {
                Text("Guardar y sumar puntos")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(garments <= 0)
        }
        .padding()
        .presentationDetents([.medium])
    }
}