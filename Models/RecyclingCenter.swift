//
//  RecyclingCenter.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation
import CoreLocation

struct RecyclingCenter: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: RecyclingCenter, rhs: RecyclingCenter) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.subtitle == rhs.subtitle &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(subtitle)
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
}
