import Foundation
import Combine

@MainActor
final class CentersViewModel: ObservableObject {
    @Published var selectedCenter: RecyclingCenter?
    @Published var centers: [RecyclingCenter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchCenters() async {
        isLoading = true
        errorMessage = nil

        do {
            centers = try await APIService.shared.fetchCenters()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
