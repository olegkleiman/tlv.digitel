//
//  Authentication.swift
//  Tlv Digitel
//
//  Created by Oleg Kleiman on 11/08/2022.
//

import SwiftUI

class Authentication: ObservableObject {
    
    @Published var state: State = .initial
    
    enum State {
        case initial, initialized, authenticated, error
    }
    
    func updateValidation(_state: State) {
        withAnimation {
            self.state = _state
        }
    }
}
