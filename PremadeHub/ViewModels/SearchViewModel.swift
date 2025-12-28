import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var players: [Player] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchType = 0 // 0 = Duo, 1 = Clash
    @Published var selectedRole = "All"
    @Published var selectedRank = "All"
    
    private let userService = UserService.shared
    
    func loadPlayers() {
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                let lookingForDuo = searchType == 0 ? true : nil
                let lookingForClash = searchType == 1 ? true : nil
                let role = selectedRole != "All" ? selectedRole : nil
                let rank = selectedRank != "All" ? selectedRank : nil
                
                players = try await userService.searchUsers(
                    lookingForDuo: lookingForDuo,
                    lookingForClash: lookingForClash,
                    role: role,
                    rank: rank
                )
            } catch {
                errorMessage = error.localizedDescription
                players = []
            }
            
            isLoading = false
        }
    }
    
    func updateSearchType(_ type: Int) {
        searchType = type
        loadPlayers()
    }
    
    func updateRole(_ role: String) {
        selectedRole = role
        loadPlayers()
    }
    
    func updateRank(_ rank: String) {
        selectedRank = rank
        loadPlayers()
    }
}
