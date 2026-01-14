//
//  DescribeFoodViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 02/12/25.
//

import UIKit

class DescribeFoodViewController: UIViewController {
    
    @IBOutlet weak var dietInfoLabel: UILabel!    
    @IBOutlet weak var describeYourMealText: UITextField!
    
    var foodItems = FoodListdataStore.shared.loadFoodItems()
    var foods = FoodLogDataSource.sampleFoods
    
    var onFoodAdded: ((String) -> Void)?
    weak var dietDelegate: AddDescribedMealDelegate?
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
   
    override func viewDidLoad() {
           super.viewDidLoad()
           view.backgroundColor = UIColor.systemBackground
           title = "Add with AI"
           setupUI()
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
           print("TextField connected: \(describeYourMealText != nil)")
           print("Label connected: \(dietInfoLabel != nil)")
       }
    
    private func processAddMeal() {
           guard let text = describeYourMealText.text, !text.isEmpty else {
               showAlert(message: "Please describe your meal")
               return
           }
           
           print("DEBUG: Searching for: '\(text)'")
           
           // 1. Check foodItems array
           if let match = foodItems.first(where: { $0.desc.localizedCaseInsensitiveContains(text) }) {
               print("DEBUG: Found match in foodItems: \(match.name)")
               performSegue(withIdentifier: "addDescribe", sender: match)
               return
           }
           
           // 2. Check foods array
           if let match = foods.first(where: { $0.name.localizedCaseInsensitiveContains(text) }) {
               print("DEBUG: Found match in foods: \(match.name)")
               performSegue(withIdentifier: "addDescribe", sender: match)
               return
           }
           
           // 3. No match found
           print("DEBUG: No match found")
           showAlert(message: "No matching food found. Please try describing it differently.")
       }
       
       // MARK: - Prepare for Segue
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "addDescribe" {
               if let navigationController = segue.destination as? UINavigationController,
                  let addDescribedVC = navigationController.topViewController as? AddDescribedMealViewController {
                   
                   // Pass the data
                   if let foodData = sender as? Food {
                       addDescribedVC.food = foodData
                   } else if let foodItemData = sender as? FoodItem {
                       addDescribedVC.foodItem = foodItemData
                   }
                   
                   // Pass the delegate
                   addDescribedVC.delegate = self.dietDelegate
                   
                   print("DEBUG: Segue preparation complete with delegate")
               }
           }
       }
       
       // MARK: - Setup UI
       private func setupUI() {
           // Configure text field
           describeYourMealText?.placeholder = "Describe meal with contents, preparation, and size"
           describeYourMealText?.borderStyle = .roundedRect
           describeYourMealText?.font = UIFont.systemFont(ofSize: 14)
           describeYourMealText?.backgroundColor = UIColor.systemBackground
           describeYourMealText?.clipsToBounds = true
           
           // Configure info label
           dietInfoLabel?.backgroundColor = UIColor(hex: "FFE4E1")
           dietInfoLabel?.textColor = UIColor(hex: "333333")
           dietInfoLabel?.text = "Describe what's in your meal, how it was prepared, or the portion size"
           dietInfoLabel?.font = UIFont.systemFont(ofSize: 14)
           dietInfoLabel?.numberOfLines = 0
           dietInfoLabel?.layer.cornerRadius = 8
           dietInfoLabel?.clipsToBounds = true
           dietInfoLabel?.textAlignment = .left
           
           // Add padding to label
           if let text = dietInfoLabel?.text {
               let paragraphStyle = NSMutableParagraphStyle()
               paragraphStyle.firstLineHeadIndent = 12
               paragraphStyle.headIndent = 12
               paragraphStyle.tailIndent = -12
               
               let attributedString = NSAttributedString(
                   string: text,
                   attributes: [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont.systemFont(ofSize: 14),
                       .foregroundColor: UIColor(hex: "D8989E")
                   ]
               )
               dietInfoLabel?.attributedText = attributedString
           }
           
           // Configure Add button
       }
       
       // MARK: - Actions
       @objc private func dismissKeyboard() {
           view.endEditing(true)
       }
    
    @IBAction func close(_ sender: Any) {
        print("Close button tapped")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
       processAddMeal()
    }
        
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

