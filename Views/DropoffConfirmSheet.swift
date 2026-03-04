import SwiftUI

struct DropoffConfirmSheet: View {
    let payload: DropoffQRPayload
    let isSubmitting: Bool
    let errorMessage: String?
    let onConfirm: (Int) -> Void

    @State private var garmentsCount = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Confirmar entrega")
                .font(.title2)
                .bold()

            Text("ID del centro: \(payload.centerId)")
                .foregroundStyle(.secondary)

            Text("Tipo de contenedor: \(payload.containerType.title)")
                .foregroundStyle(.secondary)

            Divider()

            Text("Cantidad de prendas")
                .font(.headline)

            Stepper(value: $garmentsCount, in: 1...500) {
                Text("\(garmentsCount)")
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Spacer()

            Button {
                onConfirm(garmentsCount)
            } label: {
                HStack(spacing: 8) {
                    if isSubmitting {
                        ProgressView()
                    }
                    Text(isSubmitting ? "Guardando..." : "Confirmar entrega")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSubmitting)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    DropoffConfirmSheet(
        payload: DropoffQRPayload(centerId: "centro_tec", containerType: .mixed),
        isSubmitting: false,
        errorMessage: nil,
        onConfirm: { _ in }
    )
}
