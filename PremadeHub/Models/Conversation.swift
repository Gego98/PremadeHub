import Foundation

struct Conversation: Identifiable {
    let id: String
    let otherUser: ConversationUser
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
}

struct ConversationUser: Identifiable {
    let id: String
    let summonerName: String
    let summonerTag: String
}

struct Message: Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let text: String
    let timestamp: Date
    let read: Bool
}
