//
//  CategoryViewController.swift
//  Todoist
//
//  Created by Ervin on 9/10/18.
//  Copyright © 2018 Ervin. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    //MARK: - Global Variables + ViewDidLoad
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArray = [Category]()
    var alertTextField = UITextField() // for AlertController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArrayFromContext()
        
    }
    
    //MARK: - User Interaction Methods
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        self.presentAlert(alertTextField)
    }
    
    
    // MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell")!
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
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
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
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
                let newCategory = Category(context: self.context)
                newCategory.name = userInput
                self.categoryArray.append(newCategory)
                self.saveArrayToContext()
                
                self.tableView.reloadData()
                print(self.categoryArray)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - CoreData – Saving and Loading
    func saveArrayToContext() {
        do {
            try context.save()
        } catch {
            print("Error saving to-do to context: \(error)")
        }
    }
    
    func loadArrayFromContext() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        fetchArrayWithRequest(named: request)
        
    }
    
    func fetchArrayWithRequest(named request: NSFetchRequest<Category>) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching to-do with request: \(error)")
        }
        tableView.reloadData()
    }
}
