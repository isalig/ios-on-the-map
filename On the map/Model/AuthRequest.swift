//
//  AuthRequest.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

struct AuthRequest: Encodable {
    let udacity: Credentials
}

struct Credentials: Encodable {
    let username: String
    let password: String
}
