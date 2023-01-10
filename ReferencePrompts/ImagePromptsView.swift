//
//  ImagePromptsView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import SwiftUI

struct ImagePromptsView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .opacity(visualPrompts.lists.count > 0 ? 0 : 1)
            
            LazyVStack {
                ForEach(visualPrompts.lists) { prompt in
                    Text("prompt: \(prompt.credit)")
                }
            }
        }
    }
}
