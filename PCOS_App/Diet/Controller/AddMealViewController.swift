import UIKit

class AddMealViewController: UIViewController {
    
    // handlebar UI
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //closebutton
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = UIColor.systemGray5
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //lbel
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add meal"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //done button
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(UIColor(hex: "fe7a96"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        imageView.image = UIImage(systemName: "magnifyingglass", withConfiguration: config)
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search for food"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let micButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: "mic.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Recent", "Favorites"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.systemGray6
        control.selectedSegmentTintColor = .white
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let scanBarcodeButton: UIButton = {
        let button = createOptionButton(
            imageName: "barcode.viewfinder",
            title: "Scan Barcode"
        )
        button.tag = 1
        return button
    }()
    
    private let scanWithAIButton: UIButton = {
        let button = createOptionButton(
            imageName: "camera",
            title: "Scan with AI"
        )
        button.tag = 2
        return button
    }()
    
    private let describeMealButton: UIButton = {
        let button = createOptionButton(
            imageName: "text.bubble",
            title: "Describe Meal"
        )
        button.tag = 3
        return button
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            scanBarcodeButton,
            scanWithAIButton,
            describeMealButton
        ])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(handleBar)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
        view.addSubview(searchContainer)
        
        searchContainer.addSubview(searchIconImageView)
        searchContainer.addSubview(searchTextField)
        searchContainer.addSubview(micButton)
        
        view.addSubview(segmentedControl)
        view.addSubview(optionsStackView)
        
        handleBar.isHidden = true
        
        NSLayoutConstraint.activate([
            // Handle Bar
            handleBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            // Close Button
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 50),
            closeButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            // Done Button
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            
            optionsStackView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionsStackView.heightAnchor.constraint(equalToConstant: 110),

            searchContainer.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // Search Icon
            searchIconImageView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 12),
            searchIconImageView.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Search Text Field
            searchTextField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: micButton.leadingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            
            // Mic Button
            micButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            micButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            micButton.widthAnchor.constraint(equalToConstant: 30),
            micButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        scanBarcodeButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        scanWithAIButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        describeMealButton.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Helper Methods
    private static func createOptionButton(imageName: String, title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        
        let imageView = UIImageView(image: image)
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(imageView)
        button.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: button.topAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -8)
        ])
        
        return button
    }
    
    // MARK: - Actions
    @objc private func dismissModal() {
        dismiss(animated: true)
    }
    
    @objc private func optionButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("Scan Barcode tapped")
            // Implement barcode scanning
        case 2:
            print("Scan with AI tapped")
            // Implement AI scanning
        case 3:
            print("Describe Meal tapped")
            let describeVC = DescribeFoodViewController()
            // If this AddMealViewController is presented modally, we can push if embedded in a navigation controller
            if let nav = self.navigationController {
                nav.pushViewController(describeVC, animated: true)
            } else {
                let nav = UINavigationController(rootViewController: describeVC)
                nav.modalPresentationStyle = .automatic
                self.present(nav, animated: true)
            }
        default:
            break
        }
    }
}

// MARK: - Presentation Extension
extension AddMealViewController {
    static func present(from viewController: UIViewController) {
        let addMealVC = AddMealViewController()
        
        if let sheet = addMealVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = nil
        }
        addMealVC.isModalInPresentation = false
        
        viewController.present(addMealVC, animated: true)
    }
}

