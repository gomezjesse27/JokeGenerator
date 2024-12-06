//
//  ContentView.swift
//  JokeGenerator
//
//  Created by Jaysen Gomez on 12/5/24.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedCategory: JokeCategory = .any
    @State private var jokeText: String = "Select a category and press refresh!"
    @State private var isLoading: Bool = false
    
    @State private var currentJokeCate: String = ""
    @State private var showSetting: Bool = false
    @State private var showAlertDark: Bool = false
    
//MARK: - View
    
    var body: some View {
        VStack {
            HStack {
                Text("Group 4")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(width: 100, height: 50)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.all, 12)
                    .background(.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        showSetting.toggle()
                    }
            }
            .padding(.top, -8)
            
            Spacer()
            
            // simple text to display the joke
            Text(jokeText)
                .font(.system(size: 24))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("- \(currentJokeCate) joke")
                .font(.subheadline)
                .fontWeight(.regular)
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Spacer()
            
            Divider()
                .frame(height: 2)
                .background(.black)
                .clipShape(.capsule)
            
            // For the categories. Simple picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(JokeCategory.allCases, id: \.self) { category in
                    Text(category.rawValue.capitalized).tag(category)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 160)

            // simple button for refresh
            Button(action: fetchJoke) {
                HStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Next \"\(selectedCategory.rawValue.capitalized)\" Joke")
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, maxHeight: 56, alignment: .center)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                            .padding(.bottom)
                    }
                }
            }
            .disabled(isLoading)
            
        }
        .padding()
        .onAppear(perform: fetchJoke)
        .alert("Warning!", isPresented: $showAlertDark) {
            Button("No, take me back", role: .destructive, action: {
                selectedCategory = .any
            })
            Button("OK, let's go", role: .cancel, action: {})
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
            SettingView(showSetting: $showSetting)
        }
    }
    
//MARK: - Functions

    private func fetchJoke() {
        isLoading = true
        jokeText = "Loading..."
        // Load text, maybe replace with an icon or something...?
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

// jokecategory to work with swiftui...
extension JokeCategory: CaseIterable, Identifiable {
    public var id: String { rawValue }
    public static var allCases: [JokeCategory] {
        return [.any, .programming, .misc, .dark, .pun, .spooky, .christmas]
    }
}

//MARK: - Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
