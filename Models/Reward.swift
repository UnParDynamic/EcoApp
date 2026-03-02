//
//  Reward.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation

struct Reward: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let costPoints: Int
}