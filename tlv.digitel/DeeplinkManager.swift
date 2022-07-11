//
//  DeeplinkManager.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import Foundation

class DeeplinkManager {
    
    var accessToken: String?
    
    enum DeeplinkTarget: Equatable {
        case home
        case login
    }
    
    class DeeplinkContansts {
        static let scheme = "tel-aviv"
        static let host = "com.digitel"
        static let path = "/home"
        static let query = "id"
    }
    
    func manage(url: URL) -> DeeplinkTarget {
        guard url.scheme == DeeplinkContansts.scheme,
                url.host == DeeplinkContansts.host,
                url.path == DeeplinkContansts.path,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            return .login
        }
        
        self.accessToken = components.queryItems?.first(where: { $0.name == "access_token" })?.value
        
        return .home
    }
}
