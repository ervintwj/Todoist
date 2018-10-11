//
//  ToDoItem.swift
//  Todoist
//
//  Created by Ervin on 12/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    
    @objc dynamic var title = String()
    @objc dynamic var isChecked = Bool()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
    
}
