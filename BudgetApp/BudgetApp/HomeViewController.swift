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
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let uid = Auth.auth().currentUser?.uid else {
                print("User not authenticated")
                return
            
            
            //moneySpent.text =
            }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                // Data is returned as a dictionary [String: Any]
                let data = document.data()
                
                // Extract the specific field (e.g., "firstName")
                if let firstName = data?["firstName"] as? String {
                    self.userOutlet.text = "Hello \(firstName)!"
                }
            } else {
                print("Document does not exist or there was an error: \(error?.localizedDescription ?? "Unknown error")")
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
