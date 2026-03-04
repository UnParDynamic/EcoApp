import Foundation

struct APIErrorResponse: Codable {
    let detail: String
}

enum APIError: LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case couldNotConnect
    case notConnectedToInternet
    case requestTimedOut
    case networkConnectionLost
    case serverMessage(String)
    case unknown(Error)

    init(statusCode: Int) {
        switch statusCode {
        case 400:
            self = .serverError(statusCode: 400)
        case 401:
            self = .serverError(statusCode: 401)
        case 403:
            self = .serverError(statusCode: 403)
        case 404:
            self = .serverError(statusCode: 404)
        case 409:
            self = .serverError(statusCode: 409)
        case 422:
            self = .serverError(statusCode: 422)
        case 429:
            self = .serverError(statusCode: 429)
        case 500:
            self = .serverError(statusCode: 500)
        case 502:
            self = .serverError(statusCode: 502)
        case 503:
            self = .serverError(statusCode: 503)
        case 504:
            self = .serverError(statusCode: 504)
        default:
            self = .serverError(statusCode: statusCode)
        }
    }

    init(urlError: URLError) {
        switch urlError.code {
        case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            self = .couldNotConnect
        case .notConnectedToInternet:
            self = .notConnectedToInternet
        case .timedOut:
            self = .requestTimedOut
        case .networkConnectionLost:
            self = .networkConnectionLost
        default:
            self = .unknown(urlError)
        }
    }

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .serverError(let statusCode):
            switch statusCode {
            case 400:
                return "400: Solicitud inválida."
            case 401:
                return "401: No autorizado. Verifica tus credenciales."
            case 403:
                return "403: Acceso denegado."
            case 404:
                return "404: Recurso no encontrado."
            case 409:
                return "409: Conflicto."
            case 422:
                return "422: Solicitud no procesable."
            case 429:
                return "429: Demasiadas solicitudes. Intenta de nuevo en un momento."
            case 500:
                return "500: Error interno del servidor."
            case 502:
                return "502: Puerta de enlace incorrecta."
            case 503:
                return "503: Servicio no disponible."
            case 504:
                return "504: Tiempo de espera agotado en la puerta de enlace."
            default:
                return "Error del servidor (\(statusCode))."
            }
        case .noData:
            return "No se recibieron datos del servidor."
        case .couldNotConnect:
            return "No se pudo conectar con el servidor."
        case .notConnectedToInternet:
            return "Sin conexión a internet."
        case .requestTimedOut:
            return "La solicitud excedió el tiempo de espera. Intenta de nuevo."
        case .networkConnectionLost:
            return "Se perdió la conexión de red."
        case .serverMessage(let message):
            return Self.localizedServerMessage(message)
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    private static func localizedServerMessage(_ message: String) -> String {
        switch message {
        case "Email already registered.":
            return "El correo ya está registrado."
        case "Invalid email or password.":
            return "Correo o contraseña inválidos."
        case "User not found.":
            return "Usuario no encontrado."
        case "Center not found.":
            return "Centro no encontrado."
        case "Password must be <= 72 bytes for bcrypt.":
            return "La contraseña debe tener un máximo de 72 bytes para bcrypt."
        default:
            if message.hasPrefix("Signup failed:") {
                return message.replacingOccurrences(of: "Signup failed:", with: "Error al registrarse:")
            }
            if message.hasPrefix("Login failed:") {
                return message.replacingOccurrences(of: "Login failed:", with: "Error al iniciar sesión:")
            }
            if message.hasPrefix("Create dropoff failed:") {
                return message.replacingOccurrences(of: "Create dropoff failed:", with: "Error al registrar entrega:")
            }
            if message.hasPrefix("History fetch failed:") {
                return message.replacingOccurrences(of: "History fetch failed:", with: "Error al obtener historial:")
            }
            if message.hasPrefix("List centers failed:") {
                return message.replacingOccurrences(of: "List centers failed:", with: "Error al obtener centros:")
            }
            return message
        }
    }
}

final class APIService {
    static let shared = APIService()

    let baseURL: URL

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    private init() {
        if let override = ProcessInfo.processInfo.environment["ECOAPP_API_BASE_URL"],
           let overrideURL = URL(string: override) {
            baseURL = overrideURL
        } else {
            #if targetEnvironment(simulator)
            baseURL = URL(string: "http://127.0.0.1:8000")!
            #else
            // Base por defecto para dispositivo físico.
            baseURL = URL(string: "http://10.22.188.160:8000")!
            #endif
        }
    }

    func signup(email: String,
                displayName: String,
                password: String,
                profileImageUrl: String? = nil) async throws -> UserResponse {
        let body = SignupRequest(
            email: email,
            displayName: displayName,
            password: password,
            profileImageURL: profileImageUrl
        )
        return try await performRequest(path: "signup", method: "POST", body: body)
    }

    func login(email: String, password: String) async throws -> UserResponse {
        let body = LoginRequest(email: email, password: password)
        return try await performRequest(path: "login", method: "POST", body: body)
    }

    func createDropoff(request: CreateDropoffRequest) async throws -> CreateDropoffResponse {
        try await performRequest(path: "dropoffs", method: "POST", body: request)
    }

    func fetchCenters() async throws -> [RecyclingCenter] {
        try await performRequest(path: "centers", method: "GET")
    }

    func fetchHistory(userID: String) async throws -> [UserHistoryItemResponse] {
        try await performRequest(path: "users/\(userID)/history", method: "GET")
    }

    private func performRequest<ResponseBody: Decodable>(
        path: String,
        method: String
    ) async throws -> ResponseBody {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        return try await execute(request)
    }

    private func performRequest<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: String,
        body: RequestBody
    ) async throws -> ResponseBody {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        return try await execute(request)
    }

    private func execute<ResponseBody: Decodable>(_ request: URLRequest) async throws -> ResponseBody {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverMessage(apiError.detail)
                }
                throw APIError(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                throw APIError.noData
            }

            do {
                return try decoder.decode(ResponseBody.self, from: data)
            } catch {
                throw APIError.unknown(error)
            }
        } catch let urlError as URLError {
            throw APIError(urlError: urlError)
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.unknown(error)
        }
    }
}
