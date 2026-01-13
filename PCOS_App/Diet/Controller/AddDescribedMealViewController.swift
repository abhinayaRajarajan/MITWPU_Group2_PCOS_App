//
//  AddConfirmViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//
protocol AddDescribedMealDelegate: AnyObject {
    func didConfirmMeal(_ food: Food)
}

import UIKit

class AddDescribedMealViewController: UIViewController {
    
    
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var FoodWeightLabel: UILabel!
    @IBOutlet weak var servingNumberLabel: UILabel!
    @IBOutlet weak var servingStepper: UIStepper!
    @IBOutlet weak var foodWeightView: UIView!
    var foodItem: FoodItem!
    var ingredientsLength: Int = 0
    var food: Food!
    weak var delegate: AddDescribedMealDelegate?
    private var servingMultiplier: Double = 1.0
    private var headerView: FoodLogIngredientHeader!
    private var ingredients: [Ingredient] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard foodItem != nil || food != nil else {
                    print("ERROR: Both foodItem and food are nil!")
                    navigationController?.popViewController(animated: true)
                    return
                }
        loadIngredients()
        setupHeaderConstraints()
        setupHeader()
        setupStepper()
        setupServingLabel()
        setupWeightLabel()
        setupTableView()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Confirm logging this meal"
    }
    
    private func loadIngredients() {
            if let food = food {
                ingredients = food.ingredients ?? []
                foodName.text = food.name
            } else if let foodItem = foodItem {
                ingredients = foodItem.ingredients
                foodName.text = foodItem.name
            }
            
            print("DEBUG: Loaded \(ingredients.count) ingredients")
        }
        
        private func setupHeaderConstraints() {
            guard let headerContainer = foodWeightView else { return }
            headerContainer.translatesAutoresizingMaskIntoConstraints = false
        }
        
        private func setupHeader() {
            guard let containerView = foodWeightView else {
                print("ERROR: foodWeightView is nil!")
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
            if let food = food {
                headerView.configure(with: food)
                print("DEBUG: setupHeader - Configured with Food: \(food.name)")
            } else if let foodItem = foodItem {
                headerView.configure(with: foodItem)
                print("DEBUG: setupHeader - Configured with FoodItem: \(foodItem.name)")
            } else {
                print("ERROR: Both food and foodItem are nil!")
            }
        }
        
        private func setupTableView() {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
        
        private func setupStepper() {
            guard let stepper = servingStepper else {
                print("Error: servingStepper outlet is not connected!")
                return
            }
            
            stepper.minimumValue = 0.5
            stepper.maximumValue = 10.0
            stepper.stepValue = 0.5
            stepper.value = 1.0
            servingMultiplier = 1.0
            
            stepper.tintColor = .label
            stepper.layer.cornerRadius = 10
            stepper.clipsToBounds = true
            
            stepper.addTarget(self, action: #selector(servingStepperChanged(_:)), for: .valueChanged)
        }
        
        @objc private func servingStepperChanged(_ sender: UIStepper) {
            servingMultiplier = sender.value
            
            // Update serving label
            let servingText: String
            if servingMultiplier == 1.0 {
                servingText = "1 serving"
            } else {
                servingText = String(format: "%.1f servings", servingMultiplier)
            }
            servingNumberLabel.text = servingText
            
            // Update weight label
            updateWeightLabel()
            
            // Update header macros with multiplied values
            updateHeaderWithCurrentIngredients()
        }
        
        private func setupServingLabel() {
            guard let label = servingNumberLabel else { return }
            
            label.font = .systemFont(ofSize: 18, weight: .medium)
            label.textColor = .label
            label.text = "1 serving"
        }
        
        private func setupWeightLabel() {
            guard let label = FoodWeightLabel else {
                print("Error: FoodWeightLabel outlet is not connected!")
                return
            }
            
            label.backgroundColor = .systemGray5
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            label.numberOfLines = 2
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textColor = .label
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.systemGray3.cgColor
            
            updateWeightLabel()
            
            print("DEBUG: FoodWeightLabel configured")
        }
        
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let finalFood = createFinalFoodObject() else {
                print("ERROR: Could not create final food object")
                return
            }
            
            print("DEBUG: Final food created: \(finalFood.name)")
            print("DEBUG: Delegate is: \(delegate != nil ? "set" : "nil")")
            
            // Pass it back to DietViewController through delegate
            delegate?.didConfirmMeal(finalFood)
            
            // Dismiss all modals back to DietVC
            // First dismiss this modal
            dismiss(animated: true) { [weak self] in
                // Then dismiss the DescribeFoodVC modal
                self?.presentingViewController?.dismiss(animated: true) {
                    // AddMealVC will pop itself or you can pop it here
                    print("All modals dismissed")
                }
            }
            
            print("Meal confirmed and dismissing")
    }
    
    private func createFinalFoodObject() -> Food? {
            if let food = food {
                // Calculate final macros based on current ingredients and serving multiplier
                var totalProtein: Double = 0
                var totalCarbs: Double = 0
                var totalFat: Double = 0
                
                for ingredient in ingredients {
                    let factor = ingredient.quantity / 100.0
                    totalProtein += ingredient.protein * factor
                    totalCarbs += ingredient.carbs * factor
                    totalFat += ingredient.fats * factor
                }
                
                totalProtein *= servingMultiplier
                totalCarbs *= servingMultiplier
                totalFat *= servingMultiplier
                
                // Create the final Food object
                return Food(
                    id: UUID(), // New ID for the logged meal
                    name: food.name,
                    image: food.image,
                    timeStamp: Date(), // Current time
                    servingSize: food.servingSize * servingMultiplier,
                    weight: food.weight,
                    isSelected: false,
                    isLogged: true, // Mark as logged
                    desc: food.desc,
                    proteinContent: totalProtein,
                    carbsContent: totalCarbs,
                    fatsContent: totalFat,
                    fibreContent: food.fibreContent,
                    customCalories: nil,
                    tags: food.tags,
                    ingredients: ingredients,
                    Insights: food.Insights
                )
            } else if let foodItem = foodItem {
                // Similar for FoodItem
                var totalProtein: Double = 0
                var totalCarbs: Double = 0
                var totalFat: Double = 0
                
                for ingredient in ingredients {
                    let factor = ingredient.quantity / 100.0
                    totalProtein += ingredient.protein * factor
                    totalCarbs += ingredient.carbs * factor
                    totalFat += ingredient.fats * factor
                }
                
                totalProtein *= servingMultiplier
                totalCarbs *= servingMultiplier
                totalFat *= servingMultiplier
                
                // Convert FoodItem to Food
                return Food(
                    id: UUID(),
                    name: foodItem.name,
                    image: foodItem.image,
                    timeStamp: Date(),
                    servingSize: foodItem.servingSize * servingMultiplier,
                    weight: nil,
                    isSelected: false,
                    isLogged: true,
                    desc: foodItem.desc,
                    proteinContent: totalProtein,
                    carbsContent: totalCarbs,
                    fatsContent: totalFat,
                    fibreContent: 0,
                    customCalories: nil,
                    tags: [],
                    ingredients: ingredients,
                    Insights: nil
                )
            }
            
            return nil
        }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func updateWeightLabel() {
            guard let label = FoodWeightLabel else { return }
            
            // Calculate total weight based on type
            var totalWeight: Double = 0
        var unit: String = "g"
            if let food = food {
                totalWeight = (food.servingSize) * servingMultiplier
            } else if let foodItem = foodItem {
                totalWeight = (foodItem.servingSize) * servingMultiplier
                unit = foodItem.unit
            }
            
            label.text = String(format: "Total\n%.0f \(unit)", totalWeight)
        }
        
        // MARK: - Update Header With Current Ingredients
        private func updateHeaderWithCurrentIngredients() {
            guard !ingredients.isEmpty else {
                print("DEBUG: No ingredients to calculate macros")
                return
            }
            
            // Calculate total macros from current ingredients
            var totalProtein: Double = 0
            var totalCarbs: Double = 0
            var totalFat: Double = 0
            
            for ingredient in ingredients {
                // Calculate based on quantity (macros are per 100g)
                let factor = ingredient.quantity / 100.0
                totalProtein += ingredient.protein * factor
                totalCarbs += ingredient.carbs * factor
                totalFat += ingredient.fats * factor
            }
            
            // Apply serving multiplier
            totalProtein *= servingMultiplier
            totalCarbs *= servingMultiplier
            totalFat *= servingMultiplier
            
            print("DEBUG: Calculated macros - P: \(totalProtein), C: \(totalCarbs), F: \(totalFat)")
            
            // Create temporary Food/FoodItem with calculated values
            if let food = food {
                let tempFood = Food(
                    id: food.id,
                    name: food.name,
                    image: food.image,
                    timeStamp: food.timeStamp,
                    servingSize: food.servingSize,
                    weight: food.weight,
                    isSelected: food.isSelected,
                    isLogged: food.isLogged,
                    desc: food.desc,
                    proteinContent: totalProtein,
                    carbsContent: totalCarbs,
                    fatsContent: totalFat,
                    fibreContent: food.fibreContent,
                    customCalories: nil,
                    tags: food.tags,
                    ingredients: ingredients,
                    Insights: food.Insights
                )
                headerView.configure(with: tempFood)
            } else if let foodItem = foodItem {
                let tempFoodItem = FoodItem(
                    id: foodItem.id,
                    name: foodItem.name,
                    calories: Int((totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9)),
                    image: foodItem.image,
                    servingSize: foodItem.servingSize,
                    unit: foodItem.unit,
                    protein: totalProtein,
                    carbs: totalCarbs,
                    fat: totalFat,
                    isSelected: foodItem.isSelected,
                    desc: foodItem.desc,
                    ingredients: ingredients
                )
                headerView.configure(with: tempFoodItem)
            }
            
            print("DEBUG: Header updated with calculated macros")
        }
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    extension AddDescribedMealViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let count = ingredients.count
            print("DEBUG: TableView rows: \(count)")
            return count > 0 ? count : 1 // Show at least 1 row
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            if ingredients.isEmpty {
                cell.textLabel?.text = "No ingredients available"
                cell.textLabel?.textColor = .secondaryLabel
                cell.detailTextLabel?.text = nil
                cell.selectionStyle = .none
            } else {
                let ingredient = ingredients[indexPath.row]
                
                // Display ingredient name
                cell.textLabel?.text = ingredient.name
                cell.textLabel?.textColor = .label
                
                // Display ingredient amount/quantity in detail
//                if let quantity = ingredient.quantity, let unit = ingredient.unit {
//                    cell.detailTextLabel?.text = "\(quantity) \(unit)"
//                } else if let quantity = ingredient.quantity {
//                    cell.detailTextLabel?.text = "\(quantity)"
//                } else {
//                    cell.detailTextLabel?.text = nil
//                }
                
                cell.selectionStyle = .default
            }
            
            // Use subtitle style if available
            cell.detailTextLabel?.textColor = .secondaryLabel
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Edit Ingredients"
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 25
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if !ingredients.isEmpty {
                // Handle ingredient edit
                let ingredient = ingredients[indexPath.row]
                print("DEBUG: Tapped ingredient: \(ingredient.name)")
                // TODO: Show edit interface for quantity/amount
                showEditIngredient(ingredient, at: indexPath)
            }
        }
        
        // MARK: - Enable Editing
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Only allow editing if there are actual ingredients
            return !ingredients.isEmpty
        }
        
        // MARK: - Commit Editing (Delete)
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                // Show confirmation alert before deleting
                let ingredient = ingredients[indexPath.row]
                showDeleteConfirmation(for: ingredient, at: indexPath)
            }
        }
        
        // MARK: - Custom Delete Button Title
        func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
            return "Delete"
        }
        
        // MARK: - Swipe Actions (Alternative to simple delete)
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard !ingredients.isEmpty else { return nil }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
                guard let self = self else {
                    completionHandler(false)
                    return
                }
                
                let ingredient = self.ingredients[indexPath.row]
                self.showDeleteConfirmation(for: ingredient, at: indexPath)
                completionHandler(true)
            }
            
            deleteAction.backgroundColor = .systemRed
            deleteAction.image = UIImage(systemName: "trash.fill")
            
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false // Require confirmation
            
            return configuration
        }
        
        // MARK: - Delete Confirmation Alert
        private func showDeleteConfirmation(for ingredient: Ingredient, at indexPath: IndexPath) {
            let ingredientDisplay: String = ingredient.name
            let alert = UIAlertController(
                title: "Delete Ingredient",
                message: "Are you sure you want to remove '\(ingredientDisplay)' from this meal?",
                preferredStyle: .alert
            )
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                print("DEBUG: Delete cancelled")
            }
            
            // Delete action
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.deleteIngredient(at: indexPath)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            
            present(alert, animated: true)
        }
        
        // MARK: - Delete Ingredient
        private func deleteIngredient(at indexPath: IndexPath) {
            let ingredient = ingredients[indexPath.row]
            print("DEBUG: Deleting ingredient: \(ingredient.name)")
            
            ingredients.remove(at: indexPath.row)
            
            if ingredients.isEmpty {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // ✅ Use this instead of recalculateMacros()
            updateHeaderWithCurrentIngredients()
            
            print("DEBUG: \(ingredients.count) ingredients remaining")
        }
        
        // MARK: - Edit Ingredient
        private func showEditIngredient(_ ingredient: Ingredient, at indexPath: IndexPath) {
            let alert = UIAlertController(
                title: "Edit Ingredient",
                message: "Edit quantity for \(ingredient.name)",
                preferredStyle: .alert
            )
            
            // Add text field for quantity
            alert.addTextField { textField in
                textField.placeholder = "Quantity"
                textField.keyboardType = .decimalPad
//                if let quantity = ingredient.quantity {
//                    textField.text = "\(quantity)"
//                }
            }
            
            // Add text field for unit
            alert.addTextField { textField in
                textField.placeholder = "Unit (g, ml, cup, etc.)"
                textField.text = ingredient.unit
            }
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            // Save action
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let self = self else { return }
                
                let quantityText = alert.textFields?[0].text ?? ""
                let unitText = alert.textFields?[1].text ?? ""
                
                var updatedIngredient = ingredient
                updatedIngredient.quantity = Double(quantityText) ?? 100
                updatedIngredient.unit = unitText.isEmpty ? "g" : unitText
                
                self.ingredients[indexPath.row] = updatedIngredient
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                // ✅ Use this instead of recalculateMacros()
                self.updateHeaderWithCurrentIngredients()
                
                print("DEBUG: Updated ingredient: \(updatedIngredient.name)")
            }
        
            
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            present(alert, animated: true)
        }
        
        // MARK: - Recalculate Macros
        private func recalculateMacros() {
            guard !ingredients.isEmpty else {
                print("DEBUG: No ingredients to recalculate")
                return
            }
            
            // Calculate total macros from remaining ingredients
            var totalProtein: Double = 0
            var totalCarbs: Double = 0
            var totalFat: Double = 0
            
            for ingredient in ingredients {
                totalProtein += ingredient.protein * (ingredient.quantity / 100.0)
                totalCarbs += ingredient.carbs * (ingredient.quantity / 100.0)
                totalFat += ingredient.fats * (ingredient.quantity / 100.0)
            }
            
            // Apply serving multiplier
            totalProtein *= servingMultiplier
            totalCarbs *= servingMultiplier
            totalFat *= servingMultiplier
            
            print("DEBUG: Recalculated macros - P: \(totalProtein), C: \(totalCarbs), F: \(totalFat)")
            
            // Update the food/foodItem object with new values
            if let food = food {
                var modifiedFood = food
                modifiedFood.proteinContent = totalProtein
                modifiedFood.carbsContent = totalCarbs
                modifiedFood.fatsContent = totalFat
                modifiedFood.customCalories = nil // Let it calculate from macros
                
                // Update header
                headerView.configure(with: modifiedFood)
                
                // Update the original reference
                self.food = modifiedFood
            } else if let foodItem = foodItem {
                var modifiedFoodItem = foodItem
                modifiedFoodItem.protein = totalProtein
                modifiedFoodItem.carbs = totalCarbs
                modifiedFoodItem.fat = totalFat
                
                // Update header
                headerView.configure(with: modifiedFoodItem)
                
                // Update the original reference
                self.foodItem = modifiedFoodItem
            }
            
            print("DEBUG: Header updated with new macros")
        }
    }
