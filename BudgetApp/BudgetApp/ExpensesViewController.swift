//
//  ExpensesViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ExpensesViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    //Earliest expenses date
    @IBOutlet weak var expensesDateOL: UILabel!
    //Total amount spent since earliest expenses date
    @IBOutlet weak var amountSpentOL: UILabel!
    
    
    //Inputted date
    @IBOutlet weak var inputtedDateOL: UITextField!
    
    @IBOutlet weak var test: UIDatePicker!
    
    //Inputted cost
    @IBOutlet weak var inputtedCostOL: UITextField!
    //Inputted expense type
    @IBOutlet weak var inputtedTypeOL: UITextField!
    //Expense submit button OL
    @IBOutlet weak var submitButtonOL: UIButton!
    //Expense submit BTN
    @IBAction func submitBTN(_ sender: Any) {
        let date = inputtedDateOL.text ?? ""
        let type = inputtedTypeOL.text ?? ""
        let costString = inputtedCostOL.text ?? ""
        let cost = Double(costString) ?? 0.0
        
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
        
        //Currently showing date and time, change to just date.
        self.statusOL.text = test.date.formatted()
        
        //Reset text fields
        inputtedDateOL.text = ""
        inputtedCostOL.text = ""
        inputtedTypeOL.text = ""
    }
    //Inputted date changed
    @IBAction func dateChanged(_ sender: Any) {
        checkFieldDisableButton()
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
        if inputtedDateOL.text != "" && inputtedCostOL.text != "" && inputtedTypeOL.text != "" {
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
