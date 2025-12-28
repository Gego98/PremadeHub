import Foundation
import Combine

@MainActor
class InvitationsViewModel: ObservableObject {
    @Published var invitations: [TeamInvitation] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let teamService = TeamService.shared
    private let authService = AuthService.shared
    
    func loadInvitations() {
        guard let userId = authService.getCurrentUserId() else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                invitations = try await teamService.getPendingInvitations(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                invitations = []
            }
            
            isLoading = false
        }
    }
    
    func acceptInvitation(_ invitation: TeamInvitation) {
        Task {
            do {
                let teamId = try await teamService.acceptTeamInvitation(
                    invitationId: invitation.id,
                    invitation: invitation
                )
                
                // Remove from list
                invitations.removeAll { $0.id == invitation.id }
                
                print("Team created with ID: \(teamId)")
            } catch {
                errorMessage = "Failed to accept invitation: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    func rejectInvitation(_ invitationId: String) {
        Task {
            do {
                try await teamService.rejectTeamInvitation(invitationId: invitationId)
                
                // Remove from list
                invitations.removeAll { $0.id == invitationId }
            } catch {
                errorMessage = "Failed to reject invitation: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}
