//
//  APIModel.swift
//  JokeGenerator
//
//  Created by Jaysen Gomez on 12/5/24.
//

import Foundation

struct Joke: Codable {
    let type: String
    let joke: String?
    let setup: String?
    let delivery: String?
}

struct JokeAPIResponse: Codable {
    let error: Bool
    let jokes: [Joke]?
    let type: String?
    let joke: String?
    let setup: String?
    let delivery: String?
}

class JokeAPIClient {
    static let baseURL = "https://v2.jokeapi.dev/joke"

    static func fetchJokes(
        category: JokeCategory,
        amount: Int = 1,
        completion: @escaping (Result<[Joke], Error>) -> Void
    ) {
        // Define blacklist flags
        let blacklistFlags = ["nsfw", "religious", "political", "racist", "sexist", "explicit"]
        let blacklistParam = blacklistFlags.joined(separator: ",")
        
        // Determine categories
        let categories: [String]
        if category == .any {
            categories = JokeCategory.allCases
                .filter { $0 != .dark && $0 != .any } // Exclude "dark" and "any" from the list
                .map { $0.rawValue }
        } else {
            categories = [category.rawValue]
        }
        
        let categoryParam = categories.joined(separator: ",")

        // Build URL components
        var urlComponents = URLComponents(string: "\(baseURL)/\(categoryParam)")!
        urlComponents.queryItems = [
            URLQueryItem(name: "amount", value: "\(amount)"),
            URLQueryItem(name: "blacklistFlags", value: blacklistParam) // Add blacklist flags
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

        // Perform the network request
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo: nil)))
                return
            }

            do {
                // Decode the response
                let apiResponse = try JSONDecoder().decode(JokeAPIResponse.self, from: data)
                
                if let jokes = apiResponse.jokes {
                    completion(.success(jokes))
                } else if let type = apiResponse.type {
                    let joke = Joke(type: type, joke: apiResponse.joke, setup: apiResponse.setup, delivery: apiResponse.delivery)
                    completion(.success([joke]))
                } else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: -3, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
