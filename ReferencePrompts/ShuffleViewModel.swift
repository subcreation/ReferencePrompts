//
//  ShuffleViewModel.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import Foundation

class ShuffleViewModel : ObservableObject {
    @Published var listData = ["one", "two", "three", "four"]

    func shuffle() {
        listData.shuffle()
        //or listData = dictionary.shuffled().prefix(upTo: 10)
    }
}
