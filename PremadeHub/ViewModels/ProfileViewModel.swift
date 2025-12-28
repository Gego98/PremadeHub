import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userData: UserProfile?
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let userService = UserService.shared
    private let authService = AuthService.shared
    
    func loadUserProfile() {
        guard let userId = authService.getCurrentUserId() else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                userData = try await userService.getUser(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    func updateLookingForDuo(_ value: Bool) {
        guard let userId = authService.getCurrentUserId() else { return }
        
        // Update local state immediately (optimistic update)
        userData?.lookingForDuo = value
        
        Task {
            do {
                try await userService.updateLookingForDuo(userId: userId, isLooking: value)
            } catch {
                // Revert on error
                userData?.lookingForDuo = !value
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateLookingForClash(_ value: Bool) {
        guard let userId = authService.getCurrentUserId() else { return }
        
        // Update local state immediately (optimistic update)
        userData?.lookingForClash = value
        
        Task {
            do {
                try await userService.updateLookingForClash(userId: userId, isLooking: value)
            } catch {
                // Revert on error
                userData?.lookingForClash = !value
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateProfile(summonerName: String, summonerTag: String, region: String, rank: String, role: String) async throws {
        guard let userId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        let updateData: [String: Any] = [
            "summonerName": summonerName,
            "summonerTag": summonerTag,
            "region": region,
            "rank": rank,
            "role": role
        ]
        
        try await userService.updateUser(userId: userId, data: updateData)
        
        // Update local data
        userData?.rank = rank
        userData?.role = role
    }
    
    func logout() throws {
        try authService.logout()
    }
}
