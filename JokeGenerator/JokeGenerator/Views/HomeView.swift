//
//HomeView.swift
//JokeGenerator
//
//Created by Jaysen Gomez, Mariah salgado
//

import SwiftUI

struct HomeView: View {
    
    @Binding var emailLoggedIn: String
    @State var user: User = User(username: "", email: "")
    @AppStorage(USER_EMAIL) var userEmail: String?

    @State private var selectedCategory: JokeCategory = .any
    @State private var jokeText: String = "Select a category and press refresh!"
    @State private var isLoading: Bool = false
    
    @State private var currentJokeCate: String = ""
    @State private var showSetting: Bool = false
    @State private var showAlertDark: Bool = false

//MARK: - View
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height// Check for landscape mode
            
            VStack(spacing: isLandscape ? 10 : 20) {
                
                // Header section (title + settings button)
                headerView
                
                if isLandscape {
                    // Layout for landscape mode
                    HStack(spacing: 20) {
                        // Joke Display in landscape mode
                        jokeCardView
                            .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.7)
                        
                        VStack(spacing: 20) {
                            // Picker and Button stacked vertically
                            categoryPickerView
                                .frame(width: geometry.size.width * 0.35)
                            
                            refreshButtonView
                                .frame(width: geometry.size.width * 0.35)
                        }
                    }
                } else {
                    // Portrait layout
                    Spacer()
                    
                    // Joke Display
                    jokeCardView
                        .frame(height: geometry.size.height * 0.4)
                    
                    Spacer()
                    
                    // Picker and Button stacked vertically
                    categoryPickerView
                    refreshButtonView
                }
            }
            .padding()
            .background(backgroundColor(for: selectedCategory))
            .animation(.easeInOut, value: selectedCategory)
            .onAppear {
                fetchJoke()
                Task {
                    try await fetchUserData()
                }
            }
            .alert("Warning!", isPresented: $showAlertDark) {
                Button("No, take me back", role: .destructive) {
                    selectedCategory = .any
                }
                Button("OK, let's go", role: .cancel) {}
            } message: {
                Text("The dark jokes can be offensive to some people. Please proceed with caution.")
            }
            .onChange(of: jokeText) { _ in
                currentJokeCate = selectedCategory.rawValue.capitalized
            }
            .onChange(of: selectedCategory) { _ in
                if selectedCategory == .dark {
                    showAlertDark.toggle()
                }
            }
            .fullScreenCover(isPresented: $showSetting) {
                SettingView(showSetting: $showSetting, emailLoggedIn: $emailLoggedIn, user: $user)
            }
        }
    }
}

//MARK: - Subviews

extension HomeView {

    var headerView: some View {
        HStack {
            // Title
            Text(user.username.isEmpty ? "Welcome!" : "Hi, \(user.username)!")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
            // Settings button
            Image(systemName: "gear")
                .resizable()
                .frame(width: 24, height: 24)
                .padding()
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
                .onTapGesture {
                    showSetting.toggle()
                }
        }
        .padding(.horizontal)
    }
    
    var jokeCardView: some View {
        // Card to display the joke
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 5)
            
            VStack(spacing: 10) {
                Text(jokeText)// Joke content
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(.black)
                
                Text("- \(currentJokeCate) joke")// Joke category
                    .font(.footnote.italic())
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .padding(.horizontal)
    }
    
    var categoryPickerView: some View {
        // Picker to choose joke categories
        Picker("Category", selection: $selectedCategory) {
            ForEach(JokeCategory.allCases, id: \.self) { category in
                Text(category.rawValue.capitalized)
                    .tag(category)
                    .foregroundColor(.white)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .background(Color.gray.opacity(0.4))
        .cornerRadius(8)
    }
    
    var refreshButtonView: some View {
        // Button to fetch a new joke
        Button(action: fetchJoke) {
            HStack {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Next \"\(selectedCategory.rawValue.capitalized)\" Joke")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7)) // Lighter blue color
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .gray, radius: 5, x: 0, y: 3)
                }
            }
        }
        .disabled(isLoading)// Disable while loading
        .padding(.horizontal)
    }
}

//MARK: - Functions

extension HomeView {
    
    private func backgroundColor(for category: JokeCategory) -> Color {// Change background color based on category
        switch category {
        case .any: return Color.blue.opacity(0.7)
        case .programming: return Color.green
        case .misc: return Color.orange
        case .dark: return Color.black
        case .pun: return Color.yellow
        case .spooky: return Color.purple
        case .christmas: return Color.red
        }
    }
    
    private func fetchUserData() async throws {
        // Fetch user data from backend
        do {
            let email = userEmail ?? ""
            user = try await AuthService.shared.loadUserData(email: email)
        } catch {
            print("DEBUG: Error loading user data")
        }
    }

    private func fetchJoke() {
        isLoading = true
        jokeText = "Loading..."
        
        JokeAPIClient.fetchJokes(category: selectedCategory, amount: 1) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let jokes):
                    if let joke = jokes.first {
                        if joke.type == "single" {
                            jokeText = joke.joke ?? "No joke available."
                        } else {
                            jokeText = "\(joke.setup ?? "")\n\n\(joke.delivery ?? "")"
                        }
                    } else {
                        jokeText = "No jokes found."
                    }
                case .failure(let error):
                    jokeText = "Failed to fetch joke: \(error.localizedDescription)"
                }
            }
        }
    }
}

// JokeCategory Support for SwiftUI

extension JokeCategory: CaseIterable, Identifiable {
    public var id: String { rawValue }
    public static var allCases: [JokeCategory] {
        [.any, .programming, .misc, .dark, .pun, .spooky, .christmas]
    }
}

//MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(emailLoggedIn: .constant(""))
    }
}
