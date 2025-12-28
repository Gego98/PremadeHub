import Foundation

struct TeamInvitation: Identifiable {
    let id: String
    let fromUserId: String
    let fromUserName: String
    let fromUserTag: String
    let toUserId: String
    let teamType: TeamType
    let status: InvitationStatus
    let createdAt: Date
    
    // Computed property for display
    var inviterDisplayName: String {
        return "\(fromUserName)#\(fromUserTag)"
    }
}

enum InvitationStatus: String {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}
