//
//  CategoryViewController.swift
//  Todoist
//
//  Created by Ervin on 9/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    //MARK: - Global Variables + ViewDidLoad
    let realm = try! Realm()
    var categoryArray: Results<Category>?
    var alertTextField = UITextField() // for AlertController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - User Interaction Methods
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        self.presentAlert(alertTextField)
    }
    
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell")!
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added."
        
        return cell
    }
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToItems" {
            let destinationVC = segue.destination as! ToDoListViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray?[indexPath.row]
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            do {
                try self.realm.write {
                    let category = self.categoryArray![indexPath.row]
                    self.realm.delete(category.items)
                    self.realm.delete(category)
                }
            } catch { print("Unable to delete category, \(error)") }
            completionHandler(true)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return config
    }

    
    // MARK: - Helper Methods
    func presentAlert(_ textfield: UITextField) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Category Name"
            self.alertTextField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if let userInput = self.alertTextField.text {
                guard userInput != "" else { return }
                let newCategory = Category()
                newCategory.name = userInput
                self.save(category: newCategory)
                self.loadCategories()
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - Realm – Saving and Loading
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving to-do to Realm: \(error)")
        }
    }
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
        
    }
}

