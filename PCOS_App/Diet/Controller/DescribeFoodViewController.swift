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
    @IBOutlet weak var addDescribedMealButton: UIButton!
    var foodItems = FoodListdataStore.shared.loadFoodItems()
    var foods = FoodLogDataSource.sampleFoods
    // Closure to pass data back
    var onFoodAdded: ((String) -> Void)?
    weak var dietDelegate: AddDescribedMealDelegate?
    
    // handlebar UI
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // close button
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: UIControl.State.normal)
        button.tintColor = .systemGray
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // title label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add with AI"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // done button
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(UIColor(hexString: "fe7a96"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        
        // First setup UI styling for storyboard elements
        setupUI()
        
        // Then setup constraints for storyboard elements
        updateStoryboardElementsConstraints()
        
        // Add header views on top
        setupHeaderViews()
        
        // Setup actions
        setupActions()
        
        // Dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Debug: Print to verify outlets are connected
        print("TextField connected: \(describeYourMealText != nil)")
        print("Label connected: \(dietInfoLabel != nil)")
        print("Button connected: \(addDescribedMealButton != nil)")
    }
    
    @IBAction func addMealTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "addDescribe", sender: nil)
        processAddMeal()
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
//                let vc = storyboard?.instantiateViewController(identifier: "AddDescribedMealViewController") as! AddDescribedMealViewController
//                vc.foodItem = match
                performSegue(withIdentifier: "addDescribe", sender: match)
                return
            }
            
            // 2. Check foods array
            if let match = foods.first(where: { $0.name.localizedCaseInsensitiveContains(text) }) {
                print("DEBUG: Found match in foods: \(match.name)")
//                let vc = storyboard?.instantiateViewController(identifier: "AddDescribedMealViewController") as! AddDescribedMealViewController
//                vc.food = match
                performSegue(withIdentifier: "addDescribe", sender: match)
                return
            }
            
            // 3. No match found
            print("DEBUG: No match found")
            showAlert(message: "No matching food found. Please try describing it differently.")
        }
        
        // MARK: - Prepare for Segue (REQUIRED to pass data)
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
                            
                            // IMPORTANT: Pass the delegate through
                            addDescribedVC.delegate = self.dietDelegate
                            
                            print("DEBUG: Segue preparation complete with delegate")
                        }
                    }
        }
        
    
    // MARK: - Setup Header
    private func setupHeaderViews() {
        // Add all header elements to the view
        view.addSubview(handleBar)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Handle bar at top
            handleBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 36),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            // Close button (X) on the left
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Title in center
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            // Done button on the right
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
    }
    
    // MARK: - Update Storyboard Elements
    private func updateStoryboardElementsConstraints() {
        guard let textField = describeYourMealText,
              let label = dietInfoLabel,
              let button = addDescribedMealButton else {
            print(" WARNING: One or more outlets are nil!")
            return
        }
        
        // Enable Auto Layout for storyboard elements
        textField.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove any existing constraints
        NSLayoutConstraint.deactivate(textField.constraints)
        NSLayoutConstraint.deactivate(label.constraints)
        NSLayoutConstraint.deactivate(button.constraints)
        
        // Text field constraints (below the header that we'll add)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Info label constraints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
        
        // Add button constraints
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Configure text field
        describeYourMealText?.placeholder = "Describe meal with contents, preparation, and size"
        describeYourMealText?.borderStyle = UITextField.BorderStyle.roundedRect
        describeYourMealText?.font = UIFont.systemFont(ofSize: 16)
        describeYourMealText?.backgroundColor = UIColor.systemBackground
        describeYourMealText?.layer.cornerRadius = 8
        describeYourMealText?.clipsToBounds = true
        
        // Configure info label (pink hint box)
        dietInfoLabel?.backgroundColor = UIColor(hexString: "FFE4E1")
        dietInfoLabel?.textColor = UIColor(hexString: "333333")
        dietInfoLabel?.text = "Describe what's in your meal, how it was prepared, or the portion size"
        dietInfoLabel?.font = UIFont.systemFont(ofSize: 14)
        dietInfoLabel?.numberOfLines = 0
        dietInfoLabel?.layer.cornerRadius = 8
        dietInfoLabel?.clipsToBounds = true
        dietInfoLabel?.textAlignment = .left
        
        // Add padding to label using attributed text
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
                    .foregroundColor: UIColor(hexString: "D8989E")
                ]
            )
            dietInfoLabel?.attributedText = attributedString
        }
        
        // Configure Add button
        addDescribedMealButton?.backgroundColor = UIColor(hexString: "fe7a96")
        addDescribedMealButton?.setTitle("Add", for: UIControl.State.normal)
        addDescribedMealButton?.setTitleColor(UIColor.white, for: UIControl.State.normal)
        addDescribedMealButton?.layer.cornerRadius = 12
        addDescribedMealButton?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
    
    // MARK: - Actions
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: UIControl.Event.touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: UIControl.Event.touchUpInside)
//        addDescribedMealButton?.addTarget(self, action: #selector(addMealTapped), for: UIControl.Event.touchUpInside)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func closeTapped() {
        print("Close button tapped")
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func doneTapped() {
        print("Done button tapped")
        addMealTapped()
    }
    
    @objc private func addMealTapped() {
        print("Add meal button tapped")
        guard let mealDescription = describeYourMealText?.text, !mealDescription.isEmpty else {
            showAlert(message: "Please describe your meal")
            return
        }
        
        // Pass data back
        onFoodAdded?(mealDescription)
        
        // TODO: Process with AI here
        print("Meal added: \(mealDescription)")
        
        dismiss(animated: true, completion: nil)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Missing Information", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
}


// MARK: - UIColor Extension
extension UIColor {
    convenience init(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

