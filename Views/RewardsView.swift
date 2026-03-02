//
//  RewardsView.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import SwiftUI

struct RewardsView: View {
    @EnvironmentObject private var store: EcoAppStore
    @StateObject private var vm = RewardsViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Tus puntos")
                        Spacer()
                        Text("\(store.points)")
                            .font(.headline)
                    }
                }

                Section("Canjea beneficios") {
                    ForEach(vm.rewards) { reward in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(reward.title).font(.headline)
                                    Text(reward.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(reward.costPoints) pts")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Button {
                                store.redeem(costPoints: reward.costPoints)
                            } label: {
                                Text(store.canRedeem(costPoints: reward.costPoints) ? "Canjear" : "Puntos insuficientes")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!store.canRedeem(costPoints: reward.costPoints))
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Recompensas")
        }
    }
}