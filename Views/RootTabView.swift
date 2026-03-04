import SwiftUI

struct RootTabView: View {
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
    }
}
