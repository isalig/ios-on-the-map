//
//  AuthResponse.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

struct AuthResponse : Codable {
    let account: Account?
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct ErrorResponse: Codable {
    let status: Int
    let error: String
}
