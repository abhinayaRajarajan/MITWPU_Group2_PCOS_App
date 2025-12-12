//
//  HomeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class HomeViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure profile button
//        let profile = UIBarButtonItem(
//            image: UIImage(systemName: "person.circle"),
//            style: .plain,
//            target: self,
//            action: #selector(addTapped)
//        )
//        navigationItem.rightBarButtonItem = profile
        
//        // Make sure LogButton is added to view and visible
//        view.addSubview(LogButton)
//        LogButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            LogButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            LogButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
    }
    
    
    @IBAction func LogButton(_ sender: Any) {
        performSegue(withIdentifier: "showSymptomLogger", sender: self)
    }
    
    
}
