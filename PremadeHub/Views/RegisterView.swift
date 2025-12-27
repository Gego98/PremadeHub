import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var summonerName = ""
    @State private var summonerTag = ""
    @State private var selectedRegion = "NA"
    @State private var selectedRank = "Unranked"
    @State private var selectedDivision = "IV"
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var navigateToHome = false
    
    let regions = ["NA", "EUW", "EUNE", "KR", "BR", "LAN", "LAS", "OCE", "RU", "TR", "JP"]
    let ranksWithDivisions = ["Iron", "Bronze", "Silver", "Gold", "Platinum", "Emerald", "Diamond"]
    let ranksWithoutDivisions = ["Unranked", "Master", "Grandmaster", "Challenger"]
    let divisions = ["I", "II", "III", "IV"]
    
    var allRanks: [String] {
        ranksWithoutDivisions + ranksWithDivisions
    }
    
    var showDivisionPicker: Bool {
        ranksWithDivisions.contains(selectedRank)
    }
    
    var fullRank: String {
        if showDivisionPicker {
            return "\(selectedRank) \(selectedDivision)"
        } else {
            return selectedRank
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.01, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.cyan)
                        
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Join the League community")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    // Summoner Name + Tag (inline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Riot ID")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 0) {
                            // Summoner Name
                            ZStack(alignment: .leading) {
                                if summonerName.isEmpty {
                                    Text("Summoner Name")
                                        .foregroundColor(.gray.opacity(0.5))
                                        .padding(.leading, 16)
                                }
                                TextField("", text: $summonerName)
                                    .foregroundColor(.white)
                                    .padding()
                                    .autocorrectionDisabled()
                            }
                            .background(Color.white.opacity(0.1))
                            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                                topLeading: 10,
                                bottomLeading: 10,
                                bottomTrailing: 0,
                                topTrailing: 0
                            )))
                            
                            // # Separator
                            Text("#")
                                .font(.title3)
                                .foregroundColor(.gray)
                                .frame(width: 30)
                                .frame(maxHeight: .infinity)
//                                .background(Color.white.opacity(0.05))
                            
                            // Summoner Tag
                            ZStack {
                                if summonerTag.isEmpty {
                                    Text("TAG")
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                TextField("", text: $summonerTag)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .onChange(of: summonerTag) { oldValue, newValue in
                                        // Limit to 5 characters
                                        if newValue.count > 5 {
                                            summonerTag = String(newValue.prefix(5))
                                        }
                                    }
                            }
                            .frame(width: 100)
                            .background(Color.white.opacity(0.1))
                            .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
                                topLeading: 0,
                                bottomLeading: 0,
                                bottomTrailing: 10,
                                topTrailing: 10
                            )))
                        }
                        .frame(height: 50)
                    }
                    .padding(.horizontal, 30)
                    
                    // Region Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Region")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Menu {
                            ForEach(regions, id: \.self) { region in
                                Button(action: {
                                    selectedRegion = region
                                }) {
                                    HStack {
                                        Text(region)
                                        if selectedRegion == region {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedRegion)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Rank Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Rank")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 10) {
                            // Rank Tier
                            Menu {
                                ForEach(allRanks, id: \.self) { rank in
                                    Button(action: {
                                        selectedRank = rank
                                        // Reset to highest division when changing rank
                                        if ranksWithDivisions.contains(rank) {
                                            selectedDivision = "IV"
                                        }
                                    }) {
                                        HStack {
                                            Text(rank)
                                            if selectedRank == rank {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRank)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .frame(maxWidth: showDivisionPicker ? .infinity : .infinity)
                            
                            // Division Picker (only for Iron-Diamond)
                            if showDivisionPicker {
                                Menu {
                                    ForEach(divisions, id: \.self) { division in
                                        Button(action: {
                                            selectedDivision = division
                                        }) {
                                            HStack {
                                                Text(division)
                                                if selectedDivision == division {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedDivision)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .frame(width: 80)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        CustomTextField(
                            placeholder: "Enter your email",
                            text: $email,
                            keyboardType: .emailAddress,
                            autoCapitalization: .never
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        CustomTextField(
                            placeholder: "Minimum 6 characters",
                            text: $password,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        CustomTextField(
                            placeholder: "Re-enter your password",
                            text: $confirmPassword,
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 30)
                    
                    // Register Button
                    Button(action: register) {
                        ZStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.cyan)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    // Back to Login
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Login")
                                .foregroundColor(.cyan)
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 10)
                    
                    Spacer()
                        .frame(height: 30)
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Registration Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func register() {
        // Validation
        guard !summonerName.isEmpty else {
            errorMessage = "Please enter your summoner name"
            showError = true
            return
        }
        
        guard !summonerTag.isEmpty else {
            errorMessage = "Please enter your summoner tag"
            showError = true
            return
        }
        
        // Validate tag format (3-5 alphanumeric characters)
        guard summonerTag.count >= 3 && summonerTag.count <= 5 else {
            errorMessage = "Summoner tag must be 3-5 characters"
            showError = true
            return
        }
        
        // Validate tag is alphanumeric
        let alphanumericSet = CharacterSet.alphanumerics
        guard summonerTag.unicodeScalars.allSatisfy({ alphanumericSet.contains($0) }) else {
            errorMessage = "Summoner tag can only contain letters and numbers"
            showError = true
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            showError = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        isLoading = true
        
        // Create user with Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            guard let userId = result?.user.uid else {
                isLoading = false
                errorMessage = "Failed to get user ID"
                showError = true
                return
            }
            
            // Create user profile in Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "summonerName": summonerName,
                "summonerTag": summonerTag,
                "region": selectedRegion,
                "rank": fullRank,
                "email": email,
                "createdAt": Timestamp(date: Date()),
                "role": "Fill",
                "lookingForDuo": false,
                "lookingForClash": false
            ]
            
            db.collection("users").document(userId).setData(userData) { error in
                isLoading = false
                
                if let error = error {
                    errorMessage = "Account created but profile setup failed: \(error.localizedDescription)"
                    showError = true
                    return
                }
                
                // Success - navigate to home
                navigateToHome = true
            }
        }
    }
}

#Preview {
    RegisterView()
}
