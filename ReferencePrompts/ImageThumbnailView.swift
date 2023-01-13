//
//  ImageThumbnailView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/12/23.
//

import SwiftUI
import CloudKit

struct ImageThumbnailView: View {
    @State private var imageAsset:CKAsset?
    
    @State var prompt: VisualPrompt
    @State var isLoaded = false
    
    private let columnWidth: CGFloat = 150.0
    private let cornerRadius: CGFloat = 10.0
    
    @State var imageHeight: CGFloat = 150.0
    
    var body: some View {
        VStack {
            if imageAsset != nil {
                AsyncImage(url: imageAsset?.fileURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(cornerRadius)
                        // This fixes a bug with LazyVStack that causes weird behavior scrolling back
                            .background(GeometryReader { geo in
                                Color.clear
                                    .measureSize  { size in
                                        imageHeight = size.height
                                    }
                            })
                    } else if phase.error != nil {
                        ZStack {
                            Color.black
                                .frame(height: imageHeight)
                                .cornerRadius(cornerRadius)
                            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30.0)
                                .foregroundColor(.red)
                                .onAppear {
                                    loadImage()
                                }
                        }
                    } else {
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .onAppear {
            if !isLoaded {
                loadImage()
            }
        }
    }
    
    func loadImage() {
        if let thumbnailReference = prompt.thumbnailImage {
            CKPrompt.fetchImageAsset(for: thumbnailReference) { (result) in
                switch result {
                case .success(let asset):
                    imageAsset = asset
                    isLoaded = true
                case .failure(let error):
                    print("Failed to load thumbnail: \(error)")
                }
            }
        }
    }
    
    var placeholder: some View {
        ZStack {
            Color.black
                .frame(height: imageHeight)
                .cornerRadius(cornerRadius)
            ProgressView()
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct MeasureSizeModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { geometry in
      Color.clear.preference(key: SizePreferenceKey.self,
                             value: geometry.size)
    })
  }
}

extension View {
  func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
    self.modifier(MeasureSizeModifier())
      .onPreferenceChange(SizePreferenceKey.self, perform: action)
  }
}
