import UIKit

// Minimal placeholder to unblock compilation. Hook up to storyboard with
// Storyboard ID: "FoodDetailViewController" in the "Diet" storyboard.
// Extend this later with your real UI.
class FoodDetailViewController: UIViewController {
    // Inputs set by the presenter
    var foodItem: InsulinFoodItem?
    var currentQuantity: Int = 0

    // Callback to return selected quantity
    var onQuantitySelected: ((Int) -> Void)?

    private let nameLabel = UILabel()
    private let quantityStepper = UIStepper()
    private let quantityLabel = UILabel()
    private let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configure(with: foodItem, quantity: currentQuantity)
    }

    private func setupUI() {
        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        quantityLabel.font = .systemFont(ofSize: 16, weight: .regular)
        quantityLabel.textAlignment = .center
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false

        quantityStepper.minimumValue = 0
        quantityStepper.maximumValue = 20
        quantityStepper.addTarget(self, action: #selector(stepperChanged(_:)), for: .valueChanged)
        quantityStepper.translatesAutoresizingMaskIntoConstraints = false

        doneButton.setTitle("Add", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameLabel)
        view.addSubview(quantityLabel)
        view.addSubview(quantityStepper)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            quantityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            quantityStepper.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 12),
            quantityStepper.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configure(with foodItem: InsulinFoodItem?, quantity: Int) {
        nameLabel.text = foodItem?.name ?? "Food"
        quantityStepper.value = Double(quantity)
        updateQuantityLabel()
    }

    @objc private func stepperChanged(_ sender: UIStepper) {
        currentQuantity = Int(sender.value)
        updateQuantityLabel()
    }

    @objc private func doneTapped() {
        onQuantitySelected?(currentQuantity)
        // Typically you'd pop or dismiss; let the presenter handle dismissal
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func updateQuantityLabel() {
        quantityLabel.text = "Quantity: \(currentQuantity)"
    }
}
