//
//  ExpensesViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

/* TODO:
    Segment date by current month using system's date and time, users should only be able to input the date if its in the current month
    Amount spent and expenses as of should only be for the current month. If the last expense was in March but a new expense is submitted in April, the April date overrides the March date
    Add list of every expense for the current month at the bottom, either in a table view or the last 5 depending on what works.
    Potentially add a camera button that can scan receipts and gather the date and cost, set type as "Receipt"?
    Potentially add a "Past Expenses" button that brings you to a new view that has every past expense seperated by month.
    Find a way for the date input not to be slightly shifted to the right, or for things to be correctly constrainted without hiding the expenses title at the top
    */

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ExpensesViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    //Earliest expenses date
    @IBOutlet weak var expensesDateOL: UILabel!
    //Total amount spent since earliest expenses date
    @IBOutlet weak var amountSpentOL: UILabel!
    
    @IBOutlet weak var wheel: UIPickerView!
    
    
    //Inputted date
    @IBOutlet weak var inputtedDateOL: UIDatePicker!
    //Inputted cost
    @IBOutlet weak var inputtedCostOL: UITextField!
    //Inputted expense type
    @IBOutlet weak var inputtedTypeOL: UITextField!
    //Expense submit button OL
    @IBOutlet weak var submitButtonOL: UIButton!
    
    
    //Expense submit BTN
    @IBAction func submitBTN(_ sender: Any) {
        let date = inputtedDateOL.date.formatted(date: .numeric, time: .omitted)
        let type = inputtedTypeOL.text?.capitalized ?? ""
        let costString = inputtedCostOL.text ?? ""
        let cost = Double(costString) ?? 0.0
        
        if cost < 0 {
            self.statusOL.text = "Please input a positive number for Cost"
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("expenses").addDocument(data: [
            "date": date,
            "cost": cost,
            "type": type
        ]) { error in
            if let error = error {
                self.statusOL.text = "Error adding expense: \(error.localizedDescription)"
            } else {
                self.statusOL.text = "Expense added"
                self.fetchAndUpdateTotalSpent()
            }
        }
        
        
        //Reset text fields
        inputtedDateOL.date = Date()
        inputtedCostOL.text = ""
        inputtedTypeOL.text = ""
        checkFieldDisableButton()
    }
    
    
    //Camera button outlet
    @IBOutlet weak var cameraOL: UIButton!
    //Camera button
    @IBAction func cameraBTN(_ sender: Any) {
        let alert = UIAlertController(title: "Camera is unavaliable", message: "Receipt scanning is currently still a work in progress", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Inputted cost changed
    @IBAction func costChanged(_ sender: Any) {
        checkFieldDisableButton()
    }
    //Inputted type changed
    @IBAction func typeChanged(_ sender: Any) {
        checkFieldDisableButton()
    }
    //Status label
    @IBOutlet weak var statusOL: UILabel!
    
    //Check text field disable btn
    func checkFieldDisableButton() {
        if inputtedCostOL.text != "" && inputtedTypeOL.text != "" {
            submitButtonOL.isEnabled = true
        } else{
            submitButtonOL.isEnabled = false
        }
    }
    
    private func fetchAndUpdateTotalSpent() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("expenses").getDocuments { snapshot, error in
            if let error = error {
                self.statusOL.text = "Error fetching expenses: \(error.localizedDescription)"
                return
            }
            var total: Double = 0
            snapshot?.documents.forEach { doc in
                if let value = doc.data()["cost"] as? Double {
                    total += value
                } else if let str = doc.data()["cost"] as? String, let val = Double(str) {
                    total += val
                }
            }
            self.amountSpentOL.text = "Total amount spent: $\(String(format: "%.2f", total))"
        }
    }
    
    private func fetchandUpdateEarliestDate(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        db.collection("users").document(uid).collection("expenses").getDocuments { snapshot, error in
            if let error = error {
                self.statusOL.text = "Error fetching dates: \(error.localizedDescription)"
                return
            }
            var earliest: Date?
            snapshot?.documents.forEach { doc in
                if let dateString = doc.data()["date"] as? String,
                   let date = formatter.date(from: dateString) {
                    if let current = earliest {
                        if date < current { earliest = date }
                    } else {
                        earliest = date
                    }
                }
            }
            if let earliest = earliest {
                self.expensesDateOL.text = "Expenses as of \( formatter.string(from: earliest))"
            } else {
                self.expensesDateOL.text = "Expenses as of --/--/----"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAndUpdateTotalSpent()
        fetchandUpdateEarliestDate()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
