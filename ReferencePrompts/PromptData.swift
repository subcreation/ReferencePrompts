//
//  PromptData.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import Foundation
import CloudKit
import SwiftUI

var visualPrompts: CDVisualPrompts = loadVisualPrompts()

func loadVisualPrompts() -> CDVisualPrompts {
    let visualPromptResults = CDVisualPrompts()
    CKPrompt.fetchVisualPrompts { (results) in
        switch results {
        case .success(let newPrompts):
            visualPromptResults.lists = newPrompts
        case .failure(let error):
            print("failed: \(error)")
        }
    }
    return visualPromptResults
}

class CDVisualPrompts: ObservableObject {
    @Published var lists: [VisualPrompt] = []
}

struct VisualPrompt: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var detailImage: CKRecord.Reference?
    var thumbnailImage: CKRecord.Reference?
    var credit: String = ""
}

class CKPrompt {
    static let database = CKContainer.default().publicCloudDatabase
    
    class func fetchVisualPrompts(completion: @escaping(Result<[VisualPrompt], Error>) -> ()) {
        let predicate = NSPredicate(value: true)
        let order = NSSortDescriptor(key: "order", ascending: true)
        let query = CKQuery(recordType: "VisualPrompts", predicate: predicate)
        query.sortDescriptors = [order]
        
        var operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["detailImage", "thumbnailImage", "credit"]
        operation.resultsLimit = 20
        operation.qualityOfService = .userInteractive
        
        var newPrompts = [VisualPrompt]()
        
        operation.recordMatchedBlock = { (recordID, recordResult) in
            switch recordResult {
            case .failure(let error):
                print("failed: \(error)")
            case .success(let record):
                var visualPrompt = VisualPrompt()
                visualPrompt.detailImage = record["detailImage"] as? CKRecord.Reference
                visualPrompt.thumbnailImage = record["thumbnailImage"] as? CKRecord.Reference
                visualPrompt.credit = record["credit"] as! String
                print("loaded image with credit: \(visualPrompt.credit)")
                
                newPrompts.append(visualPrompt)
            }
        }
        
        operation.queryResultBlock = { recordResult in
            switch recordResult {
            case .failure(let error):
                print("failed: \(error)")
                completion(.failure(error))
            case .success(let cursor):
                if cursor != nil {
                    let nextOperation = CKQueryOperation(cursor: cursor!)
                    nextOperation.recordMatchedBlock = { (recordID, recordResult) in
                        switch recordResult {
                        case .failure(let error):
                            print("failed: \(error)")
                        case .success(let record):
                            var visualPrompt = VisualPrompt()
                            visualPrompt.detailImage = record["detailImage"] as? CKRecord.Reference
                            visualPrompt.thumbnailImage = record["thumbnailImage"] as? CKRecord.Reference
                            visualPrompt.credit = record["credit"] as! String
                            
                            newPrompts.append(visualPrompt)
                        }
                    }
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.resultsLimit = operation.resultsLimit
                    
                    operation = nextOperation
                    
                    database.add(operation)
                } else {
                    print("cursor was nil, newPrompts.count: \(newPrompts.count)")
                    completion(.success(newPrompts))
                }
            }
        }
        database.add(operation)
    }
    
    class func fetchImageAsset(for reference: CKRecord.Reference, completion: @escaping(Result<CKAsset, Error>) -> ()) {
        database.fetch(withRecordID: reference.recordID) { returnedRecord, returnedError in
            if let asset = returnedRecord?["image"] as? CKAsset {
                completion(.success(asset))
            } else {
                print("No image found for record: \(String(describing: returnedRecord?.recordID))")
            }
        }
        
    }
}
