//
//  RootTabView.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import SwiftUI

struct RootTabView: View {
    @StateObject private var store = EcoAppStore()

    var body: some View {
        TabView {
            CentersView()
                .tabItem { Label("Centros", systemImage: "map") }

            ScannerView()
                .tabItem { Label("Escanear", systemImage: "qrcode.viewfinder") }

            RewardsView()
                .tabItem { Label("Recompensas", systemImage: "gift") }

            AccountView()
                .tabItem { Label("Cuenta", systemImage: "person.crop.circle") }
        }
        .environmentObject(store)
    }
}