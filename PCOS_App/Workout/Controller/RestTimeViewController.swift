//
//  RestTimeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 08/01/26.
//

import UIKit

class RestTimeViewController: UIViewController {

    @IBOutlet weak var RestCountdownOutlet: UILabel!
    @IBOutlet weak var RestTimeImageOutlet: UIImageView!
    var secondsRemaining: Int = 30
        var timer: Timer?

        var onRestFinished: (() -> Void)?

        override func viewDidLoad() {
            super.viewDidLoad()
            RestTimeImageOutlet.image=UIImage(named: "home_image")
            RestTimeImageOutlet.contentMode = .scaleAspectFit
            startTimer()
        }

        private func startTimer() {
            updateLabel()

            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.secondsRemaining -= 1
                self.updateLabel()

                if self.secondsRemaining <= 0 {
                    self.finishRest()
                }
            }
        }

        private func updateLabel() {
            RestCountdownOutlet.text = "Rest \(secondsRemaining)s"
        }

        @IBAction func skipTapped(_ sender: UIButton) {
            finishRest()
        }

        private func finishRest() {
            timer?.invalidate()
            dismiss(animated: true) {
                self.onRestFinished?()
            }
        }
    }
