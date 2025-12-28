import Foundation
import FirebaseFirestore

class MessageService {
    static let shared = MessageService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Conversation Operations
    
    func getOrCreateConversation(participantIds: [String]) async throws -> String {
        // Sort participant IDs to ensure consistent conversation lookup
        let sortedIds = participantIds.sorted()
        
        // Check if conversation already exists
        let snapshot = try await db.collection("conversations")
            .whereField("participants", isEqualTo: sortedIds)
            .getDocuments()
        
        if let existingConversation = snapshot.documents.first {
            return existingConversation.documentID
        }
        
        // Create new conversation
        let conversationData: [String: Any] = [
            "participants": sortedIds,
            "lastMessage": "",
            "lastMessageTime": Timestamp(date: Date()),
            "createdAt": Timestamp(date: Date())
        ]
        
        let docRef = try await db.collection("conversations").addDocument(data: conversationData)
        return docRef.documentID
    }
    
    func getConversations(userId: String) async throws -> [Conversation] {
        let snapshot = try await db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .order(by: "lastMessageTime", descending: true)
            .getDocuments()
        
        var conversations: [Conversation] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            let participants = data["participants"] as? [String] ?? []
            let otherUserId = participants.first(where: { $0 != userId }) ?? ""
            
            // Fetch other user's profile
            guard let otherUser = try? await fetchConversationUser(userId: otherUserId) else {
                continue
            }
            
            let lastMessage = data["lastMessage"] as? String ?? ""
            let lastMessageTime = (data["lastMessageTime"] as? Timestamp)?.dateValue() ?? Date()
            
            // Count unread messages
            let unreadCount = try await getUnreadCount(conversationId: document.documentID, userId: userId)
            
            let conversation = Conversation(
                id: document.documentID,
                otherUser: otherUser,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                unreadCount: unreadCount
            )
            
            conversations.append(conversation)
        }
        
        return conversations
    }
    
    // MARK: - Message Operations
    
    func sendMessage(conversationId: String, senderId: String, text: String) async throws -> String {
        let messageData: [String: Any] = [
            "conversationId": conversationId,
            "senderId": senderId,
            "text": text,
            "timestamp": Timestamp(date: Date()),
            "read": false
        ]
        
        let docRef = try await db.collection("messages").addDocument(data: messageData)
        
        // Update conversation's last message
        try await db.collection("conversations").document(conversationId).updateData([
            "lastMessage": text,
            "lastMessageTime": Timestamp(date: Date())
        ])
        
        return docRef.documentID
    }
    
    func getMessages(conversationId: String) async throws -> [Message] {
        let snapshot = try await db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        var messages: [Message] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            let message = Message(
                id: document.documentID,
                conversationId: data["conversationId"] as? String ?? "",
                senderId: data["senderId"] as? String ?? "",
                text: data["text"] as? String ?? "",
                timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                read: data["read"] as? Bool ?? false
            )
            
            messages.append(message)
        }
        
        return messages
    }
    
    func markMessageAsRead(messageId: String) async throws {
        try await db.collection("messages").document(messageId).updateData([
            "read": true
        ])
    }
    
    func markConversationAsRead(conversationId: String, userId: String) async throws {
        let snapshot = try await db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .whereField("read", isEqualTo: false)
            .getDocuments()
        
        for document in snapshot.documents {
            let data = document.data()
            let senderId = data["senderId"] as? String ?? ""
            
            // Only mark as read if current user is not the sender
            if senderId != userId {
                try await markMessageAsRead(messageId: document.documentID)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func fetchConversationUser(userId: String) async throws -> ConversationUser {
        let userProfile = try await UserService.shared.getUser(userId: userId)
        
        return ConversationUser(
            id: userId,
            summonerName: userProfile.summonerName,
            summonerTag: userProfile.summonerTag
        )
    }
    
    private func getUnreadCount(conversationId: String, userId: String) async throws -> Int {
        let snapshot = try await db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .whereField("read", isEqualTo: false)
            .getDocuments()
        
        // Count messages not sent by current user
        var count = 0
        for document in snapshot.documents {
            let data = document.data()
            let senderId = data["senderId"] as? String ?? ""
            if senderId != userId {
                count += 1
            }
        }
        
        return count
    }
}

// MARK: - Message Service Errors
enum MessageServiceError: LocalizedError {
    case conversationNotFound
    case messageNotFound
    case invalidParticipants
    
    var errorDescription: String? {
        switch self {
        case .conversationNotFound:
            return "Conversation not found"
        case .messageNotFound:
            return "Message not found"
        case .invalidParticipants:
            return "Invalid participants"
        }
    }
}
