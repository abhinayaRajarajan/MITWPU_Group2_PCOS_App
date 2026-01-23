import UIKit
import AVFoundation

protocol BarcodeScannerDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: BarcodeScannerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var detectedCode: String?
    private var isScanning = false
    
    // UI Elements
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Scan", for: .normal)
        button.backgroundColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0) // #fe7a96
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 30
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
        label.text = "Position barcode within the frame"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Scanning frame overlay
    private let scanningFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0).cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupCamera()
        setupUI()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        // 1. Camera input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showError("Camera not available")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showError("Could not access camera")
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showError("Could not add camera input")
            return
        }
        
        // 2. Barcode output
        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8, .ean13, .code128, .qr,
                .upce, .code39, .code93, .pdf417
            ]
        } else {
            showError("Could not add metadata output")
            return
        }
        
        // 3. Preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // 4. Start session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func setupUI() {
        // Add UI elements on top of camera preview
        view.addSubview(scanningFrameView)
        view.addSubview(instructionLabel)
        view.addSubview(captureButton)
        view.addSubview(cancelButton)
        
        // Setup button actions
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Scanning frame in center
            scanningFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanningFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            scanningFrameView.widthAnchor.constraint(equalToConstant: 280),
            scanningFrameView.heightAnchor.constraint(equalToConstant: 200),
            
            // Instruction label above frame
            instructionLabel.bottomAnchor.constraint(equalTo: scanningFrameView.topAnchor, constant: -20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.widthAnchor.constraint(equalToConstant: 300),
            instructionLabel.heightAnchor.constraint(equalToConstant: 44),
            
            // Capture button at bottom
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 200),
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Cancel button at top right
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func captureButtonTapped() {
        guard !isScanning else { return }
        
        isScanning = true
        captureButton.isEnabled = false
        captureButton.alpha = 0.5
        instructionLabel.text = "Scanning..."
        
        // Visual feedback
        animateScanningFrame()
        
        // Give a moment for the user to position the barcode
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            // Scanning will happen automatically through the delegate
            // If nothing is detected after 3 seconds, reset
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self, self.detectedCode == nil else { return }
                self.resetScanning()
                self.showError("No barcode detected. Please try again.")
            }
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    private func animateScanningFrame() {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.repeat, .autoreverse]) {
            self.scanningFrameView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    private func stopAnimatingScanningFrame() {
        scanningFrameView.layer.removeAllAnimations()
        scanningFrameView.layer.borderColor = UIColor(red: 0.996, green: 0.478, blue: 0.588, alpha: 1.0).cgColor
    }
    
    private func resetScanning() {
        isScanning = false
        detectedCode = nil
        captureButton.isEnabled = true
        captureButton.alpha = 1.0
        instructionLabel.text = "Position barcode within the frame"
        stopAnimatingScanningFrame()
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        
        guard isScanning else { return }
        
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let code = metadataObj.stringValue {
            
            detectedCode = code
            stopAnimatingScanningFrame()
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Show confirmation alert
            showConfirmationAlert(for: code)
        }
    }
    
    private func showConfirmationAlert(for code: String) {
        let alert = UIAlertController(
            title: "Barcode Detected",
            message: "Do you want to log this item?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.delegate?.didScanBarcode(code)
            self?.dismiss(animated: true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { [weak self] _ in
            self?.resetScanning()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
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
}
