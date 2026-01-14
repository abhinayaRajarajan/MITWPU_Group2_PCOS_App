//
//  WeightPickerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class WeightPickerViewController: UIViewController {
    
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    private var picker: CircularArcWeightPickerView!
    private var currentValue: Int = 70
    private var isMetric: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPicker()
        
    }
    

    private func setupPicker() {
            picker = CircularArcWeightPickerView(
                frame: containerView.bounds,
                minValue: 40,
                maxValue: 200,
                initialValue: 60
            )

            picker.delegate = self
            picker.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(picker)

            NSLayoutConstraint.activate([
                picker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                picker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                picker.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                picker.heightAnchor.constraint(equalTo: picker.widthAnchor)
            ])
        }
    
    @IBAction func unitChanged(_ sender: UISegmentedControl) {
        isMetric = sender.selectedSegmentIndex == 0
                currentValue = isMetric
                    ? Int(Double(currentValue) / 2.20462)
                    : Int(Double(currentValue) * 2.20462)

                picker.removeFromSuperview()
                setupPicker()
                updateLabel()
        }
    
    
    @IBAction func nextTapped(_ sender: UIButton) {
            // Save the weight value and move to next screen
            UserDefaults.standard.set(currentValue, forKey: "userWeight")
            UserDefaults.standard.set(isMetric, forKey: "weightIsMetric")
            
            // Navigate to next onboarding screen
            // performSegue(withIdentifier: "toNextScreen", sender: nil)
            print("Weight saved: \(currentValue) \(isMetric ? "kg" : "lbs")")
        }
        
    private func updateLabel() {
            valueLabel.text = "\(currentValue)"
        }

}

 // MARK: - RulerPickerDelegate
 extension WeightPickerViewController: CircularArcWeightPickerDelegate {
     func weightChanged(_ value: Int) {
         valueLabel.text = "\(value)"
     }
 }

protocol CircularArcWeightPickerDelegate: AnyObject {
    func weightChanged(_ value: Int)
}

class CircularArcWeightPickerView: UIView {

    weak var delegate: CircularArcWeightPickerDelegate?

    private let minValue: Int
    private let maxValue: Int
    private var currentValue: Int

    // Arc configuration
    private let startAngle: CGFloat = .pi + .pi / 6      // ~210°
    private let endAngle: CGFloat = -.pi / 6             // ~-30°
    private let tickSpacing: CGFloat = 6                 // visual density

    private var currentAngle: CGFloat = 0

    private let ticksLayer = CALayer()
    private let centerKnob = UIView()
    private let indicator = UIView()

    init(frame: CGRect, minValue: Int, maxValue: Int, initialValue: Int) {
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = initialValue
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        self.minValue = 40
        self.maxValue = 200
        self.currentValue = 60
        super.init(coder: coder)
        setup()
    }
}

private extension CircularArcWeightPickerView {

    func setup() {
        backgroundColor = .clear

        layer.addSublayer(ticksLayer)
        drawTicks()

        drawCenterKnob()
        drawIndicator()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(pan)

        setValue(currentValue)
    }

    func drawCenterKnob() {
        let size: CGFloat = 56
        centerKnob.frame = CGRect(
            x: bounds.midX - size / 2,
            y: bounds.midY - size / 2,
            width: size,
            height: size
        )
        centerKnob.backgroundColor = UIColor.systemGreen
        centerKnob.layer.cornerRadius = size / 2
        addSubview(centerKnob)
    }

    func drawIndicator() {
        indicator.frame = CGRect(
            x: bounds.midX - 1,
            y: bounds.midY - bounds.width / 2 + 14,
            width: 2,
            height: 22
        )
        indicator.backgroundColor = .label
        addSubview(indicator)
    }
    
    func drawTicks() {
            ticksLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

            let radius = bounds.width / 2 - 24
            let center = CGPoint(x: bounds.midX, y: bounds.midY)

            let totalValues = maxValue - minValue
            let angleRange = startAngle - endAngle

            for i in 0...totalValues {
                let progress = CGFloat(i) / CGFloat(totalValues)
                let angle = startAngle - progress * angleRange

                let isMajor = i % 10 == 0
                let length: CGFloat = isMajor ? 14 : 7

                let start = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )

                let end = CGPoint(
                    x: center.x + cos(angle) * (radius - length),
                    y: center.y + sin(angle) * (radius - length)
                )

                let path = UIBezierPath()
                path.move(to: start)
                path.addLine(to: end)

                let tick = CAShapeLayer()
                tick.path = path.cgPath
                tick.strokeColor = UIColor.systemGray2.cgColor
                tick.lineWidth = 2

                ticksLayer.addSublayer(tick)
            }
        }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: self)
            let center = CGPoint(x: bounds.midX, y: bounds.midY)

            let angle = atan2(location.y - center.y, location.x - center.x)

            let clamped = min(startAngle, max(endAngle, angle))
            let percent = (startAngle - clamped) / (startAngle - endAngle)

            let value = minValue + Int(round(percent * CGFloat(maxValue - minValue)))

            if value != currentValue {
                currentValue = value
                delegate?.weightChanged(value)
            }

            ticksLayer.setAffineTransform(
                CGAffineTransform(rotationAngle: clamped - startAngle)
            )
        }

        func setValue(_ value: Int) {
            let percent = CGFloat(value - minValue) / CGFloat(maxValue - minValue)
            let angle = startAngle - percent * (startAngle - endAngle)

            ticksLayer.setAffineTransform(
                CGAffineTransform(rotationAngle: angle - startAngle)
            )
        }
}
