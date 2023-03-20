//
//  ViewController.swift
//  TG Stat
//
//  Created by Oleg Stepanov on 17.03.2023.
//

import UIKit
import UniformTypeIdentifiers
import Charts

protocol StatsViewControllerInputProtocol {
    func didPreparedData(with barChartData: BarChartData, names: [String], count: Int)
    func didPreparedData(with topWords: [(String, Int)], names: [String])
    func setLoadingState(_ isLoading: Bool)
    func showSegmentedControl()
}

class StatsViewController: UIViewController {
    
    private lazy var button: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Select File", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: Stats.allCases.map { $0.description })
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.isHidden = true
        segmentedControl.addTarget(self, action: #selector(statChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private var barChart: BarChartView = BarChartView()
    private var bubbleView: BubbleView = BubbleView()
    private lazy var loadingView: LoadingView = LoadingView()
    
    private let viewModel = StatsViewModel()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.frame = view.bounds
        loadingView.center = view.center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewInput = self
        setupView()
        setupChart()
    }
    
    private func makeFilePicker() -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.json])
        picker.allowsMultipleSelection = false
        picker.delegate = self
        return picker
    }
    
    private func setupView() {
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        
        view.addSubviews([button, barChart, bubbleView, segmentedControl, loadingView])
        bubbleView.isHidden = true
        
        barChart.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            barChart.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            barChart.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            barChart.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            barChart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            bubbleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupChart() {
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.labelRotationAngle = -45
        barChart.rightAxis.enabled = false
        barChart.leftAxis.setLabelCount(8, force: true)
        barChart.leftAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMaximum = 20000
        barChart.legend.enabled = false
        barChart.setExtraOffsets(left: 10, top: 0, right: 0, bottom: 50)
    }
    
    @objc
    private func openPicker() {
        present(makeFilePicker(), animated: true)
    }
    
    @objc
    private func statChanged() {
        setLoadingState(true)
        viewModel.selectedStat = Stats(rawValue: segmentedControl.selectedSegmentIndex + 1) ?? .senders
        Task {
            await viewModel.makeStats()
        }
    }
    
    private func toggleCharts(barChartIsHidden: Bool) {
        barChart.isHidden = barChartIsHidden
        bubbleView.isHidden = !barChartIsHidden
    }
    
    private func createAndDisplayBubbles(topWords: [(String, Int)]) {
        let bubblePositions = bubbleView.circlePacking(bubbles: topWords, frame: bubbleView.bounds)
        let totalWordsCount = topWords.reduce(0) { $0 + $1.1 }
        
        for (index, (word, count)) in topWords.enumerated() {
            let position = bubblePositions[index]
            let radius = bubbleView.calculateRelativeBubbleRadius(wordCount: count, totalWordsCount: totalWordsCount, frame: bubbleView.bounds, topWords: topWords)
            
            let bubbleFrame = CGRect(x: position.x - radius, y: position.y - radius, width: radius * 2, height: radius * 2)
            let bubble = UILabel(frame: bubbleFrame)
            bubble.textAlignment = .center
            bubble.text = "\(word)\n(\(count))"
            bubble.numberOfLines = 2
            
            // Адаптируйте размер шрифта в зависимости от радиуса пузыря
            bubble.font = UIFont.systemFont(ofSize: radius / 3)
            
            bubble.layer.cornerRadius = radius
            bubble.layer.masksToBounds = true
            bubble.layer.borderWidth = 1.0
            bubble.layer.borderColor = UIColor.black.cgColor
            
            // Примените случайный цвет для каждого пузыря
            let backgroundColor: UIColor = .randomColor()
            bubble.backgroundColor = backgroundColor
            
            // Установите цвет текста с хорошим контрастом по отношению к фону
            bubble.textColor = backgroundColor.isLight() ? .black : .white
            
            bubbleView.addSubview(bubble)
        }
    }

}

extension StatsViewController: StatsViewControllerInputProtocol {
    func didPreparedData(with topWords: [(String, Int)], names: [String]) {
        setLoadingState(false)
        toggleCharts(barChartIsHidden: true)
        bubbleView.removeAllSubviews()
        createAndDisplayBubbles(topWords: topWords)
    }
    
    func didPreparedData(with barChartData: BarChartData, names: [String], count: Int) {
        setLoadingState(false)
        toggleCharts(barChartIsHidden: false)
        
        barChart.xAxis.setLabelCount(count, force: false)
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: names)
        barChart.xAxis.axisMaximum = Double(count)
        barChart.data = barChartData
    }
    
    func setLoadingState(_ isLoading: Bool) {
        loadingView.setLoadingState(isLoading)
    }
    
    func showSegmentedControl() {
        segmentedControl.isHidden = false
    }
}

extension StatsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            do {
                setLoadingState(true)
                guard url.startAccessingSecurityScopedResource() else { return }
                let data = try Data(contentsOf: url)
                viewModel.processWithData(data: data)
            } catch let error as NSError {
                print(error.description)
                setLoadingState(false)
            }
        }
    }
}

extension StatsViewController: ChartViewDelegate { }
