//
//  CustomImage.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 08/01/25.
//

import SwiftUI

struct CustomImage<P: View, I: View>: View {
    let url: URL?
    let imageView: (Image) -> I
    let placeholder: P
    @StateObject private var vm = ImagesViewModel()
    
    public init(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> P,
        @ViewBuilder imageView: @escaping (Image) -> I
    ) {
        self.url = url
        self.imageView = imageView
        self.placeholder = placeholder()
    }
    
    var body: some View {
        VStack {
            if let image = vm.image {
                imageView(Image(uiImage: image))
            } else {
                placeholder
            }
        }
        .task {
            await vm.getImagePath(url: url)
        }
    }
}



final class ImagesViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    
    private let fileManager = LocalFileManager()
    
    func getImagePath(url: URL?) async {
        guard let url else { return }
        do {
            let path = try await fileManager.getOrDownload(url: url, key: url.lastPathComponent, media: .imageJPEG)
            let data = try Data(contentsOf: path)
            await MainActor.run {
                self.image = UIImage(data: data)
            }
        } catch {
            print(error)
        }
    }
}







#Preview {
    CustomImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/mychatappuz.firebasestorage.app/o/users%2F078BAA36-8003-4B1A-82A8-2DD7C127B1D6.jpeg?alt=media&token=335d0a2a-1ed0-454d-8584-44d4b908efa1")) {
        ProgressView()
            .background(Color.red)
    } imageView: {image in
        image
            .resizable()
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
