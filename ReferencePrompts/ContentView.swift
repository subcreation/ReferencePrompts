//
//  ContentView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ShuffleViewModel = ShuffleViewModel()
    @State var selection:Int? = 1
    
    var body: some View {
        if visualPrompts.lists.count > 0 {
            return AnyView(
                NavigationView {
                    List {
                        NavigationLink(destination: DashboardView(), tag: 1, selection: $selection) {
                            Label("Dashboard", systemImage: "speedometer")
                        }
                        NavigationLink(destination: ImagePromptsView(), tag: 2, selection: $selection) {
                            HStack {
                                Label("Prompts", systemImage: "photo")
                                Spacer()
                                Text("\(visualPrompts.lists.count)")
                                    .foregroundColor(.secondary)
                                    .opacity(0.5)
                            }
                        }
                    }
                }
            )
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                reloadView()
            }
            return AnyView(ProgressView())
        }
    }
    
    func reloadView() {
        self.viewModel.shuffle()
    }
}


