//
//  HomeViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore

var totalBudget: Int = 5000
class HomeViewController: UIViewController {

    @IBOutlet weak var amountRemaining: UILabel!
    @IBOutlet weak var moneySpent: UILabel!
    @IBOutlet weak var percentLeft: UILabel!
    @IBOutlet weak var percentAmount: UILabel!
    @IBOutlet weak var userOutlet: UILabel!
    @IBOutlet weak var lastExpenseLabel: UILabel!
    
    
    let db = Firestore.firestore()
    

    var totalSpent: Double = 0
    var totalBudgetValue: Double = 0
    
    
    func fetchMostRecentExpense() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        db.collection("users").document(uid).collection("expenses").getDocuments { snapshot, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            var latestDate: Date?
            var latestExpense: (type: String, cost: Double)?

            snapshot?.documents.forEach { doc in
                
                if let dateString = doc.data()["date"] as? String,
                   let date = formatter.date(from: dateString) {
                    
                    if latestDate == nil || date > latestDate! {
                        
                        latestDate = date
                        
                        let type = doc.data()["type"] as? String ?? "Unknown"
                        
                        var cost: Double = 0
                        if let value = doc.data()["cost"] as? Double {
                            cost = value
                        } else if let str = doc.data()["cost"] as? String,
                                  let val = Double(str) {
                            cost = val
                        }
                        
                        latestExpense = (type, cost)
                    }
                }
            }

            DispatchQueue.main.async {
                if let expense = latestExpense {
                    self.lastExpenseLabel.text = "Last Expense: \(expense.type) - $\(String(format: "%.2f", expense.cost))"
                } else {
                    self.lastExpenseLabel.text = "No expenses yet"
                }
            }
        }
    }
    
    func fetchTotalForCurrentMonth() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)

        self.db.collection("users").document(uid).collection("expenses").getDocuments { snapshot, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            
            snapshot?.documents.forEach { doc in
                
                // Get date
                if let dateString = doc.data()["date"] as? String,
                   let date = formatter.date(from: dateString) {
                    
                    let docMonth = calendar.component(.month, from: date)
                    let docYear = calendar.component(.year, from: date)
                    
                    
                    if docMonth == currentMonth && docYear == currentYear {
                        
                        if let value = doc.data()["cost"] as? Double {
                            self.totalSpent += value
                        } else if let str = doc.data()["cost"] as? String,
                                  let val = Double(str) {
                            self.totalSpent += val
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self.totalSpent = self.totalSpent   //
                
                self.moneySpent.text = "Money Spent $\(String(format: "%.2f", self.totalSpent)) / $\(String(format: "%.2f", self.totalBudgetValue))"
                
                self.updateUI()
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()


                if let budget = data?["budget"] as? [String: Any],
                   let total = budget["total"] as? Double {
                    
                    self.totalBudgetValue = total
                    self.updateUI()
                } else {
                    self.amountRemaining.text = "No budget"
                }
                
            
                self.fetchMostRecentExpense()
                
                self.fetchTotalForCurrentMonth()
                
                
                if let firstName = data?["firstName"] as? String {
                    self.userOutlet.text = "Hello \(firstName)!"
                }

            } else {
                self.amountRemaining.text = "Error loading"
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    @IBAction func logOutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    func updateUI() {
        
        let remaining = totalBudgetValue - totalSpent
        
        amountRemaining.text = "Remaining: $\(String(format: "%.2f", remaining))"
        
        if totalBudgetValue > 0 {
            let percent = (remaining / totalBudgetValue) * 100
            
            percentLeft.text = "[====  \(String(format: "%.0f", percent))%  ====]"
            
            percentAmount.text = "$\(String(format: "%.2f", remaining)) left"
        } else {
            percentLeft.text = "No budget"
            percentAmount.text = ""
        }
    }
}
