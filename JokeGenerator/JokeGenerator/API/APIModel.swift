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
        var urlComponents = URLComponents(string: "\(baseURL)/\(category.rawValue)")!
        urlComponents.queryItems = [URLQueryItem(name: "amount", value: "\(amount)")]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }

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
                // Try decoding the response
                let apiResponse = try JSONDecoder().decode(JokeAPIResponse.self, from: data)
                
                // Handle jokes array or single joke
                if let jokes = apiResponse.jokes {
                    completion(.success(jokes))
                } else if let type = apiResponse.type {
                    // Construct single joke manually
                    let joke = Joke(type: type, joke: apiResponse.joke, setup: apiResponse.setup, delivery: apiResponse.delivery)
                    completion(.success([joke]))
                } else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: -3, userInfo: nil)))
                }
            } catch {
                // Print raw response for debugging
                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(rawJSON)")
                }
                completion(.failure(error))
            }
        }

        task.resume()
    }
}


