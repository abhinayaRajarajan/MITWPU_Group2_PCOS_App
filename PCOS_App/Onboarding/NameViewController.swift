//
//  NameViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func NextButtonTapped(_ sender: UIButton) {
    if let name = nameField.text, !name.isEmpty {
            print("Name entered: \(name)")
        
        UserDefaults.standard.set(name, forKey: "userName")
        } else {
            print("No name entered")
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
