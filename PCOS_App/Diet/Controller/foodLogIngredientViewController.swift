//
//  foodLogIngredientViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class foodLogIngredientViewController: UIViewController {
    
    @IBOutlet weak var servingStepper: UIStepper!
    @IBOutlet weak var servingNumberLabel: UILabel!
    @IBOutlet weak var foodweightView: UIView!
    @IBOutlet weak var FoodWeightLabel: UILabel!
    
    // Header view
    private var headerView: FoodLogIngredientHeader!
    
    // Food data
    var food: Food!
    private var servingMultiplier: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔍 DEBUG: viewDidLoad started")
        
        // Validate food data exists
        guard food != nil else {
            print("❌ Error: No food data provided")
            navigationController?.popViewController(animated: true)
            return
        }
        
        print("✅ DEBUG: Food data exists - \(food.name)")
        
        // Set navigation title
        title = food?.name ?? "Food Details"
        
        // Setup background color
        view.backgroundColor = .systemBackground
        
        // Setup all UI elements
        setupConstraints()
        setupHeader()
        setupStepper()
        setupServingLabel()
        setupWeightLabel()
        updateServingDisplay()
        
        print("✅ DEBUG: viewDidLoad completed successfully")
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        // Enable auto layout for all outlets
        foodweightView.translatesAutoresizingMaskIntoConstraints = false
        servingNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        servingStepper.translatesAutoresizingMaskIntoConstraints = false
        FoodWeightLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // foodweightView - Header container (image with overlay)
            foodweightView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            foodweightView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foodweightView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            foodweightView.heightAnchor.constraint(equalToConstant: 300),
            
            // servingNumberLabel and stepper row
            servingNumberLabel.topAnchor.constraint(equalTo: foodweightView.bottomAnchor, constant: 32),
            servingNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // servingStepper - on same row
            servingStepper.centerYAnchor.constraint(equalTo: servingNumberLabel.centerYAnchor),
            servingStepper.trailingAnchor.constraint(equalTo: FoodWeightLabel.trailingAnchor),
            servingStepper.widthAnchor.constraint(equalToConstant: 94),
            
            // FoodWeightLabel - "Weight Total" on same row but to the right
            FoodWeightLabel.centerYAnchor.constraint(equalTo: servingNumberLabel.centerYAnchor),
            FoodWeightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            FoodWeightLabel.widthAnchor.constraint(equalToConstant: 110),
            FoodWeightLabel.heightAnchor.constraint(equalToConstant: 50),
            FoodWeightLabel.leadingAnchor.constraint(greaterThanOrEqualTo: servingStepper.trailingAnchor, constant: 12)
        ])
    }
    
    // MARK: - Setup Header
    private func setupHeader() {
        print("🔍 DEBUG: setupHeader - Start")
        
        guard let food = food else {
            print("❌ Error: No food data available")
            return
        }
        
        guard let containerView = foodweightView else {
            print("❌ Error: foodweightView outlet is not connected!")
            return
        }
        
        // Clear container
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Set container background
        containerView.backgroundColor = .clear
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        // Load header from nib
        headerView = FoodLogIngredientHeader.loadFromNib()
        
        // Add header view to container
        containerView.addSubview(headerView)
        
        // Setup constraints
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Configure with food data
        headerView.configure(with: food)
        
        print("✅ DEBUG: setupHeader - Complete")
    }
    
    // MARK: - Setup Stepper
    private func setupStepper() {
        guard let stepper = servingStepper else {
            print("❌ Error: servingStepper outlet is not connected!")
            return
        }
        
        stepper.minimumValue = 0.5
        stepper.maximumValue = 10.0
        stepper.stepValue = 0.5
        stepper.value = 1.0
        servingMultiplier = 1.0
        
        // Style the stepper to match design
        stepper.tintColor = .label
        stepper.backgroundColor = .systemGray5
        stepper.layer.cornerRadius = 10
        stepper.clipsToBounds = true
    }
    
    // MARK: - Setup Serving Label
    private func setupServingLabel() {
        guard let label = servingNumberLabel else { return }
        
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
    }
    
    // MARK: - Setup Weight Label
    private func setupWeightLabel() {
        guard let label = FoodWeightLabel else { return }
        
        label.backgroundColor = .systemGray5
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
    }
    
    // MARK: - Actions
    @IBAction func servingStepperChanged(_ sender: UIStepper) {
        servingMultiplier = sender.value
        updateServingDisplay()
        updateMacros()
    }
    
    // MARK: - Update Display
    private func updateServingDisplay() {
        // Update serving label
        let servingText: String
        if servingMultiplier == 1.0 {
            servingText = "1 serving"
        } else if servingMultiplier.truncatingRemainder(dividingBy: 1) == 0 {
            // Whole number
            servingText = "\(Int(servingMultiplier)) servings"
        } else {
            // Decimal
            servingText = String(format: "%.1f servings", servingMultiplier)
        }
        
        servingNumberLabel?.text = servingText
        
        // Update weight label
        guard let food = food else { return }
        
        // Calculate total weight
        let baseWeight = food.weight ?? food.quantity
        let totalWeight = Int(baseWeight * servingMultiplier)
        
        // Format with line break
        let weightText = "Weight total\n\(totalWeight) g"
        FoodWeightLabel?.text = weightText
    }
    
    private func updateMacros() {
        guard let food = food else { return }
        
        // Create a temporary food object with multiplied values
        var multipliedFood = food
        multipliedFood.proteinContent = food.proteinContent * servingMultiplier
        multipliedFood.carbsContent = food.carbsContent * servingMultiplier
        multipliedFood.fatsContent = food.fatsContent * servingMultiplier
        multipliedFood.fibreContent = food.fibreContent * servingMultiplier
        
        // Update weight if available
        if let weight = food.weight {
            multipliedFood.weight = weight * servingMultiplier
        }
        
        // Update custom calories if set, otherwise calculate
        if let customCalories = food.customCalories {
            multipliedFood.customCalories = customCalories * servingMultiplier
        } else {
            let calories = (food.proteinContent * 4) + (food.carbsContent * 4) + (food.fatsContent * 9)
            multipliedFood.customCalories = calories * servingMultiplier
        }
        
        // Update ingredients if available
        if let ingredients = food.ingredients {
            multipliedFood.ingredients = ingredients.map { ingredient in
                var newIngredient = ingredient
                newIngredient.quantity = ingredient.quantity * servingMultiplier
                return newIngredient
            }
        }
        
        headerView.configure(with: multipliedFood)
    }
    
    // MARK: - Static Presentation
    static func present(from viewController: UIViewController, with food: Food) {
        guard let storyboard = viewController.storyboard ?? UIStoryboard(name: "Main", bundle: nil) as UIStoryboard? else {
            print("❌ Error: Could not load storyboard")
            return
        }
        
        guard let ingredientVC = storyboard.instantiateViewController(withIdentifier: "foodLogIngredientViewController") as? foodLogIngredientViewController else {
            print("❌ Error: Could not instantiate foodLogIngredientViewController")
            return
        }
        
        ingredientVC.food = food
        
        if let navController = viewController.navigationController {
            navController.pushViewController(ingredientVC, animated: true)
        } else {
            print("❌ Error: No navigation controller found")
        }
    }
}
