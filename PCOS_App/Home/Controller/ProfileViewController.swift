//
//  ProfileViewController.swift
//  PCOS_App
//
//  Created by SAYYAM JAIN on 17/12/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let section0 = ["Progress report","Medical history"]
    
    private let settings = ["Edit Profile", "Reminders", "Privacy", "Integrations", "Notifications","Help & Support"
    ]
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? section0.count : settings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileActionCell",
                for: indexPath
            )
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = section0[indexPath.row]
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SettingCell",
            for: indexPath
        )
        
        let label = cell.viewWithTag(1) as! UILabel
        label.text = settings[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "SETTINGS" : nil
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {
        
        guard section == 1,
              let header = view as? UITableViewHeaderFooterView else { return }
        
        header.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        header.textLabel?.textColor = .secondaryLabel
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 32 : 8
    }
    
    
}
