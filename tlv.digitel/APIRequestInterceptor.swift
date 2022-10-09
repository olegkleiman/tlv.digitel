//
//  NetworkManager.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 08/10/2022.
//

import Foundation
import Alamofire
import KeychainSwift

struct DecodableRefreshTokens: Codable {
    let access_token: String?
    let token_type: String
    let not_before: Int?
    let id_token_expires_in: Int?
    let profile_info: String?
    let scope: String?
    let expires_in: Int // Here Azure B2C returns int in contrast with string within token response
    let expires_on: Int?
    let resource: String?
    let refresh_token: String
    let refresh_token_expires_in: Int?
    let id_token: String
}

class APIRequestInterceptor: RequestInterceptor {
    static let shared: APIRequestInterceptor = {
        return APIRequestInterceptor()
    }()
    
    var request: Alamofire.Request?
    let retryLimit = 3

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        debugPrint(urlRequest)
        
        let keychain = KeychainSwift()
        guard let tokens = keychain.get("tlv_tokens")
        else {
            return
        }
        let _data = tokens.data(using: .utf8)!
        
        do {
            let jsonDecoder = JSONDecoder()
            let oauthTokens = try jsonDecoder.decode(DecodableTokens.self, from: _data)
            let access_token = oauthTokens.access_token
            
            urlRequest.setValue("token \(access_token)", forHTTPHeaderField: "Authorization")
        } catch let error {
            print("Tokens deserialization error: \(error)")
        }

        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let statusCode = request.response?.statusCode
        else {
            completion(.doNotRetry)
            return
        }
        
        guard request.retryCount < retryLimit
        else {
            completion(.doNotRetry)
            return
        }

        switch statusCode {
            case 200...299:
                completion(.doNotRetry)
            case 401:
                refreshToken { isSuccess in isSuccess ? completion(.retry) : completion(.doNotRetry) }
                break;
            default:
                completion(.retry)
        }

    }
    
    func refreshToken(completion: @escaping (_ isSuccess: Bool) -> Void) {
        
        let keychain = KeychainSwift()
        guard let tokens = keychain.get("tlv_tokens")
        else {
            return
        }
       
        let _data = tokens.data(using: .utf8)!
        do {
            let jsonDecoder = JSONDecoder()
            let oauthTokens = try jsonDecoder.decode(DecodableTokens.self, from: _data)
            let refresh_token = oauthTokens.refresh_token
            
            let url = "https://api.tel-aviv.gov.il/sso/refresh_token"
            let parameters: [String: String] = [
                "client_id": CLIENT_ID,
                "scope": "openid offline_access https://tlvfpb2cppr.onmicrosoft.com/\(CLIENT_ID)/TLV.Digitel.All",
                "refresh_token": refresh_token,
                "isAnonyousLogin": "false"
            ]
            let headers: HTTPHeaders = [
                .contentType("application/json")
            ]

            AF.request(url, method: .post,
                       parameters: parameters,
                       encoder: JSONParameterEncoder.default,
                       headers: headers)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: DecodableRefreshTokens.self) { response in

                switch response.result {
                    case .success(let refreshTokens):
                        let jsonTokens = DecodableTokens(copyFrom: refreshTokens)
                        debugPrint(jsonTokens.access_token)
                    
                        saveTokens(jsonTokens) { isSuccess in
                            isSuccess ? completion(true) : completion(false)
                        }

                    
                case .failure(let error):
                        print("🥶 \(error)")
                        completion(false)

                }
            }
            
        } catch let error {
            print("Tokens deserialization error: \(error)")
        }
        
        
    }
    
}


