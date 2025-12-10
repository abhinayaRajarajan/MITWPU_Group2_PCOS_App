//
//  FoodLogIngredientHeader.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class FoodLogIngredientHeader: UIViewController {

    @IBOutlet weak var FoodImageView: UIImageView!
    
    @IBOutlet weak var macrosContainerStack: UIStackView!
    
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var FatsLabel: UILabel!
    @IBOutlet weak var ProteinLabel: UILabel!
    
    private var food: Food!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
           // Image view styling
           FoodImageView.contentMode = .scaleAspectFill
           FoodImageView.clipsToBounds = true
           FoodImageView.layer.cornerRadius = 12
           
           // Add glass/blur effect to macros container
           addGlassEffect(to: macrosContainerStack)
           
           // Add separators between macros
           addSeparators()
       }
       
       private func addGlassEffect(to view: UIView) {
           // Remove existing blur effect if any
           view.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
           
           // Create blur effect
           let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
           let blurView = UIVisualEffectView(effect: blurEffect)
           blurView.frame = view.bounds
           blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           blurView.layer.cornerRadius = 12
           blurView.clipsToBounds = true
           
           // Insert blur as background
           view.insertSubview(blurView, at: 0)
           
           // Make the container background clear so blur shows through
           view.backgroundColor = .clear
           
           // Optional: Add subtle border
           view.layer.borderWidth = 0.5
           view.layer.borderColor = UIColor.separator.withAlphaComponent(0.3).cgColor
           view.layer.cornerRadius = 12
       }
       
       private func addSeparators() {
           // Get the vertical stacks from the horizontal stack
           guard let arrangedSubviews = macrosContainerStack?.arrangedSubviews,
                 arrangedSubviews.count >= 4 else { return }
           
           // Create separators between each section
           // Insert at positions 1, 3, 5 (after each vertical stack)
           for i in stride(from: 1, to: 7, by: 2) {
               if i < macrosContainerStack.arrangedSubviews.count {
                   let separator = createSeparator()
                   macrosContainerStack.insertArrangedSubview(separator, at: i)
               }
           }
       }
       
       private func createSeparator() -> UIView {
           let separator = UIView()
           separator.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
           separator.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               separator.widthAnchor.constraint(equalToConstant: 1),
               separator.heightAnchor.constraint(equalToConstant: 40)
           ])
           
           return separator
       }
       
       // MARK: - Configure
       func configure(with food: Food) {
           self.food = food
           
           // Set image
           if let imageName = food.image {
               FoodImageView.image = UIImage(named: imageName)
           } else {
               FoodImageView.image = UIImage(named: "biryani")
           }
           
           // Update macros with base values (no multiplier yet)
           updateMacros()
       }
       
       private func updateMacros() {
           caloriesLabel.text = "\(Int(food.calories)) kcal"
           carbsLabel.text = "\(Int(food.carbsContent)) g"
           FatsLabel.text = "\(Int(food.fatsContent)) g"
           ProteinLabel.text = "\(Int(food.proteinContent)) g"
       }
       
       // MARK: - Static Loading
       static func loadFromNib() -> FoodLogIngredientHeader {
           let nib = UINib(nibName: "FoodLogIngredientHeader", bundle: nil)
           return nib.instantiate(withOwner: nil, options: nil).first as! FoodLogIngredientHeader
       }
}
