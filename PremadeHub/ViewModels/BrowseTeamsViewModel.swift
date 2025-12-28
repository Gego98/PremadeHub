import Foundation
import Combine

@MainActor
class BrowseTeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let teamService = TeamService.shared
    private let authService = AuthService.shared
    
    func loadTeams() {
        guard let currentUserId = authService.getCurrentUserId() else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let allTeams = try await teamService.getBrowsableTeams()
                
                // Filter out teams user is already in
                teams = allTeams.filter { team in
                    !team.members.contains { $0.id == currentUserId }
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                teams = []
            }
            
            isLoading = false
        }
    }
    
    func sendJoinRequest(teamId: String) async throws {
        guard let userId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        _ = try await teamService.sendJoinRequest(teamId: teamId, userId: userId)
    }
}
