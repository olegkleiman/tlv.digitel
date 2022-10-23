//
//  SignInViewModel.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 11/08/2022.
//

import SwiftUI
import Alamofire

class SignInViewModel: ObservableObject {
    
    @Published var credentials = Credentials()
    @Published var showProgressView = false
    
    func login(clientId: String,
               otp: String,
               completion: @escaping (DecodableTokens?, Error?) throws -> Void) {
     
        let url = URL(string: "https://api.tel-aviv.gov.il/sso/login")!
        
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        struct LoginParameters : Encodable {
                let phoneNumber: String
                let otp: String
                let clientId: String
                let scope: String
                let deviceId: String
                let withUpgrade: Bool
        }
        let parameters = LoginParameters(
            phoneNumber: credentials.phoneNumber,
            otp: otp,
            clientId: clientId,
            scope: "openid offline_access https://\(TENANT_NAME).onmicrosoft.com/\(clientId)/TLV.Digitel.All",
            deviceId: deviceId,
            withUpgrade: false
        )

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: DecodableTokens.self) { response in
            
            switch response.result {
                
                case .success(let tokens):
                    try! completion(tokens, nil)
                
                case .failure(let error):
                    if let data = response.data {
                        let json = String(data: data, encoding: String.Encoding.utf8)
                        print("Failure Response: \(String(describing: json))")
                    }
                    try! completion(nil, error)
                
            }
            
        }
        
    }
    
    func requestOTP(completion: @escaping (Bool) -> Void) {
        
        showProgressView = true
        defer { showProgressView = false }
        
        let url = URL(string:"https://api.tel-aviv.gov.il/sso/request_otp")!
        
        let parameters: [String: String] = [
            "userId": credentials.userId,
            "phoneNumber": credentials.phoneNumber,
            "clientId": credentials.clientId
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
        .responseDecodable(of: SendOTPResponse.self) { response in
            
            switch (response.result ) {
                case .success:
                
                    let _res = response.value!.IsError
                    completion(!_res)

                case .failure(let error):
                    print("\(error)")
                    completion(false)
            }
        }

    }
}
