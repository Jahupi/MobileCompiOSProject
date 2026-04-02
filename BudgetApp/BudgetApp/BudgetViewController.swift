//
//  BudgetViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit

class BudgetViewController: UIViewController {
    
    // MARK: - Outlets
    // Connect these to the text fields in the storyboard
    
    @IBOutlet weak var foodLimitTextField: UITextField!
    @IBOutlet weak var transportationLimitTextField: UITextField!
    @IBOutlet weak var entertainmentLimitTextField: UITextField!
    @IBOutlet weak var billsLimitTextField: UITextField!
    @IBOutlet weak var otherLimitTextField: UITextField!
    
    // Connect this to the label / view you are using as the pie chart placeholder
    @IBOutlet weak var pieChartPlaceholderLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // Future idea:
        // load any saved budget data here
        
        // Future idea:
        // draw pie chart or update a chart view here
    }
    
    
    // MARK: - Setup
    
    func setupUI() {
        // Make the text fields use a number pad for dollar amounts
        foodLimitTextField.keyboardType = .decimalPad
        transportationLimitTextField.keyboardType = .decimalPad
        entertainmentLimitTextField.keyboardType = .decimalPad
        billsLimitTextField.keyboardType = .decimalPad
        otherLimitTextField.keyboardType = .decimalPad
        
        // This is just a placeholder for now
        pieChartPlaceholderLabel.text = "Pie chart will go here"
        
        // Future styling could go here
        // Example:
        // round buttons
        // add borders to text fields
        // style the chart section
    }
    
    
    // MARK: - Actions
    
    @IBAction func saveBudgetTapped(_ sender: UIButton) {
        
        // Grab the values from the text fields
        let food = foodLimitTextField.text ?? ""
        let transportation = transportationLimitTextField.text ?? ""
        let entertainment = entertainmentLimitTextField.text ?? ""
        let bills = billsLimitTextField.text ?? ""
        let other = otherLimitTextField.text ?? ""
        
        // For now, just print them so you can show the inputs are being captured
        print("Food: \(food)")
        print("Transportation: \(transportation)")
        print("Entertainment: \(entertainment)")
        print("Bills: \(bills)")
        print("Other: \(other)")
        
        // Future improvements:
        // 1. Validate that fields are not empty
        // 2. Convert text to Double values
        // 3. Calculate category percentages
        // 4. Update a pie chart based on the values
        // 5. Save values using UserDefaults or Firebase
        // 6. Send totals to the dashboard
        
        showSaveConfirmation()
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        // Clear all text fields
        foodLimitTextField.text = ""
        transportationLimitTextField.text = ""
        entertainmentLimitTextField.text = ""
        billsLimitTextField.text = ""
        otherLimitTextField.text = ""
        
        // Reset placeholder text
        pieChartPlaceholderLabel.text = "Pie chart will go here"
        
        // Future idea:
        // reset the chart display as well
    }
    
    
    // MARK: - Helper Functions
    
    func showSaveConfirmation() {
        let alert = UIAlertController(
            title: "Budget Saved",
            message: "Your budget information has been saved.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Future Improvements
    
    /*
     Possible additions later:
     
     - Add a monthly total field
     - Compare category totals against the full budget
     - Replace the placeholder label with a UIView for a chart
     - Use colors for each category in the chart
     - Store values so they remain after the app closes
     - Pass budget data to the Home/Dashboard screen
     */
}
    
    
    // MARK: - Future Improvements
    
    /*
     Possible additions later:
     
     - Add input validation so empty fields are not accepted
     - Convert text field values into Double values
     - Save budget data using UserDefaults or Firebase
     - Pass budget totals back to the dashboard screen
     - Add more categories like groceries, subscriptions, or savings
     */
