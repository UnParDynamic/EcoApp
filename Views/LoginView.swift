import SwiftUI

struct LoginView: View {
    enum AuthMode: String, CaseIterable, Identifiable {
        case login = "Iniciar sesión"
        case signup = "Registrarse"

        var id: String { rawValue }
    }

    @Binding var isLoggedIn: Bool
    @EnvironmentObject private var store: EcoAppStore

    @StateObject private var vm = AccountViewModel()
    @State private var authMode: AuthMode = .login
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("EcoApp")
                        .font(.largeTitle.bold())

                    Picker("Modo de acceso", selection: $authMode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(authMode == .login ? "Inicia sesion para continuar" : "Crea una cuenta nueva")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if authMode == .signup {
                        TextField("Nombre para mostrar", text: $displayName)
                            .textContentType(.name)
                            .padding()
                            .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    }

                    TextField("Correo electrónico", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                    SecureField("Contraseña", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            await submit()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                            }
                            Text(buttonTitle)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSubmit)

                    Button(authMode == .login ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión") {
                        authMode = authMode == .login ? .signup : .login
                        errorMessage = nil
                    }
                    .font(.footnote)

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var canSubmit: Bool {
        guard !isLoading, !email.isEmpty, !password.isEmpty else { return false }
        if authMode == .signup {
            return !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    private var buttonTitle: String {
        if isLoading {
            return authMode == .login ? "Iniciando sesión..." : "Creando cuenta..."
        }
        return authMode.rawValue
    }

    private func submit() async {
        errorMessage = nil
        isLoading = true

        do {
            let user: UserResponse

            switch authMode {
            case .login:
                user = try await vm.login(email: email, password: password, store: store)
            case .signup:
                user = try await vm.signup(
                    email: email,
                    displayName: displayName,
                    password: password,
                    profileImageUrl: nil,
                    store: store
                )
            }

            UserDefaults.standard.set(user.userId, forKey: "currentUserID")
            UserDefaults.standard.set(user.email, forKey: "currentUserEmail")
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
        .environmentObject(EcoAppStore())
}
