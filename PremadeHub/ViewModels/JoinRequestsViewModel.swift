import Foundation
import Combine

@MainActor
class JoinRequestsViewModel: ObservableObject {
    @Published var requests: [JoinRequest] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let teamService = TeamService.shared
    
    func loadRequests(teamId: String) {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                requests = try await teamService.getTeamJoinRequests(teamId: teamId)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                requests = []
            }
            
            isLoading = false
        }
    }
    
    func acceptRequest(_ request: JoinRequest) async throws {
        try await teamService.acceptJoinRequest(requestId: request.id, request: request)
        // Remove from list
        requests.removeAll { $0.id == request.id }
    }
    
    func rejectRequest(_ requestId: String) async throws {
        try await teamService.rejectJoinRequest(requestId: requestId)
        // Remove from list
        requests.removeAll { $0.id == requestId }
    }
}
