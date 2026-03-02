//
//  RewardsViewModel.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation
import Combine

@MainActor
final class RewardsViewModel: ObservableObject {
    let rewards: [Reward] = [
        .init(title: "Cupón 10% Tienda X", subtitle: "Válido 30 días", costPoints: 250),
        .init(title: "Vale digital $100", subtitle: "Entrega por correo", costPoints: 1000),
        .init(title: "Envío gratis", subtitle: "En comercios aliados", costPoints: 400)
    ]
}
