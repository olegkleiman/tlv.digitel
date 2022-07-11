//
//  LoginView.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    //MARK: - PROPERTIES
    @State var userId: String = ""
    @State var phoneNumber: String = ""
    
    var body: some View {
        
        ZStack {
            
            Image("bg-6")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            Spacer()
            
            VStack() {
                Text("Welcome to TLV Digitel")
                    .padding(.top, 20)
                    .font(.title)
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing:0) {
                    Label {
                        TextField("Citizen Id", text: $userId)
                            .background(.gray)
                            .keyboardType(.numberPad)
                            .padding(.leading)
                            .padding(.trailing)
                            .font(.system(size: 24))
                    } icon: {
                        Image(systemName: "person")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .frame(height: 45)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 0.5).frame(height: 45))
                
                    Label {
                        TextField("Phone Number", text: $phoneNumber)
                            .background(.gray)
//                            .cornerRadius(5.0)
                            .keyboardType(.numberPad)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.top)
                            .font(.system(size: 24))
                    } icon: {
                        Image(systemName: "phone")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)

                    }
                }
                .padding()

                Spacer()
                Button("Continue") {
                    
                }
            }
        }
        
    }
    
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
