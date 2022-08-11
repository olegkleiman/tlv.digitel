//
//  LoginView.swift
//  tlv.digitel
//
//  Created by Oleg Kleiman on 10/07/2022.
//

import Foundation
import SwiftUI
import Alamofire

struct SendOTPResponse: Codable {
    let isError: Bool
    let errorDesc: String
    let errorId: Int
}

struct LoginView: View {
    
    @Binding var authState: AuthState
    
    //MARK: - PROPERTIES
    @State private var userId: String = "313069486"
    @State private var phoneNumber: String = "0543307026"
    @State private var clientId: String = "bc00c1e4-30e4-443c-a559-a5b39ff42586"
    @State var isLoading: Bool = false
    @State var pageNum: Int = 1
    
    @State  var errorMessage: String = ""
    @State  var showError: Bool = false
    
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
                
                ZStack {
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .padding()
                        .opacity(isLoading ? 1 : 0)
                    
                    Button("Continue") {
                        Task {
                            self.isLoading.toggle()
                            
                            let url = URL(string:"https://tlvsso.azurewebsites.net/api/request_otp")!
                            
                            let parameters: [String: String] = [
                                "userId": userId,
                                "phoneNumber": phoneNumber,
                                "clientId": clientId
                            ]
                            
                            AF.request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                                .responseDecodable(of: SendOTPResponse.self) { response in
                                    if response.value!.isError as Bool {
                                        self.errorMessage = (response.value?.errorDesc as? String)!
                                        self.showError.toggle()
                                        return
                                    }
                                    
                                    pageNum = 2
                            }
                        }
                    }
                    .opacity(!isLoading ? 1 : 0)
                }
            }
        }
        
    }
    
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(authState: .constant(.forceLogin))
        }
    }
}
