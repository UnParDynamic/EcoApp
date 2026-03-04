import Foundation

struct DropOffRecord: Identifiable, Hashable {
    let id: String
    let centerName: String
    let containerType: String?
    let date: Date
    let garmentsCount: Int
    let pointsEarned: Int

    init(
        id: String = UUID().uuidString,
        centerName: String,
        containerType: String? = nil,
        date: Date,
        garmentsCount: Int,
        pointsEarned: Int
    ) {
        self.id = id
        self.centerName = centerName
        self.containerType = containerType
        self.date = date
        self.garmentsCount = garmentsCount
        self.pointsEarned = pointsEarned
    }
}
