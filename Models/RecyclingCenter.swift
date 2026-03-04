import Foundation
import CoreLocation

struct RecyclingCenter: Identifiable, Hashable, Codable {
    let centerId: String
    let name: String
    let address: String?
    let latitude: Double
    let longitude: Double

    var id: String { centerId }

    var subtitle: String {
        if let address, !address.isEmpty {
            return address
        }
        return centerId
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: RecyclingCenter, rhs: RecyclingCenter) -> Bool {
        lhs.centerId == rhs.centerId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(centerId)
    }
}
