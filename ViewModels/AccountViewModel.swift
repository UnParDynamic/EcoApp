//
//  AccountViewModel.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation
import Combine

@MainActor
final class AccountViewModel: ObservableObject {
    let displayName: String = "EcoApp User"
    let locationText: String = "Monterrey, MX"
}
