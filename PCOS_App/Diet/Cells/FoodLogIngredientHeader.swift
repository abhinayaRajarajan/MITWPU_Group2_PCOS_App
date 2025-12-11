//
//  FoodLogIngredientHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class FoodLogIngredientHeader: UIView {
    
    @IBOutlet weak var FoodImageView: UIImageView!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatsLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    
    @IBOutlet weak var macrosContainerStack: UIStackView!
    
    
    private var food: Food?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Image view styling
        FoodImageView.contentMode = .scaleAspectFill
        FoodImageView.clipsToBounds = true
        FoodImageView.layer.cornerRadius = 16
        FoodImageView.backgroundColor = .systemGray5
        
        // Macros container styling - glass effect overlay
        macrosContainerStack.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        macrosContainerStack.layer.cornerRadius = 16
        macrosContainerStack.layer.shadowColor = UIColor.black.cgColor
        macrosContainerStack.layer.shadowOpacity = 0.15
        macrosContainerStack.layer.shadowOffset = CGSize(width: 0, height: 4)
        macrosContainerStack.layer.shadowRadius = 12
        
        // Add blur effect
        addBlurEffect()
        
        macrosContainerStack.spacing = 0
        macrosContainerStack.distribution = .fillEqually
        macrosContainerStack.axis = .horizontal
        macrosContainerStack.layoutMargins = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        macrosContainerStack.isLayoutMarginsRelativeArrangement = true
        
        // Style the macro labels
        styleMacroLabels()
    }
    
    private func addBlurEffect() {
        // Remove any existing blur
        macrosContainerStack.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.clipsToBounds = true
        
        // Insert blur as background
        macrosContainerStack.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: macrosContainerStack.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: macrosContainerStack.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: macrosContainerStack.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: macrosContainerStack.bottomAnchor)
        ])
        
        // Make container background clear so blur shows
        macrosContainerStack.backgroundColor = .clear
    }
    
    private func styleMacroLabels() {
        // Style each macro label
        [caloriesLabel, carbsLabel, fatsLabel, proteinLabel].forEach { label in
            label?.font = .systemFont(ofSize: 15, weight: .semibold)
            label?.textAlignment = .center
            label?.numberOfLines = 2
            label?.textColor = .label
        }
    }
    
    // MARK: - Configure
    func configure(with food: Food) {
        self.food = food
        
        // Set image
        if let imageName = food.image, let image = UIImage(named: imageName) {
            FoodImageView.image = image
            FoodImageView.backgroundColor = .clear
        } else {
            FoodImageView.image = UIImage(named: "placeholder_food")
            FoodImageView.backgroundColor = .systemGray5
        }
        
        // Update macros
        updateMacros()
    }
    
    private func updateMacros() {
        guard let food = food else { return }
        
        // Calculate or use custom calories
        let calories = food.customCalories ?? ((food.proteinContent * 4) + (food.carbsContent * 4) + (food.fatsContent * 9))
        
        // Format the labels to match your design (value on top, label below)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 2
        
        caloriesLabel.attributedText = formatMacroText(value: "\(Int(calories)) kcal", label: "Calories")
        carbsLabel.attributedText = formatMacroText(value: "\(Int(food.carbsContent)) g", label: "Carbs")
        fatsLabel.attributedText = formatMacroText(value: "\(Int(food.fatsContent)) g", label: "Fat")
        proteinLabel.attributedText = formatMacroText(value: "\(Int(food.proteinContent)) g", label: "Protein")
    }
    
    private func formatMacroText(value: String, label: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString()
        
        // Label text (smaller, on top)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        attributed.append(NSAttributedString(string: label + "\n", attributes: labelAttributes))
        
        // Value text (larger, bold, below)
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        attributed.append(NSAttributedString(string: value, attributes: valueAttributes))
        
        return attributed
    }
    
    // MARK: - Layout Override
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure constraints are set up properly
        setupConstraintsIfNeeded()
    }
    
    private func setupConstraintsIfNeeded() {
        guard FoodImageView.constraints.isEmpty else { return }
        
        FoodImageView.translatesAutoresizingMaskIntoConstraints = false
        macrosContainerStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Image fills the entire view
            FoodImageView.topAnchor.constraint(equalTo: topAnchor),
            FoodImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            FoodImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            FoodImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Macros container overlays on bottom of image
            macrosContainerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            macrosContainerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            macrosContainerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            macrosContainerStack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    // MARK: - Static Loading
    static func loadFromNib() -> FoodLogIngredientHeader {
        let bundle = Bundle(for: FoodLogIngredientHeader.self)
        let nib = UINib(nibName: "FoodLogIngredientHeader", bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? FoodLogIngredientHeader else {
            fatalError("Could not load FoodLogIngredientHeader from nib")
        }
        
        return view
    }
}
