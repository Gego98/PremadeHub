import Foundation
import Combine

@MainActor
class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private let messageService = MessageService.shared
    private let authService = AuthService.shared
    
    func loadConversations() {
        guard let userId = authService.getCurrentUserId() else {
            errorMessage = "User not authenticated"
            isLoading = false
            return
        }
        
        Task {
            isLoading = true
            errorMessage = nil
            
            do {
                conversations = try await messageService.getConversations(userId: userId)
            } catch {
                errorMessage = error.localizedDescription
                conversations = []
            }
            
            isLoading = false
        }
    }
    
    func startConversation(with userId: String) async throws -> String {
        guard let currentUserId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        let conversationId = try await messageService.getOrCreateConversation(
            participantIds: [currentUserId, userId]
        )
        
        // Reload conversations
        loadConversations()
        
        return conversationId
    }
    
    func markConversationAsRead(conversationId: String) async throws {
        guard let userId = authService.getCurrentUserId() else {
            throw AuthError.notAuthenticated
        }
        
        try await messageService.markConversationAsRead(
            conversationId: conversationId,
            userId: userId
        )
        
        // Reload conversations to update unread count
        loadConversations()
    }
}
