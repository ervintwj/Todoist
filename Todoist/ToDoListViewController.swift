//
//  ViewController.swift
//  Todoist
//
//  Created by Ervin on 3/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [ToDoItem]()
    let userDefaults = UserDefaults.standard
    let propertyListDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoList.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadArrayFromPropertyList()
    }
    
    //MARK: - Add Button Tapped
    @IBAction func addButtonTapped(_ sender: Any) {
        print(self.itemArray)
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add To-do", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter your to-do"
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let userInput = textField.text {
                guard userInput != "" else { return }
                let newToDo = ToDoItem(title: userInput, isChecked: false)
                self.itemArray.append(newToDo)
                self.saveArrayToPropertyList()
                
                self.tableView.reloadData()
                print(self.itemArray)
            }
        }

        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func saveArrayToPropertyList() {
        let encoder = PropertyListEncoder()
        do {
            let encodedToDo = try encoder.encode(self.itemArray)
            try encodedToDo.write(to: self.propertyListDirectory!)
        } catch {
            print("Error encoding To-do into Property List, \(error)")
        }
    }
    
    func loadArrayFromPropertyList() {
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: self.propertyListDirectory!) {
            do {
                let decodedToDo = try decoder.decode([ToDoItem].self, from: data)
                self.itemArray = decodedToDo
            } catch {
                print("Error decoding To-Do from Property List, \(error)")
            }
        }
    }
}


extension ToDoListViewController {

    //MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell")!
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isChecked ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Interactions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].isChecked = !itemArray[indexPath.row].isChecked
        saveArrayToPropertyList()
    
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
}

