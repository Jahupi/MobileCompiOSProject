//
//  ViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/17/26.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {

    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var statusOutlet: UILabel!
    
    @IBOutlet weak var firstNameOutlet: UITextField!
    @IBOutlet weak var lastNameOutlet: UITextField!
    
    func resetFields() {
        firstNameOutlet.text = ""
        lastNameOutlet.text = ""
        emailOutlet.text = ""
        passwordOutlet.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resetFields()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }

    @IBAction func signUpAction(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailOutlet.text!, password: passwordOutlet.text!) { (result, error) in
            if let error = error {
                self.statusOutlet.text = "Error signing in: \(error.localizedDescription)"
            } else {
                self.statusOutlet.text = "Signed up with email: \(self.emailOutlet.text!)"
                self.createUserDocument(self.firstNameOutlet.text!, self.lastNameOutlet.text!)
                self.resetFields()
            }
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailOutlet.text!, password: passwordOutlet.text!) { (result, error) in
            if let error = error {
                self.statusOutlet.text = "Error signing in: \(error.localizedDescription)"
            } else {
                self.statusOutlet.text = "Signed in with email: \(self.emailOutlet.text!)"
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
        }
        resetFields()
    }

    func createUserDocument(_ firstName: String, _ lastName: String) {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            print("No authenticated user")
            return
        }
        
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "uid": uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "createdAt": Timestamp(),
            "updatedAt": Timestamp(),
            "defaultCurrency": "USD"
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
            } else {
                print("User document successfully created")
            }
        }
    }
}

