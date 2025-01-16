//
//  WebRTCManager.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/01/25.
//

import Foundation
import SwiftUI
import WebRTC


class WebRTCManager: NSObject, ObservableObject {
    private var peerConnectionFactory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?

    override init() {
        self.peerConnectionFactory = RTCPeerConnectionFactory()
        super.init()
    }

    func createPeerConnection() {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": "true"]
        )
        
        self.peerConnection = peerConnectionFactory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
    }
    
    func addAudioTrack() {
        let audioConstraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = peerConnectionFactory.audioSource(with: audioConstraints)
        let audioTrack = peerConnectionFactory.audioTrack(with: audioSource, trackId: "audio0")
        peerConnection?.add(audioTrack, streamIds: ["stream0"])
    }

    func createOffer(completion: @escaping (RTCSessionDescription) -> Void) {
        peerConnection?.offer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)) { sdp, error in
            guard let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { _ in })
            completion(sdp)
        }
    }

    func createAnswer(completion: @escaping (RTCSessionDescription) -> Void) {
        peerConnection?.answer(for: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)) { sdp, error in
            guard let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { _ in })
            completion(sdp)
        }
    }

    func setRemoteDescription(_ sdp: RTCSessionDescription) {
        peerConnection?.setRemoteDescription(sdp, completionHandler: { _ in })
    }

    func addCandidate(_ candidate: RTCIceCandidate) {
        peerConnection?.add(candidate)
    }
}

extension WebRTCManager: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        // Send candidate to the server
    }
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}
