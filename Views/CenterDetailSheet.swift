//
//  CenterDetailSheet.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import SwiftUI

struct CenterDetailSheet: View {
    let center: RecyclingCenter

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(center.name).font(.title2).bold()
            Text(center.subtitle).foregroundStyle(.secondary)

            Divider().padding(.vertical, 4)

            Label("Horario: 9:00 – 18:00", systemImage: "clock")
            Label("Acepta: ropa, textiles", systemImage: "tshirt")
            Label("QR disponible en sitio", systemImage: "qrcode")

            Spacer()

            Button {
                // Luego: abrir Apple Maps con ruta
            } label: {
                Text("Cómo llegar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium])
    }
}