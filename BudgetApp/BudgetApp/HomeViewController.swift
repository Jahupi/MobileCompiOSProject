//
//  HomeViewController.swift
//  BudgetApp
//
//  Created by Jackley,Tanner D on 3/24/26.
//

import UIKit
var totalBudget: Int = 5000
class HomeViewController: UIViewController {

    @IBOutlet weak var amountRemaining: UILabel!
    @IBOutlet weak var moneySpent: UILabel!
    
    @IBOutlet weak var percentLeft: UILabel!
    @IBOutlet weak var percentAmount: UILabel!
    
    
    
    
    
    @IBAction func addExpense(_ sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
