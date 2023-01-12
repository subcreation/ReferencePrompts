//
//  DashboardView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import SwiftUI
import CloudKit

struct DashboardView: View {
    @State var showVisualModal = false
    @State var imageAsset:CKAsset?
    
    var body: some View {
        let imagePrompt = visualPrompts.lists[0]
        
        return VStack {
            HStack {
                Text("Today's Visual Prompt")
                Spacer()
                Button(action:  { showVisualModal = true }) {
                    Image(systemName: "photo")
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if imageAsset != nil {
                AsyncImage(url: imageAsset?.fileURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        ZStack {
                            Color.black
                            Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30.0)
                                .foregroundColor(.red)
                        }
                    } else {
                        ZStack {
                            Color.black
                            ProgressView()
                        }
                    }
                }
#if os(macOS)
            .frame(minWidth: 160.0, maxWidth: 250.0, minHeight: 120.0, idealHeight: 180.0, maxHeight: 180.0, alignment: .center)
#else
            .frame(minWidth: 160.0, idealWidth: 250.0, maxWidth: .infinity, minHeight: 120.0, idealHeight: 180.0, maxHeight: .infinity, alignment: .center)
#endif
            .cornerRadius(10.0)
            }
        }
        .onAppear {
            if let thumbnailReference = imagePrompt.thumbnailImage {
                CKPrompt.fetchImageAsset(for: thumbnailReference) { (result) in
                    switch result {
                    case .success(let asset):
                        self.imageAsset = asset
                    case .failure(let error):
                        print("Failed to load thumbnail: \(error)")
                    }
                }
            }
        }
#if os(macOS)
        .frame(maxWidth: 250)
#endif
    }
    
}
