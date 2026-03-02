//
//  CentersView.swift
//  EcoApp
//
//  Created by Mar Reyes on 02/03/26.
//


import SwiftUI
import MapKit

struct CentersView: View {
    @StateObject private var vm = CentersViewModel()

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.6866, longitude: -100.3161),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    )

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                ForEach(vm.centers) { center in
                    Annotation(center.name, coordinate: center.coordinate) {
                        Button {
                            vm.selectedCenter = center
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .accessibilityLabel(center.name)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Centros")
            .sheet(item: $vm.selectedCenter) { center in
                CenterDetailSheet(center: center)
            }
        }
    }
}
