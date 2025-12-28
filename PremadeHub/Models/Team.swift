import Foundation

struct Team: Identifiable {
    let id: String
    let type: TeamType
    var name: String
    var privacy: TeamPrivacy
    let createdBy: String
    let members: [TeamMember]
    let createdAt: Date
    
    // Computed properties for team size management
    var maxSize: Int {
        switch type {
        case .duo:
            return 2
        case .clash:
            return 5
        }
    }
    
    var currentSize: Int {
        return members.count
    }
    
    var availableSlots: Int {
        return maxSize - currentSize
    }
    
    var isFull: Bool {
        return currentSize >= maxSize
    }
    
    var availableSlotsText: String {
        if isFull {
            return "Team is full"
        } else if availableSlots == 1 {
            return "1 slot available"
        } else {
            return "\(availableSlots) slots available"
        }
    }
}

enum TeamType: String {
    case duo = "duo"
    case clash = "clash"
}

enum TeamPrivacy: String {
    case open = "open"           // Anyone can request to join
    case inviteOnly = "invite_only"  // Only invited players can join
}

struct TeamMember: Identifiable {
    let id: String
    let summonerName: String
    let summonerTag: String
    let rank: String
    let role: String
    let isCurrentUser: Bool
}
