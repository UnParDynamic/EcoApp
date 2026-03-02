//
//  AccountView.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var store: EcoAppStore
    @StateObject private var vm = AccountViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 44))
                            .symbolRenderingMode(.hierarchical)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(vm.displayName).font(.headline)
                            Text(vm.locationText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    HStack {
                        Text("Puntos")
                        Spacer()
                        Text("\(store.points)").font(.headline)
                    }
                }

                Section("Historial de entregas") {
                    if store.history.isEmpty {
                        Text("Aún no hay entregas registradas.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.history) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.centerName).font(.headline)
                                Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(item.garmentsCount) prendas • +\(item.pointsEarned) pts")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Ajustes") {
                    Label("Notificaciones", systemImage: "bell")
                    Label("Privacidad", systemImage: "hand.raised")
                    Label("Soporte", systemImage: "questionmark.circle")
                }
            }
            .navigationTitle("Cuenta")
        }
    }
}