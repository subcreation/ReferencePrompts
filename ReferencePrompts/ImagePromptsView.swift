//
//  ImagePromptsView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import SwiftUI

struct ImagePromptsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var selectedItem: VisualPrompt? = nil
    private let columnWidth: CGFloat = 150.0
    private let cornerRadius: CGFloat = 10.0
    private let mosaicSpacing: CGFloat = 10.0
    
    var body: some View {
        ZStack {
            ProgressView()
                .opacity(visualPrompts.lists.count > 0 ? 0 : 1)
            
            GeometryReader { geo in
                ScrollView {
                    HStack(alignment: .top, spacing: mosaicSpacing) {
                        ForEach((0..<Int(floor(geo.size.width / columnWidth))).reversed(), id: \.self) { c in
                            VStack(spacing: mosaicSpacing) {
                                ForEach(getPromptsInColumns(by: Int(floor(geo.size.width / columnWidth)))[c]) { prompt in
                                    ImageThumbnailView(prompt: prompt)
                                        .onTapGesture {
                                            selectedItem = prompt
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    .sheet(item: $selectedItem) { item in
                        VStack {
                            HStack {
                                CloseButton()
                                    .padding(16.0)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            selectedItem = nil
                                        }
                                    }
                                Spacer()
                            }
                            ImagePromptDetailView(action: { print("Placeholder action: navigate to new poem") }, visualPrompt: item)
                            #if os(macOS)
                                .frame(width: (NSScreen.main?.visibleFrame.width ?? 1024.0) - 100.0, height: (NSScreen.main?.visibleFrame.height ?? 1024.0) - 100.0)
                            #endif
                            .background(colorScheme == .dark ? Color(hex: 0x000000, opacity: 0.3) : Color(hex: 0xFFFFFF, opacity: 0.3))
                        }
                    }
                    .navigationTitle("Visual Prompts")
                }
            }
        }
    }
    
    func getPromptsInColumns(by column: Int) -> [[VisualPrompt]] {
        var result: [[VisualPrompt]] = []
        
        for i in 0..<column {
            var list: [VisualPrompt] = []
            visualPrompts.lists.forEach { prompt in
                let index = visualPrompts.lists.firstIndex { $0.id == prompt.id }
                
                if let index = index {
                    if (index+1) % column == i {
                        list.insert(prompt, at: 0)
                    }
                }
            }
            result.append(list)
        }
        return result
    }
}
