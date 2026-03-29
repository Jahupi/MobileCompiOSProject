//
//  ViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/17/26.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var statusOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUpAction(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailOutlet.text!, password: passwordOutlet.text!) { (result, error) in
            if let error = error {
                self.statusOutlet.text = "Error signing in: \(error.localizedDescription)"
            } else {
                self.statusOutlet.text = "Signed up with email: \(self.emailOutlet.text!)"
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
    }
    
}

