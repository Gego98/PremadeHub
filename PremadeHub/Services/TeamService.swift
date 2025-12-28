import Foundation
import FirebaseFirestore

class TeamService {
    static let shared = TeamService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Team Operations
    
    func createTeam(type: TeamType, name: String, privacy: TeamPrivacy, createdBy: String, members: [String]) async throws -> String {
        let teamData: [String: Any] = [
            "type": type.rawValue,
            "name": name,
            "privacy": privacy.rawValue,
            "createdBy": createdBy,
            "memberIds": members,
            "maxSize": type == .duo ? 2 : 5,
            "status": "active",
            "createdAt": Timestamp(date: Date())
        ]
        
        let docRef = try await db.collection("teams").addDocument(data: teamData)
        return docRef.documentID
    }
    
    func getMyTeams(userId: String) async throws -> [Team] {
        let snapshot = try await db.collection("teams")
            .whereField("memberIds", arrayContains: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments()
        
        var teams: [Team] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            let typeString = data["type"] as? String ?? "duo"
            let type: TeamType = typeString == "duo" ? .duo : .clash
            
            let name = data["name"] as? String ?? (type == .duo ? "Duo Team" : "Clash Team")
            
            let privacyString = data["privacy"] as? String ?? "invite_only"
            let privacy: TeamPrivacy = privacyString == "open" ? .open : .inviteOnly
            
            let createdBy = data["createdBy"] as? String ?? ""
            
            let memberIds = data["memberIds"] as? [String] ?? []
            
            // Fetch member details
            var members: [TeamMember] = []
            for memberId in memberIds {
                if let member = try? await fetchTeamMember(userId: memberId) {
                    members.append(member)
                }
            }
            
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            let team = Team(
                id: document.documentID,
                type: type,
                name: name,
                privacy: privacy,
                createdBy: createdBy,
                members: members,
                createdAt: createdAt
            )
            
            teams.append(team)
        }
        
        return teams
    }
    
