//
//  SignInViewModel.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 11/08/2022.
//

import Foundation
import Alamofire

class SignInViewModel: ObservableObject {
    
    @Published var credentials = Credentials()
    @Published var showProgressView = false
        
    func login(completion: @escaping (Bool) -> Void) {
        showProgressView = true
        
        completion(true)
    }
    
    func requestOTP(completion: @escaping (Bool) -> Void) {
        
        showProgressView = true
        defer { showProgressView = false }
        
        let url = URL(string:"https://tlvsso.azurewebsites.net/api/request_otp")!
        
        let parameters: [String: String] = [
            "userId": credentials.userId,
            "phoneNumber": credentials.phoneNumber,
            "clientId": credentials.clientId
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
        .responseDecodable(of: SendOTPResponse.self) { response in
            
            switch (response.result ) {
                case .success:
                
                    let _res = response.value!.isError
                    completion(!_res)

                case .failure(let error):
                    print("\(error)")
                    completion(false)
            }
        }

    }
}
