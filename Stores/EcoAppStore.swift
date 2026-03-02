//
//  EcoAppStore.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation
import Combine

@MainActor
final class EcoAppStore: ObservableObject {
    @Published var points: Int = 320
    @Published var history: [DropOffRecord] = [
        .init(centerName: "Centro Tec", date: .now.addingTimeInterval(-172_800), garmentsCount: 8, pointsEarned: 80),
        .init(centerName: "Cumbres Drop-Off", date: .now.addingTimeInterval(-691_200), garmentsCount: 5, pointsEarned: 50)
    ]

    let pointsPerGarment = 10

    func addDropOff(centerName: String, garments: Int) {
        let earned = garments * pointsPerGarment
        points += earned
        history.insert(.init(centerName: centerName, date: .now, garmentsCount: garments, pointsEarned: earned), at: 0)
    }

    func canRedeem(costPoints: Int) -> Bool {
        points >= costPoints
    }

    func redeem(costPoints: Int) {
        guard canRedeem(costPoints: costPoints) else { return }
        points -= costPoints
    }
}
