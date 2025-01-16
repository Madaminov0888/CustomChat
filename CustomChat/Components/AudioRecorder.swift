//
//  AudioRecorder.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 15/01/25.
//

import SwiftUI
import AVFoundation

struct AudioRecorderView: View {
    @StateObject private var recorder = AudioRecorder()
    @Binding var isRecording: Bool
    @State private var elapsedTime: TimeInterval = 0
    @State private var recordedAudioURL: URL? = nil
    let onFinish: (_ url: URL) -> ()
    
    init(isRecording: Binding<Bool>,onFinish: @escaping (_ url: URL) -> ()) {
        self.onFinish = onFinish
        self._isRecording = isRecording
    }
    
    var body: some View {
        ZStack {
            if isRecording {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(1 + CGFloat(recorder.volume * 0.5))
                    .animation(.easeInOut(duration: 0.2), value: recorder.volume)
                
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 110, height: 110)
                
                VStack {
                    Image(systemName: "microphone.badge.xmark.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.leading, 15)
                        .foregroundColor(.red)
                    
                    Text(formatElapsedTime(elapsedTime))
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            recorder.checkPermissions()
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                recorder.startRecording()
                startTimer()
            } else {
                recorder.stopRecording()
                stopTimer()
                recordedAudioURL = recorder.audioURL
                if let audioURL = recordedAudioURL {
                    onFinish(audioURL)
                }
            }
        }
    }
    
    private func toggleRecording() {
        isRecording.toggle()
    }
    
    private func startTimer() {
        elapsedTime = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if isRecording {
                elapsedTime += 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func stopTimer() {
        elapsedTime = 0
    }
    
    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}



class AudioRecorder: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    @Published var volume: Float = 0.0
    var audioURL: URL?
    
    func checkPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if !granted {
                print("Microphone permission denied.")
            }
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let tempDir = FileManager.default.temporaryDirectory
            audioURL = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            
            startMonitoringVolume()
            print("Recording started at: \(audioURL!)")
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopMonitoringVolume()
    }
    
    private func startMonitoringVolume() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.audioRecorder?.updateMeters()
            self.volume = self.audioRecorder?.averagePower(forChannel: 0) ?? 0
            self.volume = max(0.0, min(1.0, (self.volume + 50) / 50)) // Normalize to 0...1
        }
    }
    
    private func stopMonitoringVolume() {
        timer?.invalidate()
        timer = nil
    }
}


#Preview {
    @Previewable @State var isRecording: Bool = false
    
    AudioRecorderView(isRecording: $isRecording, onFinish: { url in
        print("something", url.absoluteString)
    })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.csBackground)
}
