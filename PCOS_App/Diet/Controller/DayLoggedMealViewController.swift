//
//  DayLoggedMealViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class DayLoggedMealViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mealDayLabel: UILabel!
    @IBOutlet weak var noMealsLabel: UILabel!
    @IBOutlet weak var daysMeal: UITableView!
    
    var selectedDate: Date!
    private var meals: [Food] = []
    private let calendar = Calendar.current
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupTableView()
            loadAndDisplay()
        }
        
        private func setupUI() {
            // Initially hide no meals label
            noMealsLabel.isHidden = true
            noMealsLabel.text = "No meals logged for this day"
            noMealsLabel.textColor = .systemGray
            noMealsLabel.font = .systemFont(ofSize: 16)
            noMealsLabel.textAlignment = .center
            
            // Setup meal day label (total calories)
            mealDayLabel.font = .systemFont(ofSize: 16, weight: .medium)
            mealDayLabel.textAlignment = .center
            mealDayLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        }
        
        private func setupTableView() {
            daysMeal.backgroundColor = .clear
            daysMeal.delegate = self
            daysMeal.dataSource = self
            daysMeal.separatorStyle = .none
            daysMeal.rowHeight = UITableView.automaticDimension
            daysMeal.estimatedRowHeight = 80
            daysMeal.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            
            // Register custom cell
            daysMeal.register(UITableViewCell.self, forCellReuseIdentifier: "MealCell")
        }
        
        private func loadAndDisplay() {
            updateDateLabel()
            loadMeals()
            updateTotalCalories()
        }
        
        private func updateDateLabel() {
            guard let selectedDate = selectedDate else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = formatter.string(from: selectedDate)
            dateLabel.font = .systemFont(ofSize: 18, weight: .semibold)
            dateLabel.textAlignment = .center
        }
        
        private func loadMeals() {
            guard let selectedDate = selectedDate else { return }
            
            let allMeals = FoodLogDataSource.sampleFoods
            let selectedDayStart = calendar.startOfDay(for: selectedDate)
            let selectedDayEnd = calendar.date(byAdding: .day, value: 1, to: selectedDayStart)!
            
            meals = allMeals.filter { meal in
                meal.isLogged && meal.timeStamp >= selectedDayStart && meal.timeStamp < selectedDayEnd
            }.sorted { $0.timeStamp < $1.timeStamp }
            
            if meals.isEmpty {
                daysMeal.isHidden = true
                noMealsLabel.isHidden = false
            } else {
                daysMeal.isHidden = false
                noMealsLabel.isHidden = true
            }
            
            daysMeal.reloadData()
            
            print("DEBUG: Loaded \(meals.count) meals for \(selectedDate)")
        }
        
        private func updateTotalCalories() {
            guard !meals.isEmpty else {
                mealDayLabel.text = "0 kcal"
                return
            }
            
            let totalCalories = meals.reduce(0) { total, meal in
                let calories = Int((meal.proteinContent * 4) + (meal.carbsContent * 4) + (meal.fatsContent * 9))
                return total + calories
            }
            
            mealDayLabel.text = "\(totalCalories) kcal total"
        }
        
        // MARK: - Public Method to Update Date
        func updateDate(_ newDate: Date) {
            selectedDate = newDate
            loadAndDisplay()
        }
    }

    // MARK: - UITableViewDataSource
    extension DayLoggedMealViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return meals.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
            let meal = meals[indexPath.row]
            
            // Clear previous content
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            // Configure cell
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            // Create card container
            let cardView = UIView()
            cardView.translatesAutoresizingMaskIntoConstraints = false
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 12
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.05
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowRadius = 4
            cell.contentView.addSubview(cardView)
            
            // Meal image view
            let mealImageView = UIImageView()
            mealImageView.translatesAutoresizingMaskIntoConstraints = false
            mealImageView.contentMode = .scaleAspectFill
            mealImageView.clipsToBounds = true
            mealImageView.layer.cornerRadius = 8
            mealImageView.backgroundColor = UIColor.systemGray6
            
            if let imageName = meal.image, let image = UIImage(named: imageName) {
                mealImageView.image = image
            } else {
                mealImageView.image = UIImage(systemName: "fork.knife")
                mealImageView.tintColor = .systemGray3
                mealImageView.contentMode = .center
            }
            cardView.addSubview(mealImageView)
            
            // Meal info container
            let infoStackView = UIStackView()
            infoStackView.translatesAutoresizingMaskIntoConstraints = false
            infoStackView.axis = .vertical
            infoStackView.spacing = 4
            infoStackView.alignment = .leading
            cardView.addSubview(infoStackView)
            
            // Meal name label
            let nameLabel = UILabel()
            nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            nameLabel.textColor = .darkGray
            nameLabel.text = meal.name
            nameLabel.numberOfLines = 1
            infoStackView.addArrangedSubview(nameLabel)
            
            // Time label
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let timeLabel = UILabel()
            timeLabel.font = .systemFont(ofSize: 14)
            timeLabel.textColor = .systemGray
            timeLabel.text = timeFormatter.string(from: meal.timeStamp)
            infoStackView.addArrangedSubview(timeLabel)
            
            // Calories label
            let calories = Int((meal.proteinContent * 4) + (meal.carbsContent * 4) + (meal.fatsContent * 9))
            let caloriesLabel = UILabel()
            caloriesLabel.font = .systemFont(ofSize: 14, weight: .medium)
            caloriesLabel.textColor = UIColor(red: 254.0/255.0, green: 122.0/255.0, blue: 150.0/255.0, alpha: 1.0)
            caloriesLabel.text = "\(calories) kcal"
            infoStackView.addArrangedSubview(caloriesLabel)
            
            // Macros label
            let macrosLabel = UILabel()
            macrosLabel.font = .systemFont(ofSize: 12)
            macrosLabel.textColor = .systemGray2
            macrosLabel.text = String(format: "• P: %.0fg     • C: %.0fg     • F: %.0fg",
                                       meal.proteinContent,
                                       meal.carbsContent,
                                       meal.fatsContent)
            infoStackView.addArrangedSubview(macrosLabel)
            
            NSLayoutConstraint.activate([
                // Card view constraints
                cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
                cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0),
                cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -0),
                cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
                
                // Meal image
                mealImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
                mealImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
                mealImageView.widthAnchor.constraint(equalToConstant: 60),
                mealImageView.heightAnchor.constraint(equalToConstant: 60),
                
                // Info stack view
                infoStackView.leadingAnchor.constraint(equalTo: mealImageView.trailingAnchor, constant: 12),
                infoStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
                infoStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
                infoStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
            ])
            
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    extension DayLoggedMealViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let selectedMeal = meals[indexPath.row]
            
            // Navigate to meal detail if needed
            print("DEBUG: Selected meal: \(selectedMeal.name)")
            
            // Optional: Navigate to FoodLogIngredientViewController
            FoodLogIngredientViewController.present(from: self, with: selectedMeal)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 96
        }
    }
