//
//  CallView.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/01/25.
//

import SwiftUI

struct CallView: View {
    @StateObject private var webRTCManager = WebRTCManager()
    @StateObject private var webSocketManager = WebSocketManager(userID: "12345") // Replace with actual user ID

    var body: some View {
        VStack {
            Button("Start Call") {
//                webSocketManager.connect()
                webRTCManager.createPeerConnection()
                webRTCManager.addAudioTrack()
                webRTCManager.createOffer { offer in
                    let offerDict: [String: Any] = [
                        "action": "send_offer",
                        "sdp": offer.sdp,
                        "type": offer.type.rawValue,
                        "target_user_id": "67890"  // Replace with actual target user ID
                    ]
                    webSocketManager.send(offerDict)
                }
            }
            Button("Answer Call") {
//                webSocketManager.connect()
                webRTCManager.createPeerConnection()
                webRTCManager.addAudioTrack()
                webRTCManager.createAnswer { answer in
                    let answerDict: [String: Any] = [
                        "action": "send_answer",
                        "sdp": answer.sdp,
                        "type": answer.type.rawValue,
                        "target_user_id": "67890"  // Replace with actual target user ID
                    ]
                    webSocketManager.send(answerDict)
                }
            }
        }
        .onAppear {
            webSocketManager.connect()
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
        .padding()
    }
}



#Preview {
    CallView()
}
