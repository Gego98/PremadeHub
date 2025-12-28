import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        guard let userId = result.user.uid as String? else {
            throw AuthError.noUserID
        }
        return userId
    }
    
    func register(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        guard let userId = result.user.uid as String? else {
            throw AuthError.noUserID
        }
        return userId
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func isAuthenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case noUserID
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .noUserID:
            return "Failed to get user ID"
        case .notAuthenticated:
            return "User not authenticated"
        }
    }
}
