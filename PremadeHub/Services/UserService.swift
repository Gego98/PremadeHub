import Foundation
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - User CRUD Operations
    
    func createUser(userId: String, userData: [String: Any]) async throws {
        try await db.collection("users").document(userId).setData(userData)
    }
    
    func getUser(userId: String) async throws -> UserProfile {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard let data = document.data() else {
            throw UserServiceError.userNotFound
        }
        
        return UserProfile(
            id: userId,
            summonerName: data["summonerName"] as? String ?? "",
            summonerTag: data["summonerTag"] as? String ?? "",
            region: data["region"] as? String ?? "",
            rank: data["rank"] as? String ?? "Unranked",
            role: data["role"] as? String ?? "Fill",
            lookingForDuo: data["lookingForDuo"] as? Bool ?? false,
            lookingForClash: data["lookingForClash"] as? Bool ?? false,
            email: data["email"] as? String ?? ""
        )
    }
    
    func updateUser(userId: String, data: [String: Any]) async throws {
        try await db.collection("users").document(userId).updateData(data)
    }
    
    func updateLookingForDuo(userId: String, isLooking: Bool) async throws {
        try await db.collection("users").document(userId).updateData([
            "lookingForDuo": isLooking
        ])
    }
    
    func updateLookingForClash(userId: String, isLooking: Bool) async throws {
        try await db.collection("users").document(userId).updateData([
            "lookingForClash": isLooking
        ])
    }
    
    // MARK: - Search Operations
    
    func searchUsers(lookingForDuo: Bool? = nil, lookingForClash: Bool? = nil, role: String? = nil, rank: String? = nil) async throws -> [Player] {
        var query: Query = db.collection("users")
        
        // Apply filters
        if let lookingForDuo = lookingForDuo {
            query = query.whereField("lookingForDuo", isEqualTo: lookingForDuo)
        }
        
        if let lookingForClash = lookingForClash {
            query = query.whereField("lookingForClash", isEqualTo: lookingForClash)
        }
        
        let snapshot = try await query.getDocuments()
        
        var players: [Player] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            // Skip current user
            if let currentUserId = AuthService.shared.getCurrentUserId() {
                if document.documentID == currentUserId {
                    continue
                }
            }
            
            let playerRank = data["rank"] as? String ?? "Unranked"
            let playerRole = data["role"] as? String ?? "Fill"
            
            // Apply client-side filters
            if let roleFilter = role, roleFilter != "All", playerRole != roleFilter {
                continue
            }
            
            if let rankFilter = rank {
                if rankFilter != "All" && !matchesRankFilter(rank: playerRank, filter: rankFilter) {
                    continue
                }
            }
            
            let player = Player(
                id: document.documentID,
                summonerName: data["summonerName"] as? String ?? "",
                summonerTag: data["summonerTag"] as? String ?? "",
                region: data["region"] as? String ?? "",
                rank: playerRank,
                role: playerRole
            )
            
            players.append(player)
        }
        
        return players
    }
    
    private func matchesRankFilter(rank: String, filter: String) -> Bool {
        if filter == "Master+" {
            return rank.contains("Master") || rank.contains("Grandmaster") || rank.contains("Challenger")
        } else {
            return rank.hasPrefix(filter)
        }
    }
}

// MARK: - User Service Errors
enum UserServiceError: LocalizedError {
    case userNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidData:
            return "Invalid user data"
        }
    }
}
