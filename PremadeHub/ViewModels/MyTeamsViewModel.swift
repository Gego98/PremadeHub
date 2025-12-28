import Foundation
import Combine

@MainActor
class MyTeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let teamService = TeamService.shared
    private let authService = AuthService.shared
    
    func loadTeams() {
        guard let userId = authService.getCurrentUserId() else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                teams = try await teamService.getMyTeams(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
                teams = []
            }
            
            isLoading = false
        }
    }
    
    func createTeam(type: TeamType, name: String, privacy: TeamPrivacy) async throws {
        guard let userId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        _ = try await teamService.createTeam(
            type: type,
            name: name,
            privacy: privacy,
            createdBy: userId,
            members: [userId]
        )
        
        // Reload teams
        loadTeams()
    }
    
    func invitePlayer(teamId: String, playerId: String, teamType: TeamType) async throws {
        guard let userId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        _ = try await teamService.sendTeamInvitation(
            fromUserId: userId,
            toUserId: playerId,
            teamType: teamType
        )
    }
    
    func leaveTeam(teamId: String) async throws {
        guard let userId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        try await teamService.removeMemberFromTeam(teamId: teamId, userId: userId)
        
        // Reload teams
        loadTeams()
    }
}
