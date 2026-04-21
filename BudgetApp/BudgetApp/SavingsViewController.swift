//
//  SavingsViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SavingsViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var goalNameTextField: UITextField!
    @IBOutlet weak var targetAmountTextField: UITextField!
    @IBOutlet weak var savedAmountTextField: UITextField!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    //Properties
    
    let db = Firestore.firestore()
    
    //Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldListeners()
        loadSavedGoal()
    }
    
    func setupUI() {
        targetAmountTextField.keyboardType = .decimalPad
        savedAmountTextField.keyboardType = .decimalPad
        
        progressBar.progress = 0
        progressBar.trackTintColor = UIColor.systemGray4
        progressBar.progressTintColor = UIColor.systemBlue
        
        progressLabel.text = "$0.00 of $0.00 Saved"
    }
    
    func setupTextFieldListeners() {
        targetAmountTextField.addTarget(self, action: #selector(fieldsDidChange), for: .editingChanged)
        savedAmountTextField.addTarget(self, action: #selector(fieldsDidChange), for: .editingChanged)
    }
    
    //Live Updates
    
    @objc func fieldsDidChange() {
        updateProgressUI()
    }
    
    func updateProgressUI() {
        let target = Double(targetAmountTextField.text ?? "") ?? 0
        let saved = Double(savedAmountTextField.text ?? "") ?? 0
        
        let progress: Float = (target > 0) ? Float(min(saved / target, 1.0)) : 0
        progressBar.setProgress(progress, animated: true)
        progressLabel.text = "$\(String(format: "%.2f", saved)) of $\(String(format: "%.2f", target)) Saved"
            }
    
    //Actions
    
    @IBAction func saveGoalTapped(_ sender: UIButton) {
        let goalName = goalNameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let target = Double(targetAmountTextField.text ?? "") ?? 0
        let saved = Double(savedAmountTextField.text ?? "") ?? 0
        
        guard !goalName.isEmpty else {
            showMessage(title: "Missing Info", message: "Please enter a goal name.")
            return
        }
        guard target > 0 else {
            showMessage(title: "Missing Info", message: "Please enter a target amount greater than $0.")
            return
        }
        guard saved >= 0 else {
            showMessage(title: "Invalid Amount", message: "Saved amount cannot be negative")
            return
        }
        
        saveToFirestore(goalName: goalName, target: target, saved: saved)
    }

    //Firestore Stuff
    
    func saveToFirestore(goalName: String, target: Double, saved: Double) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showMessage(title: "Save Failed", message: "No logged in user.")
            return
        }
        
        let savingsData: [String: Any] = [
            "goalName": goalName,
            "targetAmount": target,
            "savedAmount": saved,
            "updatedAt": Timestamp()
        ]
        
        db.collection("users").document(uid).setData([
            "savings": savingsData
        ], merge: true) {error in
            if let error = error {
                self.showMessage(title: "Save Failed", message: error.localizedDescription)
            } else {
                self.showMessage(title: "Goal Saved", message: "Your savings goal has been saved!")
            }
        }
    }
    
    func loadSavedGoal() {
            guard let uid = Auth.auth().currentUser?.uid else { return }

            db.collection("users").document(uid).getDocument { document, error in
                if let error = error {
                    print("Error loading savings goal:", error.localizedDescription)
                    return
                }

                guard let document = document, document.exists,
                      let data = document.data(),
                      let savings = data["savings"] as? [String: Any] else {
                    print("No saved savings goal found")
                    return
                }

                let goalName = savings["goalName"] as? String ?? ""
                let target   = savings["targetAmount"] as? Double ?? 0
                let saved    = savings["savedAmount"]  as? Double ?? 0

                self.goalNameTextField.text      = goalName
                self.targetAmountTextField.text  = target == 0 ? "" : String(format: "%.0f", target)
                self.savedAmountTextField.text   = saved  == 0 ? "" : String(format: "%.0f", saved)

                self.updateProgressUI()
            }
        }
    
    //Helpers
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
   
}
