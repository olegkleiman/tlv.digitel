//
//  TokensUtils.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 09/10/2022.
//

import Foundation
import KeychainSwift

func saveTokens(_ tokens: DecodableTokens,
                completion: @escaping (_ isSuccess: Bool) -> Void) {
    do {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(tokens)
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        
        let keychain = KeychainSwift()
        let appID = "GX7N6F8DFJ.gov.tel-aviv.digitel"
        keychain.accessGroup = appID
        let _ = keychain.set(jsonString!, forKey: "tlv_tokens")
        
        let keychainAccessGroupName = "GX7N6F8DFJ.gov.tlv.ssoKeychainGroup"
        keychain.accessGroup = keychainAccessGroupName
        let _ = keychain.set(tokens.sso_token!, forKey: "sso_token")
        
        completion(true)
    } catch let err {
        debugPrint(err)
        completion(false)
    }
}
