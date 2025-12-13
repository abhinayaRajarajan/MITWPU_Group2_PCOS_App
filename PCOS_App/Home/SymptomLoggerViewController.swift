//
//  SymptomLoggerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class SymptomLoggerViewController: UIViewController {
    //var viewModel: SymptomLoggerViewModel = SymptomLoggerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Today's Symptoms"
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        let calendar = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarTapped))
//        navigationItem.rightBarButtonItem = calendar


        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

