//
//  FoodScannerViewController.swift
//  PCOS_App
//
//  Created by SDC-USER
//

import UIKit
import AVFoundation
import Vision
import CoreML


protocol FoodScannerDelegate: AnyObject {
    func didScanFood(_ foodItem: FoodItem)
}

class FoodScannerViewController: UIViewController {
    
    weak var delegate: FoodScannerDelegate?
    weak var dietDelegate: AddDescribedMealDelegate?
    
    // Camera
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var capturedImage: UIImage?

    // ML Model
    private var foodClassifier: VNCoreMLModel?
    
    // UI Elements
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0)
        button.setTitle("Capture", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Position food within the frame"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scanningFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0).cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var loadingView: UIView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupMLModel()
        setupCamera()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    // MARK: - ML Model Setup
    private func setupMLModel() {
        do {
            // Load the FoodClassifier 1.mlmodel
            let config = MLModelConfiguration()
            let model = try FoodClassifier_1(configuration: config)
            foodClassifier = try VNCoreMLModel(for: model.model)
        } catch {
            print("ERROR: Failed to load ML model: \(error)")
            showError("Could not load food recognition model")
        }
    }
    
    // MARK: - Camera Setup
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            showError("Camera not available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
            
        } catch {
            showError("Could not access camera: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scanningFrameView)
        view.addSubview(instructionLabel)
        view.addSubview(captureButton)
        view.addSubview(cancelButton)
        
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scanningFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            scanningFrameView.widthAnchor.constraint(equalToConstant: 280),
            scanningFrameView.heightAnchor.constraint(equalToConstant: 280),
            
            instructionLabel.bottomAnchor.constraint(equalTo: scanningFrameView.topAnchor, constant: -20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.widthAnchor.constraint(equalToConstant: 300),
            instructionLabel.heightAnchor.constraint(equalToConstant: 44),
            
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Button Actions
    @objc private func captureButtonTapped() {
        captureButton.isEnabled = false
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Food Classification
    private func classifyFood(image: UIImage) {
        guard let ciImage = CIImage(image: image),
              let model = foodClassifier else {
            hideLoadingIndicator()
            showError("Could not process image")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("ERROR: Vision request failed: \(error)")
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    self.showError("Food recognition failed")
                }
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    self.showError("Could not identify food")
                }
                return
            }
            
            let foodName = topResult.identifier
            let confidence = topResult.confidence
            
            print("DEBUG: Identified food: \(foodName) with confidence: \(confidence)")
            
            // Only proceed if confidence is reasonable
            if confidence > 0.3 {
                Task {
                    await self.analyzeFoodWithFoundationModel(foodName: foodName)
                }
            } else {
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    self.showError("Food not recognized clearly. Please try again.")
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("ERROR: Failed to perform classification: \(error)")
                DispatchQueue.main.async {
                    self.hideLoadingIndicator()
                    self.showError("Classification failed")
                }
            }
        }
    }
    
    // MARK: - AI Model Analysis
    private func analyzeFoodWithFoundationModel(foodName: String) async {
        let instructions = """
            You are a professional nutritionist specializing in Indian and international foods.
            When given a food name, return ONLY a valid JSON object with NO extra text,
            NO markdown, NO code blocks, NO explanation — just raw JSON.

            The JSON must follow this exact structure:
            {
              "name": "food name",
              "calories": 500,
              "servingSize": 1.0,
              "unit": "serving",
              "protein": 20.5,
              "carbs": 60.0,
              "fat": 15.0,
              "desc": "brief description",
              "ingredients": [
                {
                  "name": "ingredient name",
                  "quantity": 100.0,
                  "unit": "g",
                  "protein": 5.0,
                  "carbs": 20.0,
                  "fats": 3.0,
                  "fibre": 1.0
                }
              ]
            }

            Rules:
            - All numeric values must be doubles or integers (no strings for numbers)
            - ingredients array must have at least one item
            - quantity is the ACTUAL weight of that ingredient used in this recipe in grams
              (e.g. 50g for one egg, 200g of flour, 30g of onion — realistic recipe amounts, NOT 1 or 2)
            - protein, carbs, fats, fibre in ingredients are the macros PER 100G of that ingredient
            - calories, protein, carbs, fat at the top level are for the WHOLE recipe (1 serving)
            - Provide nutritional information for a standard serving size
            - Return ONLY the JSON, nothing else
            """

        let prompt = "Provide complete nutritional breakdown for: \(foodName)"

        do {
            let responseText = try await AIBrain.shared.generateRawText(prompt: prompt, instructions: instructions)

            print("DEBUG: AI Model response:\n\(responseText)")

            await MainActor.run {
                self.hideLoadingIndicator()
                self.parseAndNavigate(json: responseText, foodName: foodName)
            }

        } catch {
            print("ERROR: AI Model failed: \(error)")
            await MainActor.run {
                self.hideLoadingIndicator()
                self.showError("AI analysis failed. Please try again.\n\nError: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseAndNavigate(json: String, foodName: String) {
        var cleaned = json.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            showError("Could not process AI response. Please try again.")
            return
        }

        do {
            let decoded = try JSONDecoder().decode(AIFoodResponse.self, from: data)

            let ingredients: [Ingredient] = decoded.ingredients.map { (raw: AIIngredient) -> Ingredient in
                Ingredient(
                    id: UUID(),
                    name: raw.name,
                    quantity: raw.quantity,
                    weight: raw.quantity,
                    unit: raw.unit,
                    protein: raw.protein,
                    carbs: raw.carbs,
                    fats: raw.fats,
                    fibre: raw.fibre,
                    tags: [.none]
                )
            }

            guard !ingredients.isEmpty else {
                showError("No ingredients found in AI response. Please try again.")
                return
            }
            
            // Normalize serving size to standard defaults
            let normalizedUnit = decoded.unit.lowercased()
            let normalizedServingSize: Double
            switch normalizedUnit {
            case "ml", "milliliter", "millilitre":
                normalizedServingSize = 100   // 100 ml
            case "piece", "pieces", "unit", "units", "pcs", "pc", "slice", "slices":
                normalizedServingSize = 1     // 1 piece
            default:
                normalizedServingSize = 100   // 100 g (default)
            }

            // Save captured image to Documents directory
            var savedImageName = "dietPlaceholder"
            if let capturedImage = self.capturedImage {
                let fileName = "food_\(UUID().uuidString).jpg"
                if let data = capturedImage.jpegData(compressionQuality: 0.7) {
                    let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let foodImagesDir = documentsDir.appendingPathComponent("FoodImages", isDirectory: true)
                    try? FileManager.default.createDirectory(at: foodImagesDir, withIntermediateDirectories: true)
                    let fileURL = foodImagesDir.appendingPathComponent(fileName)
                    try? data.write(to: fileURL)
                    savedImageName = fileName
                    print("DEBUG: Saved food image relative name: \(fileName)")
                }
            }


            let foodItem = FoodItem(
                id: Int.random(in: 100000...999999),
                name: decoded.name,
                calories: decoded.calories,
                image: savedImageName,
                servingSize: normalizedServingSize,
                unit: decoded.unit,
                protein: decoded.protein,
                carbs: decoded.carbs,
                fat: decoded.fat,
                isSelected: false,
                desc: decoded.desc,
                ingredients: ingredients
            )

            print("DEBUG: Parsed FoodItem - \(foodItem.name), \(ingredients.count) ingredients")
            
            // Show confirmation alert
            showFoodConfirmationAlert(foodItem: foodItem)

        } catch {
            print("ERROR: JSON parsing failed: \(error)")
            print("DEBUG: Raw cleaned JSON:\n\(cleaned)")
            showError("Could not parse AI response. Please try again.")
        }
    }
    
    private func showFoodConfirmationAlert(foodItem: FoodItem) {
        let alert = UIAlertController(
            title: "Food Detected",
            message: "Detected: \(foodItem.name)\n\nDo you want to log this item?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.navigateToAdd(foodItem)
        }
        
        let noAction = UIAlertAction(title: "Retake", style: .cancel) { [weak self] _ in
            self?.captureButton.isEnabled = true
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateToAdd(_ foodItem: FoodItem) {
        print("DEBUG: Navigating to AddDescribedMealViewController with \(foodItem.name)")
        
        // CRITICAL: Get the presenting VC reference BEFORE dismissing
        guard let presentingVC = self.presentingViewController else {
            print("ERROR: No presenting view controller found")
            showError("Navigation error occurred")
            return
        }
        
        let storyboard = UIStoryboard(name: "Diet", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "AddDescribedMealViewController"
        ) as? AddDescribedMealViewController else {
            print("ERROR: Could not instantiate AddDescribedMealViewController")
            showError("Could not load meal confirmation screen.")
            return
        }
        
        vc.foodItem = foodItem
        vc.delegate = dietDelegate
        
        print("DEBUG: AddDescribedMealViewController configured with delegate: \(dietDelegate != nil ? "set" : "nil")")
        print("DEBUG: Presenting VC type: \(type(of: presentingVC))")
        
        // Dismiss the scanner first
        dismiss(animated: true) {
            print("DEBUG: Scanner dismissed, now presenting AddDescribedMealViewController")
            
            // Present the AddDescribedMealViewController as a sheet
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            
            if let sheet = nav.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.selectedDetentIdentifier = .large
                }
            }
            
            presentingVC.present(nav, animated: true) {
                print("DEBUG: AddDescribedMealViewController presented successfully")
            }
        }
    }
    
    // MARK: - Loading Indicator
    private func showLoadingIndicator(message: String = "Processing...") {
        let loadingView = UIView(frame: view.bounds)
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        loadingView.tag = 999

        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = loadingView.center
        activityIndicator.color = .white
        activityIndicator.startAnimating()

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.frame = CGRect(
            x: 0,
            y: activityIndicator.frame.maxY + 20,
            width: view.bounds.width,
            height: 30
        )

        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(label)
        view.addSubview(loadingView)

        self.loadingView = loadingView
        view.isUserInteractionEnabled = false
    }

    private func hideLoadingIndicator() {
        loadingView?.removeFromSuperview()
        loadingView = nil
        view.viewWithTag(999)?.removeFromSuperview()
        view.isUserInteractionEnabled = true
        captureButton.isEnabled = true
    }
    
    // MARK: - Alert
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.captureButton.isEnabled = true
        })
        
        present(alert, animated: true)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension FoodScannerViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("ERROR: Photo capture failed: \(error)")
            showError("Failed to capture photo")
            captureButton.isEnabled = true
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            showError("Could not process captured image")
            captureButton.isEnabled = true
            return
        }
        self.capturedImage = image
        print("DEBUG: Photo captured successfully")
        showLoadingIndicator(message: "Identifying food...")
        
        // Classify the food
        classifyFood(image: image)
    }
}
