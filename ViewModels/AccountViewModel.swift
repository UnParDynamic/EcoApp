import Foundation
import Combine

@MainActor
final class AccountViewModel: ObservableObject {
    @Published var history: [DropOffRecord] = []
    @Published var isLoadingHistory = false
    @Published var errorMessage: String?

    let displayName: String = "Usuario EcoApp"
    let locationText: String = "Monterrey, MX"

    func login(email: String, password: String, store: EcoAppStore) async throws -> UserResponse {
        let user = try await APIService.shared.login(email: email, password: password)
        store.setUser(user)
        return user
    }

    func signup(email: String,
                displayName: String,
                password: String,
                profileImageUrl: String? = nil,
                store: EcoAppStore) async throws -> UserResponse {
        let user = try await APIService.shared.signup(
            email: email,
            displayName: displayName,
            password: password,
            profileImageUrl: profileImageUrl
        )
        store.setUser(user)
        return user
    }

    func fetchHistory(userID: String, store: EcoAppStore) async {
        guard !userID.isEmpty else { return }

        isLoadingHistory = true
        errorMessage = nil

        do {
            let items = try await APIService.shared.fetchHistory(userID: userID)
            let mapped = items.map { item in
                DropOffRecord(
                    id: item.dropoffId,
                    centerName: item.centerId,
                    containerType: item.containerType,
                    date: parseDate(item.scannedAt),
                    garmentsCount: item.garmentsCount,
                    pointsEarned: item.pointsEarned
                )
            }

            history = mapped
            store.setHistory(mapped)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingHistory = false
    }

    private func parseDate(_ value: String) -> Date {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: value) {
            return date
        }

        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        return fallbackFormatter.date(from: value) ?? .now
    }
}
