//
//  ImagePromptDetailView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/12/23.
//

import SwiftUI
import CloudKit

struct ImagePromptDetailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) var colorScheme
    #if os(iOS)
    private let isIOS = true
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    #else
    private let isIOS = false
    #endif
    @State private var imageAsset:CKAsset?
    @State private var mouseOver = false
    @State private var tapped = false
    @State var imageSize: CGSize = .zero
    
    var action: () -> Void
    var visualPrompt: VisualPrompt? = nil
    
    @ViewBuilder
    var body: some View {
#if os(iOS)
        ZStack(alignment: .topLeading) {
            GeometryReader { geo in
                HStack {
                    Spacer()
                    VStack {
                        if imageAsset != nil {
                            Spacer()
                            AsyncImage(url: imageAsset?.fileURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    ZStack {
                                        Color.black
                                        ProgressView()
                                    }
                                }
                            }
                            Spacer()
                            VStack {
                                HStack {
                                    Text(.init("\(visualPrompt?.credit ?? "")"))
                                        .accentColor(Color.accentColor)
                                        .padding(.all, 10)
                                    Spacer()
                                    if verticalSizeClass == .compact {
                                        Button(action: {
                                            startWriting()
                                        }) {
                                            Label("Start Writing", systemImage: "square.and.pencil")
                                        }
                                        .tint(Color.accentColor)
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.large)
                                        .padding(.all, 10)
                                    }
                                }
                                if verticalSizeClass == .regular {
                                    Button(action: {
                                        startWriting()
                                    }) {
                                        Label("Start Writing", systemImage: "square.and.pencil")
                                            .frame(maxWidth: geo.size.width)
                                    }
                                    .tint(Color.accentColor)
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.large)
                                    .padding(.all, 10)
                                }
                                let botURL = NSLocalizedString("https://chats.landbot.io/v3/H-1098465-JZSTNU3QPUQNDNVN/index.html", comment: "Url to a localized bot for providing prompt feedback")
                                let fullURL = "\(botURL)?title=\(removeMarkdownURL(from: visualPrompt?.credit ?? ""))"
                                let urlWithTitleEncoded = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                Link("Give Feedback", destination: URL(string: urlWithTitleEncoded ?? "")!)
                                    .accentColor(Color.accentColor)
                                    .padding(.all, 10)
                            }
                            .frame(maxWidth: 400)
                            .cornerRadius(10.0)
                            .padding(16)
                        }
                    }
                    .onAppear {
                        if let detailReference = visualPrompt?.detailImage {
                            CKPrompt.fetchImageAsset(for: detailReference) { (result) in
                                switch result {
                                case .success(let asset):
                                    imageAsset = asset
                                case .failure(let error):
                                    print("Failed to load thumbnail: \(error)")
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
#else
        ZStack(alignment: .topLeading) {
            GeometryReader { geo in
                HStack {
                    Spacer()
                    VStack {
                        if imageAsset != nil {
                            Spacer()
                            AsyncImage(url: imageAsset?.fileURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } else if phase.error != nil {
                                    Color.red
                                } else {
                                    Color.gray
                                }
                            }
                            Spacer()
                            VStack {
                                HStack {
                                    Text(.init("\(visualPrompt?.credit ?? "")"))
                                        .accentColor(Color.accentColor)
                                        .padding(.all, 10)
                                    Spacer()
                                    Button(action: {
                                        startWriting()
                                    }) {
                                        Label("Start Writing", systemImage: "square.and.pencil")
                                    }
                                    .tint(Color.accentColor)
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.large)
                                    .padding(.all, 10)
                                }
                                let botURL = NSLocalizedString("https://chats.landbot.io/v3/H-1098465-JZSTNU3QPUQNDNVN/index.html", comment: "Url to a localized bot for providing prompt feedback")
                                let fullURL = "\(botURL)?title=\(removeMarkdownURL(from: visualPrompt?.credit ?? ""))"
                                let urlWithTitleEncoded = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                Link("Give Feedback", destination: URL(string: urlWithTitleEncoded ?? "")!)
                                    .accentColor(Color.accentColor)
                                    .padding(.all, 10)
                            }
                            .frame(maxWidth: 400)
                            .cornerRadius(10.0)
                            .padding(16)
                        }
                    }
                    .onAppear {
                        if let detailReference = visualPrompt?.detailImage {
                            CKPrompt.fetchImageAsset(for: detailReference) { (result) in
                                switch result {
                                case .success(let asset):
                                    imageAsset = asset
                                case .failure(let error):
                                    print("Failed to load thumbnail: \(error)")
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
#endif
    }
    
    func startWriting() -> Void {
        action()
        presentationMode.wrappedValue.dismiss()
    }
    
    func removeMarkdownURL(from str: String) -> String {
        return str.replacingOccurrences(of: "\\[|\\]", with: "", options: [.regularExpression]).replacingOccurrences(of: "\\([^()]*\\)", with: "", options: [.regularExpression])
    }
}
