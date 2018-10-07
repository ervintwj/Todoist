//
//  ToDoItem.swift
//  Todoist
//
//  Created by Ervin on 6/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import Foundation

struct ToDoItem: Codable {
    var title: String
    var isChecked: Bool
    
    init(title: String, isChecked: Bool) {
        self.title = title
        self.isChecked = isChecked
    }
}
