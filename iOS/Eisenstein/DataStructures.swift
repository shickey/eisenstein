//
//  DataStructures.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/27/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation
import CoreData

//struct Project {
//    let id : UUID
//    let mediaDirectory : URL
//    
//    init() {
//        let newId = UUID()
//        id = newId
//        mediaDirectory = {
//            let docsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
//            let mediaUrl = docsDirectoryUrl.appendingPathComponent(newId.uuidString, isDirectory: true)
//            try! FileManager.default.createDirectory(at: mediaUrl, withIntermediateDirectories: true, attributes: nil)
//            return mediaUrl
//        }()
//    }
//    
//}

extension Project {
    
    static func create(context moc: NSManagedObjectContext) -> Project {
        var project = self.init(context: moc)
        project.id = UUID()
        return project
    }
    
    var mediaDirectory : URL {
        get {
            let docsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            let mediaUrl = docsDirectoryUrl.appendingPathComponent(self.id!.uuidString, isDirectory: true)
            try! FileManager.default.createDirectory(at: mediaUrl, withIntermediateDirectories: true, attributes: nil)
            return mediaUrl
        }
    }
    
}
