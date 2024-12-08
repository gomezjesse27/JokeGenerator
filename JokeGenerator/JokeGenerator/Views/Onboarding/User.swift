//
//  User.swift
//  JokeGenerator
//
//  Created by Long Nguyen on 12/7/24.
//

import Foundation

struct User: Codable {
    var username: String
    var email: String
    
    static var exampleUser: User {
        User(username: "Long Nguyen", email: "longnguyen@gmail.com")
    }
}
