import SwiftUI

@main
struct EcoAppApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("currentUserID") private var currentUserID = ""
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @StateObject private var store = EcoAppStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn && !currentUserID.isEmpty {
                    RootTabView()
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
            .environmentObject(store)
            .task {
                if isLoggedIn && !currentUserID.isEmpty {
                    store.restoreSession(userID: currentUserID, email: currentUserEmail)
                }
            }
        }
    }
}
