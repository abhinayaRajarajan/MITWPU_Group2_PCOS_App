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
    
    // Closure to pass data back
        var onFoodAdded: ((String) -> Void)?
        
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
            button.setImage(image, for: .normal)
            button.tintColor = .systemGray
            button.backgroundColor = UIColor.systemGray6
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
            button.setTitle("Done", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.setTitleColor(UIColor(hex: "fe7a96"), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            setupHeaderViews()
            updateStoryboardElementsConstraints()
            setupUI()
            setupActions()
            
            // Dismiss keyboard when tapping outside
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
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
            // Remove existing constraints and add new ones
            describeYourMealText?.translatesAutoresizingMaskIntoConstraints = false
            dietInfoLabel?.translatesAutoresizingMaskIntoConstraints = false
            addDescribedMealButton?.translatesAutoresizingMaskIntoConstraints = false
            
            // Text field constraints
            if let textField = describeYourMealText {
                NSLayoutConstraint.activate([
                    textField.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 24),
                    textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    textField.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
            
            // Info label constraints
            if let label = dietInfoLabel {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: describeYourMealText.bottomAnchor, constant: 16),
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    label.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
                ])
            }
            
            // Add button constraints
            if let button = addDescribedMealButton {
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: dietInfoLabel.bottomAnchor, constant: 20),
                    button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    button.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
        }
        
        // MARK: - Setup UI
        private func setupUI() {
            // Configure text field
            describeYourMealText?.placeholder = "1 glass Banana oat smoothie no milk, mixed nuts"
            describeYourMealText?.borderStyle = .roundedRect
            describeYourMealText?.font = UIFont.systemFont(ofSize: 16)
            describeYourMealText?.backgroundColor = .systemBackground
            
            // Configure info label (pink hint box)
            dietInfoLabel?.backgroundColor = UIColor(hex: "FFE4E1")
            dietInfoLabel?.textColor = UIColor(hex: "D8989E")
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
                        .foregroundColor: UIColor(hex: "D8989E")
                    ]
                )
                dietInfoLabel?.attributedText = attributedString
            }
            
            // Configure Add button
            addDescribedMealButton?.backgroundColor = UIColor(hex: "ADD8E6") // Light blue
            addDescribedMealButton?.setTitle("Add", for: .normal)
            addDescribedMealButton?.setTitleColor(.black, for: .normal)
            addDescribedMealButton?.layer.cornerRadius = 12
            addDescribedMealButton?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }

        // MARK: - Actions
        private func setupActions() {
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
            addDescribedMealButton?.addTarget(self, action: #selector(addMealTapped), for: .touchUpInside)
        }
        
        @objc private func dismissKeyboard() {
            view.endEditing(true)
        }

        @objc private func closeTapped() {
            print("Close button tapped") // Debug
            dismiss(animated: true, completion: nil)
        }

        @objc private func doneTapped() {
            print("Done button tapped") // Debug
            addMealTapped()
        }
        
        @objc private func addMealTapped() {
            print("Add meal button tapped") // Debug
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
