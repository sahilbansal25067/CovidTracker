//
//  ViewController.swift
//  Covid Tracker
//
//  Created by Sahil Kumar Bansal on 07/11/21.
//

import UIKit
import Charts
/// Data of covid cases
class ViewController: UIViewController {
//    static let numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.locale = .current
//        return formatter
//    }()
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private var dayData : [DayData] = []{
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.createGraph()
                self.loader.isHidden = true
                self.tableView.isHidden =  false
            }
        }
    }
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        return loader
    }()
    private var scope: APICaller.DataScope = .national
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Covid Cases"
        configureTable()
        view.addSubview(loader)
        loader.isHidden = true
        createFilterButton()
        fetchData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        loader.frame = CGRect(x: 0, y: view.frame.size.height/2 - 10, width: view.frame.size.width, height: 20)
    }
    private func createGraph()
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        headerView.clipsToBounds = true
        var entries : [BarChartDataEntry] = []
        let set = dayData.prefix(10)
        for index in 0..<set.count{
            let data = set[index]
            entries.append(.init(x: Double(index), y: Double(data.count)))
        }
        let dataSet = BarChartDataSet(entries: entries)
        let data = BarChartData(dataSet: dataSet)
        dataSet.colors = ChartColorTemplates.joyful()
        let chart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width/1.5))
        chart.data = data
        headerView.addSubview(chart)
        tableView.tableHeaderView = headerView
    }
    private func configureTable()
    {
        view.addSubview(tableView)
        tableView.dataSource = self
    }
    private func fetchData(){
        loader.isHidden = false
        tableView.isHidden = true
        APICaller.shared.getCovidData(for: scope, completition: {[weak self] result in
            switch result{
            case .success(let dayData):
                self?.dayData = dayData
            case .failure(let error):
                print(error)
            }
        })
    }
    private func createFilterButton(){
        let buttonTitle: String = {
            switch scope{
            case .national: return "National"
            case .state(let state): return state.name
            }
        }()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonTitle,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapFilter))
    }
    @objc private func didTapFilter()
    {
        let vc = FilterViewController()
        vc.completion = {[weak self]
            state in
            self?.scope = .state(state)
            self?.fetchData()
            self?.createFilterButton()
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dayData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = createText(with: dayData[indexPath.row])
        return cell
    }
    func createText(with data : DayData) -> String
    {
        let dateString = DateFormatter.prettyFormatter.string(from: data.date)
        return "\(dateString):\(data.count)"
    }
}