    func addMemberToTeam(teamId: String, userId: String) async throws {
        try await db.collection("teams").document(teamId).updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ])
    }
    
    func removeMemberFromTeam(teamId: String, userId: String) async throws {
        try await db.collection("teams").document(teamId).updateData([
            "memberIds": FieldValue.arrayRemove([userId])
        ])
    }
    
    func deleteTeam(teamId: String) async throws {
        try await db.collection("teams").document(teamId).updateData([
            "status": "inactive"
        ])
    }
    
    
    func updateTeamName(teamId: String, name: String) async throws {
        try await db.collection("teams").document(teamId).updateData([
            "name": name
        ])
    }
    
    func updateTeamPrivacy(teamId: String, privacy: TeamPrivacy) async throws {
        try await db.collection("teams").document(teamId).updateData([
            "privacy": privacy.rawValue
        ])
    }
    
    // MARK: - Team Invitations
    
    func sendTeamInvitation(fromUserId: String, toUserId: String, teamType: TeamType) async throws -> String {
        // Get sender's info
        let senderProfile = try await UserService.shared.getUser(userId: fromUserId)
        
        let invitationData: [String: Any] = [
            "fromUserId": fromUserId,
            "fromUserName": senderProfile.summonerName,
            "fromUserTag": senderProfile.summonerTag,
            "toUserId": toUserId,
            "teamType": teamType == .duo ? "duo" : "clash",
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ]
        
        let docRef = try await db.collection("teamInvitations").addDocument(data: invitationData)
        return docRef.documentID
    }
    
    func getPendingInvitations(userId: String) async throws -> [TeamInvitation] {
        let snapshot = try await db.collection("teamInvitations")
            .whereField("toUserId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        var invitations: [TeamInvitation] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            let teamTypeString = data["teamType"] as? String ?? "duo"
            let teamType: TeamType = teamTypeString == "duo" ? .duo : .clash
            
            let invitation = TeamInvitation(
                id: document.documentID,
                fromUserId: data["fromUserId"] as? String ?? "",
                fromUserName: data["fromUserName"] as? String ?? "",
                fromUserTag: data["fromUserTag"] as? String ?? "",
                toUserId: data["toUserId"] as? String ?? "",
                teamType: teamType,
                status: .pending,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            invitations.append(invitation)
        }
        
        return invitations
    }
    
    func acceptTeamInvitation(invitationId: String, invitation: TeamInvitation) async throws -> String {
        // Update invitation status
        try await db.collection("teamInvitations").document(invitationId).updateData([
            "status": "accepted"
        ])
        
        // Create team with both users and default name
        let defaultName = invitation.teamType == .duo ? "Duo Team" : "Clash Team"
        let teamId = try await createTeam(
            type: invitation.teamType,
            name: defaultName,
            privacy: .inviteOnly,
            createdBy: invitation.fromUserId,
            members: [invitation.fromUserId, invitation.toUserId]
        )
        
        return teamId
    }
    
    func rejectTeamInvitation(invitationId: String) async throws {
        try await db.collection("teamInvitations").document(invitationId).updateData([
            "status": "rejected"
        ])
    }
    
    func checkExistingInvitation(fromUserId: String, toUserId: String) async throws -> Bool {
        let snapshot = try await db.collection("teamInvitations")
            .whereField("fromUserId", isEqualTo: fromUserId)
            .whereField("toUserId", isEqualTo: toUserId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func fetchTeamMember(userId: String) async throws -> TeamMember {
        let userProfile = try await UserService.shared.getUser(userId: userId)
        let isCurrentUser = userId == AuthService.shared.getCurrentUserId()
        
        return TeamMember(
            id: userId,
            summonerName: userProfile.summonerName,
            summonerTag: userProfile.summonerTag,
            rank: userProfile.rank,
            role: userProfile.role,
            isCurrentUser: isCurrentUser
        )
    }
    
    // MARK: - Join Requests
    
    func sendJoinRequest(teamId: String, userId: String) async throws -> String {
        // Check for existing pending request
        let existingRequest = try await db.collection("joinRequests")
            .whereField("teamId", isEqualTo: teamId)
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "pending")
            .getDocuments()
        
        if !existingRequest.documents.isEmpty {
            throw TeamServiceError.duplicateRequest
        }
        
        // Get user and team info
        let userProfile = try await UserService.shared.getUser(userId: userId)
        let teamDoc = try await db.collection("teams").document(teamId).getDocument()
        
        guard let teamData = teamDoc.data() else {
            throw TeamServiceError.teamNotFound
        }
        
        let teamName = teamData["name"] as? String ?? "Team"
        let teamTypeString = teamData["type"] as? String ?? "duo"
        let teamType: TeamType = teamTypeString == "duo" ? .duo : .clash
        
        let requestData: [String: Any] = [
            "teamId": teamId,
            "teamName": teamName,
            "teamType": teamType.rawValue,
            "userId": userId,
            "userName": userProfile.summonerName,
            "userTag": userProfile.summonerTag,
            "userRank": userProfile.rank,
            "userRole": userProfile.role,
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ]
        
        let docRef = try await db.collection("joinRequests").addDocument(data: requestData)
        return docRef.documentID
    }
    
    func getTeamJoinRequests(teamId: String) async throws -> [JoinRequest] {
        let snapshot = try await db.collection("joinRequests")
            .whereField("teamId", isEqualTo: teamId)
            .whereField("status", isEqualTo: "pending")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        var requests: [JoinRequest] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            let teamTypeString = data["teamType"] as? String ?? "duo"
            let teamType: TeamType = teamTypeString == "duo" ? .duo : .clash
            
            let request = JoinRequest(
                id: document.documentID,
                teamId: data["teamId"] as? String ?? "",
                teamName: data["teamName"] as? String ?? "",
                teamType: teamType,
                userId: data["userId"] as? String ?? "",
                userName: data["userName"] as? String ?? "",
                userTag: data["userTag"] as? String ?? "",
                userRank: data["userRank"] as? String ?? "",
                userRole: data["userRole"] as? String ?? "",
                status: .pending,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            requests.append(request)
        }
        
        return requests
    }
    
    func acceptJoinRequest(requestId: String, request: JoinRequest) async throws {
        // Update request status
        try await db.collection("joinRequests").document(requestId).updateData([
            "status": "accepted"
        ])
        
        // Add user to team
        try await addMemberToTeam(teamId: request.teamId, userId: request.userId)
    }
    
    func rejectJoinRequest(requestId: String) async throws {
        try await db.collection("joinRequests").document(requestId).updateData([
            "status": "rejected"
        ])
    }
    
    func getBrowsableTeams() async throws -> [Team] {
        let snapshot = try await db.collection("teams")
            .whereField("privacy", isEqualTo: "open")
            .whereField("status", isEqualTo: "active")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .getDocuments()
        
        var teams: [Team] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            let typeString = data["type"] as? String ?? "duo"
            let type: TeamType = typeString == "duo" ? .duo : .clash
            
            // Skip full teams
            let memberIds = data["memberIds"] as? [String] ?? []
            let maxSize = type == .duo ? 2 : 5
            if memberIds.count >= maxSize {
                continue
            }
            
            let name = data["name"] as? String ?? (type == .duo ? "Duo Team" : "Clash Team")
            let privacy: TeamPrivacy = .open
            let createdBy = data["createdBy"] as? String ?? ""
            
            // Fetch member details
            var members: [TeamMember] = []
            for memberId in memberIds {
                if let member = try? await fetchTeamMember(userId: memberId) {
                    members.append(member)
                }
            }
            
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            let team = Team(
                id: document.documentID,
                type: type,
                name: name,
                privacy: privacy,
                createdBy: createdBy,
                members: members,
                createdAt: createdAt
            )
            
            teams.append(team)
        }
        
        return teams
    }
}

// MARK: - Team Service Errors
enum TeamServiceError: LocalizedError {
    case teamNotFound
    case teamFull
    case invalidInvitation
    case notAuthorized
    case duplicateRequest
    
    var errorDescription: String? {
        switch self {
        case .teamNotFound:
            return "Team not found"
        case .teamFull:
            return "Team is full"
        case .invalidInvitation:
            return "Invalid invitation"
        case .notAuthorized:
            return "Not authorized to perform this action"
        case .duplicateRequest:
            return "You already have a pending request for this team"
        }
    }
}
