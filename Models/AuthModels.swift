import Foundation

struct SignupRequest: Codable {
    let email: String
    let displayName: String
    let password: String
    let profileImageURL: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct UserResponse: Codable {
    let userId: String
    let email: String
    let displayName: String
    let pointsTotal: Int
    let profileImageURL: String?
}
