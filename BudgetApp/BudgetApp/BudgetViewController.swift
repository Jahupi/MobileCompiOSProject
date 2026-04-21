//
//  BudgetViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit
import FirebaseFirestore
import DGCharts
import FirebaseAuth

class BudgetViewController: UIViewController {
    
    // MARK: - Outlets
    // Connect these to the text fields in the storyboard
    
    @IBOutlet weak var foodLimitTextField: UITextField!
    @IBOutlet weak var transportationLimitTextField: UITextField!
    @IBOutlet weak var entertainmentLimitTextField: UITextField!
    @IBOutlet weak var billsLimitTextField: UITextField!
    @IBOutlet weak var otherLimitTextField: UITextField!
    
    
    @IBOutlet weak var totalBudgetField: UITextField!
    
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedBudget()
        pieChartView.isUserInteractionEnabled = false
        setupUI()
        setupPieChart()
        setupTextFieldListeners()

    }
    
    
    // MARK: - Setup
    
    func setupUI() {
        foodLimitTextField.keyboardType = .decimalPad
            transportationLimitTextField.keyboardType = .decimalPad
            entertainmentLimitTextField.keyboardType = .decimalPad
            billsLimitTextField.keyboardType = .decimalPad
            otherLimitTextField.keyboardType = .decimalPad
            
            totalBudgetField.text = "$0.00"
    }
    
    func setupTextFieldListeners() {
        foodLimitTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        transportationLimitTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        entertainmentLimitTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        billsLimitTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
        otherLimitTextField.addTarget(self, action: #selector(textFieldsDidChange), for: .editingChanged)
    }
    
    @objc func textFieldsDidChange() {
        let food = Double(foodLimitTextField.text ?? "") ?? 0
        let transportation = Double(transportationLimitTextField.text ?? "") ?? 0
        let entertainment = Double(entertainmentLimitTextField.text ?? "") ?? 0
        let bills = Double(billsLimitTextField.text ?? "") ?? 0
        let other = Double(otherLimitTextField.text ?? "") ?? 0
        
        let total = food + transportation + entertainment + bills + other
        totalBudgetField.text = String(format: "$%.2f", total)
        
        updatePieChart(
            food: food,
            transportation: transportation,
            entertainment: entertainment,
            bills: bills,
            other: other
        )
    }
    
    // MARK: - Actions
    
    @IBAction func saveBudgetTapped(_ sender: UIButton) {
        
        let food = Double(foodLimitTextField.text ?? "") ?? 0
                let transportation = Double(transportationLimitTextField.text ?? "") ?? 0
                let entertainment = Double(entertainmentLimitTextField.text ?? "") ?? 0
                let bills = Double(billsLimitTextField.text ?? "") ?? 0
                let other = Double(otherLimitTextField.text ?? "") ?? 0
                
                let total = food + transportation + entertainment + bills + other
                totalBudgetField.text = String(format: "$%.2f", total)
                
                saveToFirestore(
                    food: food,
                    transportation: transportation,
                    entertainment: entertainment,
                    bills: bills,
                    other: other,
                    total: total
                )
           
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        foodLimitTextField.text = ""
               transportationLimitTextField.text = ""
               entertainmentLimitTextField.text = ""
               billsLimitTextField.text = ""
               otherLimitTextField.text = ""
               totalBudgetField.text = "$0.00"
               
               pieChartView.data = nil
               pieChartView.centerText = ""
               pieChartView.notifyDataSetChanged()
    }
    
    func saveToFirestore(food: Double,
                         transportation: Double,
                         entertainment: Double,
                         bills: Double,
                         other: Double,
                         total: Double) {

        guard let uid = Auth.auth().currentUser?.uid else {
                    showMessage(title: "Save Failed", message: "No logged in user.")
                    return
                }
                
                let db = Firestore.firestore()
                
                let budgetData: [String: Any] = [
                    "food": food,
                    "transportation": transportation,
                    "entertainment": entertainment,
                    "bills": bills,
                    "other": other,
                    "total": total,
                    "updatedAt": Timestamp()
                ]
                
                db.collection("users").document(uid).setData([
                    "budget": budgetData
                ], merge: true) { error in
                    if let error = error {
                        self.showMessage(title: "Save Failed", message: error.localizedDescription)
                    } else {
                        self.showMessage(title: "Budget Saved", message: "Your budget information has been saved.")
                    }
                }
    }
    func setupPieChart() {
        pieChartView.usePercentValuesEnabled = false
             //  pieChartView.drawHoleEnabled = true
               pieChartView.chartDescription.enabled = false
               pieChartView.rotationEnabled = true
               pieChartView.drawEntryLabelsEnabled = false
               pieChartView.centerText = ""
    }
    
    
    func updatePieChart(food: Double,
                        transportation: Double,
                        entertainment: Double,
                        bills: Double,
                        other: Double) {

        let values: [(String, Double)] = [
                  ("Food", food),
                  ("Transportation", transportation),
                  ("Entertainment", entertainment),
                  ("Bills", bills),
                  ("Other", other)
              ]
              
              let filteredValues = values.filter { $0.1 > 0 }
              
              if filteredValues.isEmpty {
                  pieChartView.data = nil
                  pieChartView.centerText = ""
                  return
              }
              
              var entries: [PieChartDataEntry] = []
              
              for item in filteredValues {
                  entries.append(PieChartDataEntry(value: item.1, label: item.0))
              }
              
              let dataSet = PieChartDataSet(entries: entries, label: "Budget Categories")
              dataSet.colors = [
                  UIColor.systemGreen,
                  UIColor.systemBlue,
                  UIColor.systemOrange,
                  UIColor.systemRed,
                  UIColor.systemPurple
              ]
              dataSet.sliceSpace = 2
              dataSet.selectionShift = 5
              dataSet.drawValuesEnabled = false
              
              let data = PieChartData(dataSet: dataSet)
              data.setDrawValues(false)

        pieChartView.data = data
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuad)
        pieChartView.notifyDataSetChanged()
    }
    
    func loadSavedBudget() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }

        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { document, error in
            if let error = error {
                print("Error loading budget:", error.localizedDescription)
                return
            }

            guard let document = document, document.exists,
                  let data = document.data(),
                  let budget = data["budget"] as? [String: Any] else {
                print("No saved budget found")
                return
            }

            let food = budget["food"] as? Double ?? 0
            let transportation = budget["transportation"] as? Double ?? 0
            let entertainment = budget["entertainment"] as? Double ?? 0
            let bills = budget["bills"] as? Double ?? 0
            let other = budget["other"] as? Double ?? 0
            let total = budget["total"] as? Double ?? 0

            self.foodLimitTextField.text = food == 0 ? "" : String(format: "%.0f", food)
            self.transportationLimitTextField.text = transportation == 0 ? "" : String(format: "%.0f", transportation)
            self.entertainmentLimitTextField.text = entertainment == 0 ? "" : String(format: "%.0f", entertainment)
            self.billsLimitTextField.text = bills == 0 ? "" : String(format: "%.0f", bills)
            self.otherLimitTextField.text = other == 0 ? "" : String(format: "%.0f", other)

            self.totalBudgetField.text = String(format: "$%.2f", total)

            self.updatePieChart(
                food: food,
                transportation: transportation,
                entertainment: entertainment,
                bills: bills,
                other: other
            )
        }
    }
    func showMessage(title: String, message: String) {
           let alert = UIAlertController(
               title: title,
               message: message,
               preferredStyle: .alert
           )
           
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
  
    
}


