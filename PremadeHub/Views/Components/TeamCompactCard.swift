import SwiftUI

struct TeamCompactCard: View {
    let team: Team
    
    var body: some View {
        HStack(spacing: 15) {
            // Team Icon
            ZStack {
                Circle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: team.type == .duo ? "person.2.fill" : "person.3.fill")
                    .foregroundColor(.cyan)
                    .font(.title3)
            }
            
            // Team Info
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text(team.type == .duo ? "Duo" : "Clash")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if team.privacy == .open {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                            Text("Open")
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Team Size Badge
            HStack(spacing: 4) {
                Text("\(team.currentSize)/\(team.maxSize)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(team.isFull ? .green : .cyan)
                
                if team.isFull {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(team.isFull ? Color.green.opacity(0.2) : Color.cyan.opacity(0.2))
            .cornerRadius(12)
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    TeamCompactCard(team: Team(
        id: "123",
        type: .duo,
        name: "My Awesome Team",
        privacy: .open,
        createdBy: "user1",
        members: [
            TeamMember(id: "1", summonerName: "Player1", summonerTag: "1234", rank: "Gold II", role: "Mid", isCurrentUser: true)
        ],
        createdAt: Date()
    ))
    .padding()
    .background(Color(red: 0.01, green: 0.09, blue: 0.15))
}
