//
//  ContentView.swift
//  JokeGenerator
//
//  Created by Jaysen Gomez on 12/5/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory: JokeCategory = .any
    @State private var jokeText: String = "Select a category and press refresh!"
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // simple text to display the joke
            Text(jokeText)
                .multilineTextAlignment(.center)
                .padding()
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // For the categories. Simple picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(JokeCategory.allCases, id: \.self) { category in
                    Text(category.rawValue.capitalized).tag(category)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()

            // simple button for refresh
            Button(action: fetchJoke) {
                HStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Refresh Joke")
                            .fontWeight(.bold)
                    }
                }
            }
            .disabled(isLoading)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear(perform: fetchJoke) // joke being fetched when app is loaded
    }

    private func fetchJoke() {
        isLoading = true
        jokeText = "Fetching joke..."
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
