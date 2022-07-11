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
                
                //  logo
                Image("logo-6")
                    .resizable()
                    .frame(width: 166.14, height: 26)
                    .padding(.top, 50)
                
//                Text("Welcome to TLV Digitel")
//                    .padding(.top, 40)
//                    .font(.title)
//                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(spacing:0) {
                    Label {
                        ZStack(alignment: .leading) {
                            if userId.isEmpty {
                                Text("Citizen ID")
                                    .foregroundColor(.white)
                            }
                            TextField("", text: $userId)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .padding(.leading)
                                .padding(.trailing)
                                .font(.system(size: 16))
                        }
                    } icon: {
                        Image(systemName: "person")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 45)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 0.5).frame(height: 45))
                
                    Label {
                        ZStack(alignment: .leading) {
                            if phoneNumber.isEmpty {
                                Text("Phone Number")
                                    .foregroundColor(.white)
                            }
                            TextField("", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .padding(.leading)
                                .padding(.trailing)
                                .font(.system(size: 16))
                        }
                    } icon: {
                        Image(systemName: "phone")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(.leading)
                    }
                    .frame(height: 45)
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 0.5).frame(height: 45))
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
        Group {
            LoginView()
            LoginView()
            LoginView()
        }
    }
}
