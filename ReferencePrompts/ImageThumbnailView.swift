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
    
    @State var prompt:VisualPrompt
    
    private let columnWidth: CGFloat = 150.0
    private let cornerRadius: CGFloat = 10.0
    
    var body: some View {
        VStack {
            if imageAsset != nil {
                AsyncImage(url: imageAsset?.fileURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(cornerRadius)
                    } else if phase.error != nil {
                        ZStack {
                            Color.black
                                .frame(height: columnWidth)
                                .cornerRadius(cornerRadius)
                            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30.0)
                                .foregroundColor(.red)
                        }
                    } else {
                        ZStack {
                            Color.black
                                .frame(height: columnWidth)
                                .cornerRadius(cornerRadius)
                            ProgressView()
                        }
                    }
                }
            }
        }
        .onAppear {
            if let thumbnailReference = prompt.thumbnailImage {
                CKPrompt.fetchImageAsset(for: thumbnailReference) { (result) in
                    switch result {
                    case .success(let asset):
                        imageAsset = asset
                    case .failure(let error):
                        print("Failed to load thumbnail: \(error)")
                    }
                }
            }
        }
    }
}
