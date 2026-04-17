//
//  BudgetViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit
import FirebaseFirestore
import DGCharts

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
        setupPieChart()
        setupUI()
        setupTextFieldListeners()
        
        // Future idea:
        // load any saved budget data here
        

    }
    
    
    // MARK: - Setup
    
    func setupUI() {
        // Make the text fields use a number pad for dollar amounts
        foodLimitTextField.keyboardType = .decimalPad
        transportationLimitTextField.keyboardType = .decimalPad
        entertainmentLimitTextField.keyboardType = .decimalPad
        billsLimitTextField.keyboardType = .decimalPad
        otherLimitTextField.keyboardType = .decimalPad
        
   
        // Future styling could go here
        // Example:
        // round buttons
        // add borders to text fields
        // style the chart section
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
    }
    
    // MARK: - Actions
    
    @IBAction func saveBudgetTapped(_ sender: UIButton) {
        
        let food = Double(foodLimitTextField.text ?? "") ?? 0
        let transportation = Double(transportationLimitTextField.text ?? "") ?? 0
        let entertainment = Double(entertainmentLimitTextField.text ?? "") ?? 0
        let bills = Double(billsLimitTextField.text ?? "") ?? 0
        let other = Double(otherLimitTextField.text ?? "") ?? 0
        
        let total = food + transportation + entertainment + bills + other
        
        totalBudgetField.text = "\(total)"
        
        saveToFirestore(food: food,
                        transportation: transportation,
                        entertainment: entertainment,
                        bills: bills,
                        other: other,
                        total: total)
        
        updatePieChart(food: food,
                       transportation: transportation,
                       entertainment: entertainment,
                       bills: bills,
                       other: other)
        
        showSaveConfirmation()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // Clear all text fields
        foodLimitTextField.text = ""
            transportationLimitTextField.text = ""
            entertainmentLimitTextField.text = ""
            billsLimitTextField.text = ""
            otherLimitTextField.text = ""
            totalBudgetField.text = ""
            
            pieChartView.data = nil
         
    }
    
    func saveToFirestore(food: Double,
                         transportation: Double,
                         entertainment: Double,
                         bills: Double,
                         other: Double,
                         total: Double) {
        
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "food": food,
            "transportation": transportation,
            "entertainment": entertainment,
            "bills": bills,
            "other": other,
            "total": total,
            "date": Timestamp()
        ]
        
        db.collection("budgets").addDocument(data: data) { error in
            if let error = error {
                print("❌ Error saving: \(error)")
            } else {
                print("✅ Budget saved to Firebase")
            }
        }
    }
    
    
    //when view ia loaded
    func setupPieChart() {
        pieChartView.usePercentValuesEnabled = true
        pieChartView.drawHoleEnabled = true
        pieChartView.holeRadiusPercent = 0.45
        pieChartView.transparentCircleRadiusPercent = 0.5
        pieChartView.chartDescription.enabled = false
        pieChartView.rotationEnabled = true
        pieChartView.centerText = "Budget"
        pieChartView.holeRadiusPercent = 0.6
        pieChartView.transparentCircleRadiusPercent = 0.65
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
                pieChartView.centerText = "No Data"
                return
            }

            var entries: [PieChartDataEntry] = []

            for item in filteredValues {
                entries.append(PieChartDataEntry(value: item.1, label: item.0))
            }

            let dataSet = PieChartDataSet(entries: entries, label: "Budget Categories")

            // Custom colors
            dataSet.colors = [
                UIColor.systemGreen,
                UIColor.systemBlue,
                UIColor.systemOrange,
                UIColor.systemRed,
                UIColor.systemPurple
            ]

            dataSet.sliceSpace = 2
            dataSet.selectionShift = 5

            let data = PieChartData(dataSet: dataSet)

            let total = food + transportation + entertainment + bills + other

            let formatter = DefaultValueFormatter { value, _, _, _ in
                let percent = (value / total) * 100
                return String(format: "$%.0f (%.1f%%)", value, percent)
            }

            data.setValueFormatter(formatter)

            data.setValueFont(.systemFont(ofSize: 12))
            data.setValueTextColor(.black)

            pieChartView.data = data
            pieChartView.drawEntryLabelsEnabled = false
            data.setDrawValues(false)
           

            pieChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuad)

            pieChartView.notifyDataSetChanged()
        }

       // MARK: - Alert

       func showSaveConfirmation() {
           let alert = UIAlertController(
               title: "Budget Saved",
               message: "Your budget information has been saved.",
               preferredStyle: .alert
           )

           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
  
    
}


