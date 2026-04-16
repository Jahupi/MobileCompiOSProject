//
//  ExpensesViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

/* TODO:
    Add list of every expense for the current month at the bottom, either in a table view or the last 5 depending on what works.
 
   MAYBE:
    Add a "Past Expenses" button that brings you to a new view that has every past expense seperated by month.
    Find a way for the date input not to be slightly shifted to the right, or for things to be correctly constrainted without hiding the expenses title at the top
    
   PROBABLY NOT:
    Add a camera button that can scan receipts and gather the date and cost, set type as "Receipt"?
    */

// This view controller manages entering expenses, saving them to Firestore, and showing summary info.

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Displays and manages the Expenses screen.
class ExpensesViewController: UIViewController {
    
    // Firestore database reference
    let db = Firestore.firestore()

    //Earliest expenses date
    @IBOutlet weak var expensesDateOL: UILabel!
    //Total amount spent since earliest expenses date
    @IBOutlet weak var amountSpentOL: UILabel!
    //Inputted date
    @IBOutlet weak var inputtedDateOL: UIDatePicker!
    //Inputted cost
    @IBOutlet weak var inputtedCostOL: UITextField!
    //Inputted expense type
    @IBOutlet weak var inputtedTypeOL: UITextField!
    //Expense submit button OL
    @IBOutlet weak var submitButtonOL: UIButton!
    
    
    // Finds the most recent month that has any expenses (scanning backward from current month) and returns
    // the documents and their parsed dates for that month.
    private func mostRecentMonthDocuments(snapshot: QuerySnapshot?, formatter: DateFormatter, calendar: Calendar) -> (docs: [QueryDocumentSnapshot], dates: [Date]) {
        guard let docs = snapshot?.documents else { return ([], []) }
        // Group documents by (year, month)
        var buckets: [String: (docs: [QueryDocumentSnapshot], dates: [Date], year: Int, month: Int)] = [:]
        for doc in docs {
            if let dateString = doc.data()["date"] as? String,
               let date = formatter.date(from: dateString) {
                let comps = calendar.dateComponents([.month, .year], from: date)
                guard let m = comps.month, let y = comps.year else { continue }
                let key = "\(y)-\(m)"
                if buckets[key] == nil {
                    buckets[key] = ([], [], y, m)
                }
                buckets[key]?.docs.append(doc)
                buckets[key]?.dates.append(date)
            }
        }
        // If no buckets, return empty
        if buckets.isEmpty { return ([], []) }
        // Sort keys by year/month descending (most recent first)
        let sorted = buckets.values.sorted { a, b in
            if a.year == b.year { return a.month > b.month }
            return a.year > b.year
        }
        // Choose the most recent bucket (first)
        if let first = sorted.first {
            return (first.docs, first.dates)
        }
        return ([], [])
    }
    
    
    // Handles tapping the Submit button: validates, writes to Firestore, updates UI, and resets inputs.
    @IBAction func submitBTN(_ sender: Any) {
        // Read current inputs
        let date = inputtedDateOL.date.formatted(date: .numeric, time: .omitted)
        let type = inputtedTypeOL.text?.capitalized ?? ""
        let costString = inputtedCostOL.text ?? ""
        let cost = Double(costString) ?? 0.0
        
        // Basic validation: cost must be non-negative
        if cost < 0 {
            self.statusOL.text = "Please input a positive number for Cost"
            return
        }
        
        // Ensure a logged-in user and write the expense document to Firestore
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("expenses").addDocument(data: [
            "date": date,
            "cost": cost,
            "type": type
        ]) { error in
            // Show status if the write failed, otherwise update totals
            if let error = error {
                self.statusOL.text = "Error adding expense: \(error.localizedDescription)"
            } else {
                self.statusOL.text = "Expense added"
                self.fetchAndUpdateTotalSpent()
                self.fetchandUpdateEarliestDate()
            }
        }
        
        
        // Reset inputs to defaults and re-evaluate button enabled state
        inputtedDateOL.date = Date()
        inputtedCostOL.text = ""
        inputtedTypeOL.text = ""
        checkFieldDisableButton()
    }
    
    
    // Camera button (placeholder for future receipt scanning)
    @IBOutlet weak var cameraOL: UIButton!
    // Shows an alert because scanning is not yet implemented
    @IBAction func cameraBTN(_ sender: Any) {
        let alert = UIAlertController(title: "Camera is unavaliable", message: "Receipt scanning is currently still a work in progress", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Re-check whether the Submit button should be enabled when cost changes
    @IBAction func costChanged(_ sender: Any) {
        checkFieldDisableButton()
    }
    // Re-check whether the Submit button should be enabled when type changes
    @IBAction func typeChanged(_ sender: Any) {
        checkFieldDisableButton()
    }
    // Label used to display status messages to the user
    @IBOutlet weak var statusOL: UILabel!
    
    // Enables the Submit button only when required fields are filled
    func checkFieldDisableButton() {
        // Require non-empty cost and type to enable submission
        if inputtedCostOL.text != "" && inputtedTypeOL.text != "" {
            submitButtonOL.isEnabled = true
        } else{
            submitButtonOL.isEnabled = false
        }
    }
    
    // Fetches all expenses for the current user and updates the total amount spent label
    private func fetchAndUpdateTotalSpent() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let calendar = Calendar.current

        db.collection("users").document(uid).collection("expenses").getDocuments { snapshot, error in
            if let error = error {
                self.statusOL.text = "Error fetching expenses: \(error.localizedDescription)"
                return
            }

            let chosen = self.mostRecentMonthDocuments(snapshot: snapshot, formatter: formatter, calendar: calendar)
            var total: Double = 0
            chosen.docs.forEach { doc in
                if let value = doc.data()["cost"] as? Double {
                    total += value
                } else if let str = doc.data()["cost"] as? String, let val = Double(str) {
                    total += val
                }
            }
            self.amountSpentOL.text = "Total amount spent: $\(String(format: "%.2f", total))"
        }
    }
    
    // Fetches all expenses and updates the 'Expenses as of' label with the latest date found in the most recent month
    private func fetchandUpdateEarliestDate(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let calendar = Calendar.current

        db.collection("users").document(uid).collection("expenses").getDocuments { snapshot, error in
            if let error = error {
                self.statusOL.text = "Error fetching dates: \(error.localizedDescription)"
                return
            }

            let chosen = self.mostRecentMonthDocuments(snapshot: snapshot, formatter: formatter, calendar: calendar)
            if let latest = chosen.dates.max() {
                self.expensesDateOL.text = "Expenses as of \(formatter.string(from: latest))"
            } else {
                self.expensesDateOL.text = "Expenses as of --/--/----"
            }
        }
    }

    // Initial setup when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate summary labels from Firestore
        fetchAndUpdateTotalSpent()
        fetchandUpdateEarliestDate()
        
        // Set date picker max date to current date
        inputtedDateOL.maximumDate = Date()

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

