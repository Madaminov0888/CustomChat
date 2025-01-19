//
//  AudioPlayer.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 15/01/25.
//


import SwiftUI
import AVKit

struct AudioPlayerView: View {
    let audioURL: URL
    @State private var isPlaying = false
    @State private var progress: Double = 0.0
    @State private var duration: Double = 0.0
    private let player: AVPlayer
    private var timer: Timer?
    private let color: Color
    
    init(audioURL: URL, tintColor: Color = .white) {
        self.audioURL = audioURL
        self.player = AVPlayer(url: audioURL)
        self.color = tintColor
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(color)
                }
                .padding()
                
                Slider(value: $progress, in: 0...1, onEditingChanged: { editing in
                    if !editing {
                        seekToProgress()
                    }
                })
                .accentColor(color)
                .padding(.trailing, 16)
                
                Text(formatTime(currentTime: progress * duration, totalTime: duration))
                    .foregroundColor(color)
                    .font(.caption)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanupPlayer()
        }
    }
    
    private func togglePlayback() {
        withAnimation(.bouncy(duration: 0.4)) {
            isPlaying.toggle()
            if isPlaying {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    
    private func setupPlayer() {
        if let duration = player.currentItem?.asset.duration {
            self.duration = CMTimeGetSeconds(duration)
        }
        
        // Update progress periodically
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let currentTime = player.currentItem?.currentTime() {
                let seconds = CMTimeGetSeconds(currentTime)
                self.progress = seconds / self.duration
            }
        }
        
        // Observe when audio finishes playing
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            audioDidFinishPlaying()
        }
    }
    
    private func cleanupPlayer() {
        player.pause()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    private func seekToProgress() {
        let newTime = CMTime(seconds: progress * duration, preferredTimescale: 600)
        player.seek(to: newTime)
    }
    
    private func formatTime(currentTime: Double, totalTime: Double) -> String {
        let currentMinutes = Int(currentTime) / 60
        let currentSeconds = Int(currentTime) % 60
        return String(format: "%02d:%02d", currentMinutes, currentSeconds)
    }
    
    private func audioDidFinishPlaying() {
        // Reset playback states
        isPlaying = false
        progress = 0.0
        player.seek(to: .zero)
    }
}

#Preview {
    AudioPlayerView(audioURL: URL(string: "http://codeskulptor-demos.commondatastorage.googleapis.com/GalaxyInvaders/theme_01.mp3")!)
        .glassBlurView(Color.gray)
        .frame(maxWidth: 300, maxHeight: 10)
}
