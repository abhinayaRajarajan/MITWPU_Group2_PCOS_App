//
//  MetricsViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class MetricsViewController: UIViewController {

    

        // MARK: - IBOutlets
        @IBOutlet weak var segmentedControl: UISegmentedControl!
        @IBOutlet weak var collectionView: UICollectionView!
        @IBOutlet weak var averageLabel: UILabel!
    
        @IBOutlet weak var gridView: ChartGridView!

        // MARK: - Dependencies (Injected)
        var goalType: GoalType!   // non-optional by design

        // MARK: - Types
        enum TimeRange {
            case day, week, month, year
        }

        // MARK: - State
        private var currentRange: TimeRange = .week
        private var values: [Int] = []

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            assert(goalType != nil, "MetricsViewController requires goalType before loading")

            setupNavigation()
            setupSegmentedControl()
            setupCollectionView()

            segmentedControl.selectedSegmentIndex = 1 // W
            currentRange = .week

            loadData()
        }

        // MARK: - Setup
        private func setupNavigation() {
            title = goalType.title
        }

        private func setupSegmentedControl() {
            // Ensure 4 segments exist
            segmentedControl.removeAllSegments()
            ["D", "W", "M", "Y"].enumerated().forEach {
                segmentedControl.insertSegment(withTitle: $0.element, at: $0.offset, animated: false)
            }

            segmentedControl.backgroundColor = .systemGray6
            segmentedControl.selectedSegmentTintColor = .white

            segmentedControl.layer.cornerRadius = 18
            segmentedControl.layer.masksToBounds = true

            let normalText: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 13, weight: .medium)
            ]

            let selectedText: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ]

            segmentedControl.setTitleTextAttributes(normalText, for: .normal)
            segmentedControl.setTitleTextAttributes(selectedText, for: .selected)
        }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(
            UINib(nibName: "StepBarCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "StepBarCell"
        )

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        collectionView.backgroundColor = .clear
        
        // Use flow layout for proper spacing
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
        }
    }

        // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {

      
            // Animate bubble transition
            animateSegmentTransition(to: sender.selectedSegmentIndex)
            
            switch sender.selectedSegmentIndex {
            case 0:
                currentRange = .day
                gridView.range = .day
            case 1:
                currentRange = .week
                gridView.range = .week
            case 2:
                currentRange = .month
                gridView.range = .month
            case 3:
                currentRange = .year
                gridView.range = .year
            default:
                break
            }
            
            loadData()
        }

        private func animateSegmentTransition(to index: Int) {
            // Create bubble view
            let bubbleView = UIView()
            bubbleView.backgroundColor = .white
            bubbleView.layer.cornerRadius = 18
            bubbleView.layer.masksToBounds = true
            
            // Calculate start and end positions
            let segmentWidth = segmentedControl.bounds.width / 4
            let startX = segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex)
            let endX = segmentWidth * CGFloat(index)
            
            bubbleView.frame = CGRect(
                x: startX,
                y: 0,
                width: segmentWidth,
                height: segmentedControl.bounds.height
            )
            
            segmentedControl.insertSubview(bubbleView, at: 0)
            
            // Animate
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                bubbleView.frame.origin.x = endX
            } completion: { _ in
                bubbleView.removeFromSuperview()
            }
        }


        // MARK: - Data
        private func loadData() {
            
                values = fetchMockData()
                updateAverage()
                
                // Animate collection view reload
                UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve) {
                    self.collectionView.reloadData()
                }
                
                // Animate grid view
                UIView.transition(with: gridView, duration: 0.3, options: .transitionCrossDissolve) {
                    self.gridView.setNeedsDisplay()
                }
            
        }

        private func updateAverage() {
            let avg = values.reduce(0, +) / max(values.count, 1)

            averageLabel.text = """
            DAILY AVERAGE
            \(avg) \(goalType.unit)
            """
            averageLabel.numberOfLines = 2
            averageLabel.textColor = .secondaryLabel
            averageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }

        private func fetchMockData() -> [Int] {
            switch currentRange {

            case .day:
                //as 180->max height of graph (collection view cell height->200
                //therefore using max height->180 for padding from above 
                // 24 hours
                return (0..<24).map { _ in Int.random(in: 0...goalType.maxValue/180*100) }

            case .week:
                // 7 days
                return (0..<7).map { _ in Int.random(in: 0...goalType.maxValue/180*100) }

            case .month:
                // 30 days
                return (0..<30).map { _ in Int.random(in: 0...goalType.maxValue/180*100) }

            case .year:
                // 12 months
                return (0..<12).map { _ in Int.random(in: 0...goalType.maxValue/180*100) }
            }
        }
    
    }

    // MARK: - UICollectionViewDataSource
    extension MetricsViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            values.count
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "StepBarCell",
                for: indexPath
            ) as! StepBarCollectionViewCell

            cell.configure(
                value: values[indexPath.item],
                maxValue: goalType.maxValue,
                color: goalType.barColor
            )

            return cell
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    extension MetricsViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {

            switch currentRange {
            case .day:
                return CGSize(width: 4, height: 180)
            case .week:
                return CGSize(width: 18, height: 180)
            case .month:
                return CGSize(width: 10, height: 180)
            case .year:
                return CGSize(width: 14, height: 180)
            }
        }

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
            return 8
        }
    

    

    

}
