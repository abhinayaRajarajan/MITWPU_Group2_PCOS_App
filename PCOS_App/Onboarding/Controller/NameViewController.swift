//
//  NameViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.tintColor = UIColor(hex:"FE7A96")
        setupDatePicker()
    }
    

    private func setupDatePicker() {
    // Set to Wheels style
    datePicker.preferredDatePickerStyle = .wheels
    datePicker.datePickerMode = .date
    
    // Set maximum date to today (can't select future dates)
    datePicker.maximumDate = Date()
    
    // Set minimum date (e.g., 100 years ago)
    let calendar = Calendar.current
    if let minDate = calendar.date(byAdding: .year, value: -100, to: Date()) {
        datePicker.minimumDate = minDate
    }
    
    // Set default date to 25 years ago (or whatever makes sense)
    if let defaultDate = calendar.date(byAdding: .year, value: -25, to: Date()) {
        datePicker.date = defaultDate
    }
        }
    
        
    

   
    @IBAction func NextButtonTapped(_ sender: UIButton) {
        if let name = nameField.text, !name.isEmpty {
            print("Name entered: \(name)")
            
            UserDefaults.standard.set(name, forKey: "userName")
            //        } else {
            //            print("No name entered")
            //        }
            let selectedDate = datePicker.date
            
            // Format the date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            let dateString = formatter.string(from: selectedDate)
            
            print("Date of Birth: \(dateString)")
            
            // Save to UserDefaults
            UserDefaults.standard.set(selectedDate, forKey: "userDOB")
            
            // Calculate age
            let age = Calendar.current.dateComponents([.year], from: selectedDate, to: Date()).year ?? 0
            print("Age: \(age)")
        }else {
            print("No name entered")
            
            // Show alert to user
            let alert = UIAlertController(title: "No name entered",
                                        message: "Please enter your name",
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default))
            present(alert, animated: true)
        }
        
    }
    
}
/*
 UserDefaults is a simple storage system in iOS that lets you save small pieces of data permanently on the device. Think of it like a dictionary that persists even after you close the app.
 What it does:

 Saves data locally on the user's device
 Persists between app launches - data stays even if you close and reopen the app
 Easy to use for simple data types (strings, numbers, booleans, arrays, etc.)
 
 *UserDefaults.standard.set(name, forKey: "userName")

set(name, ...) - saves the value "name"
 forKey: "userName" - gives it a label/key so you can retrieve it later

 *To retrieve the data later:
 let savedName = UserDefaults.standard.string(forKey: "userName")
 print(savedName) // prints whatever name was saved
 
 *Common use cases:
 User preferences (theme, language)
 -Login status
 -Small user profile data (name, age, weight - like in your app)
 -App settings
 
 *What NOT to use it for:
-Sensitive data (passwords, tokens) - use Keychain instead
-Large amounts of data - use Core Data or files
-Complex objects - better to use Core Data or file storage
 */
