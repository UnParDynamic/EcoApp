//
//  CentersViewModel.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation
import Combine
import CoreLocation

@MainActor
final class CentersViewModel: ObservableObject {
    @Published var selectedCenter: RecyclingCenter?

    let centers: [RecyclingCenter] = [
        .init(name: "Centro Tec", subtitle: "Drop-off de textiles", coordinate: .init(latitude: 25.6510, longitude: -100.2890)),
        .init(name: "Cumbres Drop-Off", subtitle: "Recepción de ropa", coordinate: .init(latitude: 25.7270, longitude: -100.3950)),
        .init(name: "San Pedro Reciclaje", subtitle: "Centro aliado", coordinate: .init(latitude: 25.6555, longitude: -100.3610))
    ]
}
