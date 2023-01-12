//
//  ContentView.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import SwiftUI

struct ContentView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ActiveDay.date, ascending: false)],
        animation: .default)
    var usageHistory: FetchedResults<ActiveDay>
    @Environment(\.managedObjectContext) private var viewContext
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
    
    private func getTodaysImagePromptIndex() -> Int {
        return getTotalDaysVerseOpened() % visualPrompts.lists.count
    }
    
    private func getTotalDaysVerseOpened() -> Int {
        let daysRequestedPrompt = usageHistory.filter { $0.requestedPrompt == true }
        return daysRequestedPrompt.count
    }
    
    func reloadView() {
        self.viewModel.shuffle()
    }
    
    func updateActivity() -> Void {
        let today = Date()
        if usageHistory.isEmpty {
            addActiveDay(today)
        } else {
            let todayFound = isTodayAlreadyInHistory(today)
            
            if !todayFound {
                addActiveDay(today)
            } else {
                mergeRaceConditionDuplicates()
            }
        }
    }
    
    private func addActiveDay(_ today: Date) {
        let newActiveDay = ActiveDay(context: viewContext)
        newActiveDay.date = today
        newActiveDay.minutesWriting = 0.0
        newActiveDay.completedPoem = false
        newActiveDay.requestedPrompt = true
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func isTodayAlreadyInHistory(_ today: Date) -> Bool {
        for i in 0..<usageHistory.count {
            let activeDay = usageHistory[i]
            if activeDay.date != nil {
                if Calendar.current.isDate(activeDay.date!, inSameDayAs: today) {
                    return true
                }
            }
        }
        return false
    }
    
    private func mergeRaceConditionDuplicates() {
        var previousActiveDay = usageHistory.first
        if previousActiveDay != nil {
            if previousActiveDay!.date != nil {
                var activeDaysToRemove: [Int] = []
                for i in 1..<usageHistory.count {
                    let lastDay = previousActiveDay!
                    let compareDay = usageHistory[i]
                    if compareDay.date != nil {
                        if Calendar.current.isDate(compareDay.date!, inSameDayAs: lastDay.date!) {
                            if lastDay.completedPoem {
                                compareDay.completedPoem = true
                            }
                            if lastDay.requestedPrompt {
                                compareDay.requestedPrompt = true
                            }
                            if lastDay.minutesWriting > 0.0 {
                                compareDay.minutesWriting += lastDay.minutesWriting
                            }
                            print("~-~ merged")
                            activeDaysToRemove.append(i-1)
                        }
                    }
                    previousActiveDay = compareDay
                }
                let indexSetForDayToRemove = IndexSet(activeDaysToRemove)
                deleteActivity(offsets: indexSetForDayToRemove)
            }
        }
    }
    
    private func deleteActivity(offsets: IndexSet) {
        withAnimation {
            offsets.map { usageHistory[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}


