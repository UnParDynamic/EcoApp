//
//  DropOffRecord.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation

struct DropOffRecord: Identifiable {
    let id = UUID()
    let centerName: String
    let date: Date
    let garmentsCount: Int
    let pointsEarned: Int
}