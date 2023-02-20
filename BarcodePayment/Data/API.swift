//
//  API.swift
//  BarcodePayment
//
//  Created by 樋川裕次郎 on 2023/02/20.
//

import Foundation

struct Balance : Codable {
}

struct RegistrationRequest : Codable {
    var username: String
}

struct User: Codable {
    var id: String
    var username: String
    var walletId: String
    var wallet: Wallet
}

struct LoginRequest: Codable {
   var username: String
}

struct Wallet : Codable {
    var id: String
    var amount: Int
}

struct DepositRequest : Codable {
    var walletId: String
    var amount: Int
}

struct DepositResponse: Codable {
    var isSucceed: Bool
}

struct TransactionRequest: Codable {
    var senderId: String
    var recieverId: String
    var amount: Int
}


final class BarcodeSystemFetcher {
    private let baseURL = "http://hikawayuujirounoMacBook-Pro.local:3000/"
    
    func fetchBalance(id: String) async throws -> Balance? {
        let url = baseURL + "user/wallet?username=\(id)"
        let (data, response) = try await URLSession.shared.data(from: URL(string: url)!)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.response
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                print(String(describing: data))
                let resultData = try JSONDecoder().decode(Balance.self, from: data)
                return resultData
            } catch {
                throw APIError.jsonDecode
            }
            
        default:
            throw APIError.statusCode(statusCode: httpResponse.statusCode.description)
        }
    }
    
    func sendBalance(_ request: TransactionRequest) async throws -> Bool {
        let requestData = [
            "sender": request.senderId,
            "receiver" : request.recieverId,
            "amount" : request.amount
        ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
        let url = baseURL + "transactions"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.response
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resultData = try decoder.decode(DepositResponse.self, from: data)
                print(data)
                return resultData.isSucceed
            } catch {
                throw APIError.jsonDecode
            }
            
        default:
            throw APIError.statusCode(statusCode: httpResponse.statusCode.description)
        }
    }
    
    func login(username: String) async throws -> User? {
        let url = baseURL + "user/\(username)"
        let (data, response) = try await URLSession.shared.data(from: URL(string: url)!)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.response
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let t = try? JSONSerialization.jsonObject(with: data)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resultData = try decoder.decode(User.self, from: data)
                print(resultData.username)
                return resultData
            } catch {
                throw APIError.jsonDecode
            }
            
        default:
            throw APIError.statusCode(statusCode: httpResponse.statusCode.description)
        }
    }
    
    func deposit(_ deposit: DepositRequest) async throws -> Bool {
        let requestData = [
            "wallet_id": deposit.walletId,
            "amount" : deposit.amount
        ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
        let url = baseURL + "user/wallet/deposit"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.response
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resultData = try decoder.decode(DepositResponse.self, from: data)
                print(data)
                return resultData.isSucceed
            } catch {
                throw APIError.jsonDecode
            }
            
        default:
            throw APIError.statusCode(statusCode: httpResponse.statusCode.description)
        }
    }
    
    func getUser(username: String) async throws -> User? {
        let url = baseURL + "user/\(username)"
        let (data, response) = try await URLSession.shared.data(from: URL(string: url)!)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.response
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resultData = try decoder.decode(User.self, from: data)
                print(resultData.username)
                return resultData
            } catch {
                throw APIError.jsonDecode
            }
            
        default:
            throw APIError.statusCode(statusCode: httpResponse.statusCode.description)
        }
    }
    
    func registerUser(username: String) async throws -> User? {
        let requestData = ["username": username]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
        let url = baseURL + "user/registration"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.response
        }
        
        switch httpResponse.statusCode {
        case 200:
            do {
                let t = try? JSONSerialization.jsonObject(with: data)
                print(t)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let resultData = try decoder.decode(User.self, from: data)
                print(resultData)
                return resultData
            } catch {
                throw APIError.jsonDecode
            }
            
        default:
            throw APIError.statusCode(statusCode: httpResponse.statusCode.description)
        }
    }
    
    func getWallet(walletId: String) -> Wallet? {
        return nil
    }
}
