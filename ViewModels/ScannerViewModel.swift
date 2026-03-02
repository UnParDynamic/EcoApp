//
//  ScannerViewModel.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import Foundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {
    // Después lo remplazas por el resultado del QR real
    @Published var lastScannedCenterName: String? = nil
}
