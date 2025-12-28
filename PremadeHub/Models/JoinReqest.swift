import Foundation

struct JoinRequest: Identifiable {
    let id: String
    let teamId: String
    let teamName: String
    let teamType: TeamType
    let userId: String
    let userName: String
    let userTag: String
    let userRank: String
    let userRole: String
    let status: JoinRequestStatus
    let createdAt: Date
    
    var userDisplayName: String {
        return "\(userName)#\(userTag)"
    }
}

enum JoinRequestStatus: String {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
}
