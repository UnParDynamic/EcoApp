import SwiftUI
import PhotosUI
import UIKit

struct AccountView: View {
    @EnvironmentObject private var store: EcoAppStore
    @StateObject private var vm = AccountViewModel()

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("currentUserID") private var currentUserID = ""
    @AppStorage("currentUserEmail") private var currentUserEmail = ""

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileUIImage: UIImage?
    @State private var photoErrorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        if let profileUIImage {
                            Image(uiImage: profileUIImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 56))
                                .symbolRenderingMode(.hierarchical)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.user?.displayName ?? vm.displayName)
                                .font(.headline)
                            Text(vm.locationText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Cambiar foto", systemImage: "photo")
                    }

                    HStack {
                        Text("Puntos")
                        Spacer()
                        Text("\(store.user?.pointsTotal ?? store.points)")
                            .font(.headline)
                    }
                }

                Section("Historial de entregas") {
                    if vm.isLoadingHistory {
                        ProgressView("Cargando historial...")
                    } else if vm.history.isEmpty {
                        Text("Aún no hay entregas registradas.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vm.history) { item in
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

                if let errorMessage = vm.errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                if let photoErrorMessage {
                    Section {
                        Text(photoErrorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("Ajustes") {
                    Label("Notificaciones", systemImage: "bell")
                    Label("Privacidad", systemImage: "hand.raised")
                    Label("Soporte", systemImage: "questionmark.circle")

                    Button(role: .destructive) {
                        currentUserID = ""
                        currentUserEmail = ""
                        isLoggedIn = false
                        store.clearSession()
                        vm.history = []
                    } label: {
                        Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Cuenta")
            .task(id: currentUserID) {
                await vm.fetchHistory(userID: currentUserID, store: store)
                profileUIImage = store.loadProfileImage()
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    await handlePhotoSelection(newValue)
                }
            }
        }
    }

    private func handlePhotoSelection(_ item: PhotosPickerItem) async {
        photoErrorMessage = nil

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data),
                  let jpegData = image.jpegData(compressionQuality: 0.85) else {
                photoErrorMessage = "No se pudo cargar la imagen seleccionada."
                return
            }

            try store.saveProfileImageData(jpegData)
            profileUIImage = UIImage(data: jpegData)
        } catch {
            photoErrorMessage = error.localizedDescription
        }
    }
}
