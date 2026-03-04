import Foundation

enum ContainerType: String, CaseIterable, Identifiable, Codable {
    case cotton
    case synthetic
    case mixed
    case unknown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cotton:
            return "Algodón"
        case .synthetic:
            return "Sintético"
        case .mixed:
            return "Mixto"
        case .unknown:
            return "Desconocido"
        }
    }
}

struct DropoffQRPayload: Equatable {
    let centerId: String
    let containerType: ContainerType
}

struct CreateDropoffRequest: Codable {
    let userId: String
    let centerId: String
    let containerType: String
    let garmentsCount: Int
}

struct CreateDropoffResponse: Codable {
    let dropoffId: String
    let pointsEarned: Int
    let newPointsTotal: Int
    let scannedAt: String?
}

struct UserHistoryItemResponse: Codable {
    let dropoffId: String
    let centerId: String
    let containerType: String
    let garmentsCount: Int
    let pointsEarned: Int
    let scannedAt: String
}
