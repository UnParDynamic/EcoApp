import Foundation
import Combine
import UIKit

@MainActor
final class EcoAppStore: ObservableObject {
    @Published private(set) var user: UserResponse?
    @Published private(set) var points: Int = 0
    @Published var history: [DropOffRecord] = []
    @Published var profileImagePath: String?

    private let profileImageKey = "localProfileImageFilename"

    init() {
        profileImagePath = UserDefaults.standard.string(forKey: profileImageKey)
    }

    func setUser(_ user: UserResponse) {
        self.user = user
        self.points = user.pointsTotal
    }

    func restoreSession(userID: String, email: String) {
        guard !userID.isEmpty else { return }
        guard user == nil else { return }

        let restored = UserResponse(
            userId: userID,
            email: email,
            displayName: "Usuario EcoApp",
            pointsTotal: points,
            profileImageURL: nil
        )
        setUser(restored)
    }

    func clearSession() {
        user = nil
        points = 0
        history = []
    }

    func addDropOff(
        centerName: String,
        containerType: String? = nil,
        garments: Int,
        pointsEarned: Int,
        date: Date = .now,
        id: String = UUID().uuidString
    ) {
        points += pointsEarned
        if let user {
            self.user = UserResponse(
                userId: user.userId,
                email: user.email,
                displayName: user.displayName,
                pointsTotal: points,
                profileImageURL: user.profileImageURL
            )
        }

        history.insert(
            .init(
                id: id,
                centerName: centerName,
                containerType: containerType,
                date: date,
                garmentsCount: garments,
                pointsEarned: pointsEarned
            ),
            at: 0
        )
    }

    func setHistory(_ history: [DropOffRecord]) {
        self.history = history
    }

    func syncPointsTotal(_ newTotal: Int) {
        points = newTotal

        if let user {
            self.user = UserResponse(
                userId: user.userId,
                email: user.email,
                displayName: user.displayName,
                pointsTotal: newTotal,
                profileImageURL: user.profileImageURL
            )
        }
    }

    func canRedeem(costPoints: Int) -> Bool {
        points >= costPoints
    }

    func redeem(costPoints: Int) {
        guard canRedeem(costPoints: costPoints) else { return }
        points -= costPoints

        if let user {
            self.user = UserResponse(
                userId: user.userId,
                email: user.email,
                displayName: user.displayName,
                pointsTotal: points,
                profileImageURL: user.profileImageURL
            )
        }
    }

    func saveProfileImageData(_ data: Data) throws {
        let filename = "profile.jpg"
        let url = documentsDirectory.appendingPathComponent(filename)

        try data.write(to: url, options: .atomic)
        profileImagePath = filename
        UserDefaults.standard.set(filename, forKey: profileImageKey)
    }

    func loadProfileImage() -> UIImage? {
        guard let profileImagePath else { return nil }
        let url = documentsDirectory.appendingPathComponent(profileImagePath)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
