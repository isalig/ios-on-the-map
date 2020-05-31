//
//  ApiClient.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation

class ApiClient {
    
    enum ApiEndpoint {
        static let baseUrl = "https://onthemap-api.udacity.com/v1"
        case login
        case studentDetail(userId: String)
        case studentLocations
        case addLocation
    }
    
    enum ApiError: Error {
        case networkError
        case credentialsError(message: String)
        case decodingError
    }
    
    struct AlertMessage {
        var title: String
        var message: String
    }
    
    func getUrl(for endpoint: ApiEndpoint) -> String {
        switch endpoint {
            case .login:
                return "\(ApiEndpoint.baseUrl)/session"
            case .studentDetail (let userId):
                return "\(ApiEndpoint.baseUrl)/users/\(userId)"
            case .studentLocations:
                return "\(ApiEndpoint.baseUrl)/StudentLocation?order=-updatedAt&limit=100"
            case .addLocation:
                return "\(ApiEndpoint.baseUrl)/StudentLocation"
        }
    }
    
    func login(username: String, password: String, result: @escaping (Student?, ApiError?) -> Void) {
        makePOSTRequest(endpoint: .login, data: AuthRequest(udacity: Credentials(username: username, password: password)), stripSymbols: true, result: {(response: AuthResponse?, error) in
            if (error != nil) {
                result(nil, error)
            } else {
                self.loadUserData(userId: response!.account!.key, result: result)
            }
        }
        )
    }
    
    func logout(result: @escaping (AuthResponse?, ApiError?)->Void) {
            var request = URLRequest(url: URL(string: getUrl(for: .login))!)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
              if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
              request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    result(nil, .networkError)
                    return
                }
                let range = 5..<data!.count
                let newData = data?.subdata(in: range)
              
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let decoded = try? decoder.decode(AuthResponse.self, from: newData!) else {
                    result(nil, .decodingError)
                    return
                }
                result(decoded, nil)
            }
            task.resume()
        }
        
        private func loadUserData(userId: String, result: @escaping (Student?, ApiError?) -> Void) {
            makeGETRequest(endpoint: .studentDetail(userId: userId), stripSymbols: true, result: result)
        }
        
        
        func loadLocations(result: @escaping (LocationsResult?, ApiError?)->Void) {
            makeGETRequest(endpoint: .studentLocations, stripSymbols: false, result: result)
        }
        

        func postLocation(location: StudentLocation, result: @escaping (StudentLocationResponse?, ApiError?) -> Void) {
            makePOSTRequest(endpoint: .addLocation, data: location, stripSymbols: false, result: result)
        }
        
        func makeGETRequest<ResponseType: Decodable>(endpoint: ApiEndpoint, stripSymbols: Bool, result: @escaping (ResponseType?, ApiError?) -> Void) {
            let request = URLRequest(url: URL(string: getUrl(for: endpoint))!)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    result(nil, .networkError)
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                var newData = data
                
                if (stripSymbols) {
                    let range = 5..<data!.count
                    newData = data?.subdata(in: range)
                }
                
    //            print(String(data: newData!, encoding: .utf8)!)
                
                guard let decoded = try? decoder.decode(ResponseType.self, from: newData!) else {
                    result(nil, .decodingError)
                    return
                }
                
                result(decoded, nil)
            }
            task.resume()
        }
        
        func makePOSTRequest<RequestType: Encodable, ResponseType: Decodable>(endpoint: ApiEndpoint, data: RequestType, stripSymbols: Bool, result: @escaping (ResponseType?, ApiError?) -> Void) {
            var request = URLRequest(url: URL(string: getUrl(for: endpoint))!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            
            request.httpBody = try! encoder.encode(data)
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    result(nil, .networkError)
                  return
                }
                
                var newData = data
                
                if (stripSymbols) {
                    let range = 5..<data!.count
                    newData = data?.subdata(in: range)
                }
               
                let r = response as! HTTPURLResponse
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if (r.statusCode != 200) {
                    let responseError = try? decoder.decode(ErrorResponse.self, from: newData!)
                    result(nil, .credentialsError(message: responseError!.error))
                } else {
                    guard let decoded = try? decoder.decode(ResponseType.self, from: newData!) else {
                        result(nil, .decodingError)
                        return
                    }
                    result(decoded, nil)
                }
            }
            task.resume()
        }
        
        func getAlertDataFromError(error: ApiError) -> AlertMessage {
            switch error {
            case .networkError:
                return AlertMessage(title: "Network error", message: "Please, try again later")
            case .credentialsError(let message):
                return AlertMessage(title: "Credentials error", message: message)
            case .decodingError:
                return AlertMessage(title: "Decoding error", message: "Please, contact developer or try again later")

            }
        }
}
