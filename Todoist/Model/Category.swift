//
//  Category.swift
//  Todoist
//
//  Created by Ervin on 12/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name = String()
    let items = List<ToDoItem>()
    
}
