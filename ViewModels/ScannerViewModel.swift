import Foundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var scannedPayload: DropoffQRPayload?
    @Published var showConfirmSheet = false
    @Published var scannedString = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    func parseScannedString() {
        parseScannedString(scannedString)
    }

    func parseScannedString(_ rawValue: String) {
        errorMessage = nil
        successMessage = nil

        guard let components = URLComponents(string: rawValue),
              components.scheme?.lowercased() == "ecoapp" else {
            errorMessage = "QR inválido: se esperaba ecoapp://dropoff?..."
            return
        }

        let host = (components.host ?? "").lowercased()
        let path = components.path.lowercased()

        guard host.contains("dropoff") || path.contains("dropoff") else {
            errorMessage = "Ruta de QR inválida. Se esperaba el endpoint dropoff."
            return
        }

        let queryItems = components.queryItems ?? []
        let centerID = queryItems.first(where: { $0.name == "center_id" })?.value?.trimmingCharacters(in: .whitespacesAndNewlines)
        let containerRaw = queryItems.first(where: { $0.name == "container_type" })?.value?.lowercased()

        guard let centerID, !centerID.isEmpty else {
            errorMessage = "El QR no contiene center_id."
            return
        }

        guard let containerRaw,
              let containerType = ContainerType(rawValue: containerRaw) else {
            errorMessage = "El QR no contiene un container_type válido."
            return
        }

        scannedPayload = DropoffQRPayload(centerId: centerID, containerType: containerType)
        showConfirmSheet = true
    }

    func submitDropoff(garmentsCount: Int, store: EcoAppStore) async {
        errorMessage = nil

        guard let payload = scannedPayload else {
            errorMessage = "No hay datos escaneados."
            return
        }

        guard let userID = store.user?.userId, !userID.isEmpty else {
            errorMessage = "Falta la sesión del usuario. Inicia sesión de nuevo."
            return
        }

        guard garmentsCount > 0 else {
            errorMessage = "La cantidad de prendas debe ser mayor a 0."
            return
        }

        isSubmitting = true

        do {
            let request = CreateDropoffRequest(
                userId: userID,
                centerId: payload.centerId,
                containerType: payload.containerType.rawValue,
                garmentsCount: garmentsCount
            )
            let response = try await APIService.shared.createDropoff(request: request)

            store.addDropOff(
                centerName: payload.centerId,
                containerType: payload.containerType.rawValue,
                garments: garmentsCount,
                pointsEarned: response.pointsEarned,
                id: response.dropoffId
            )
            store.syncPointsTotal(response.newPointsTotal)

            successMessage = "Entrega guardada. +\(response.pointsEarned) puntos"
            showConfirmSheet = false
            scannedPayload = nil
            scannedString = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }
}
