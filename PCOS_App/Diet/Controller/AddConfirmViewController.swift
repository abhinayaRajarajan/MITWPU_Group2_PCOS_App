//
//  AddConfirmViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class AddConfirmViewController: UIViewController {
    
    
    @IBOutlet weak var foodWeightView: UIView!
    var food: FoodItem = FoodListdataStore.shared.loadFoodItems()[0]
    private var headerView: FoodLogIngredientHeader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderConstraints()
        setupHeader()
        
    }
    
    private func setupHeaderConstraints() {
        guard let headerContainer = foodWeightView else { return }
        
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerContainer.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    // Header setup
    private func setupHeader() {

        
        guard let containerView = foodWeightView else {
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
        
        print("DEBUG: setupHeader - Complete")
    }
    

}

