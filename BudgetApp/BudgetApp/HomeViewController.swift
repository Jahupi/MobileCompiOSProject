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
    
    
    let db = Firestore.firestore()
    

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
/*<<<<<<< HEAD
                
                let totalBudget = 0
                 let otherV = data?["other"]
                    //self.amountRemaining.text = "$\(budget)"
                let foodV = data?["food"]
                
                    self.amountRemaining.text = "No budget"
                
                
            } else {
                self.amountRemaining.text = "Error loading"
            }
        }
       
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                // Data is returned as a dictionary [String: Any]
                let data = document.data()
                
                // Extract the specific field (e.g., "firstName")
=======*/

                if let budget = data?["budget"] as? [String: Any],
                   let total = budget["total"] as? Double {
                    self.amountRemaining.text = "$\(String(format: "%.2f", total))"
                } else {
                    self.amountRemaining.text = "No budget"
                }

/*>>>>>>> 0ee7ef9038cc7485f6497bc6f62910ed95e84ea8*/
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
