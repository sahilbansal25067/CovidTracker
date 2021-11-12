//
//  FilterViewController.swift
//  Covid Tracker
//
//  Created by Sahil Kumar Bansal on 07/11/21.
//

import UIKit

class FilterViewController: UIViewController {
    public var completion: ((State) -> Void)?
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    private var states: [State] = []{
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select State"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        fetchStates()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didTapClose))
        // Do any additional setup after loading the view.
    }
    @objc private func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    private func fetchStates()
    {
        APICaller.shared.getStateList(completition: {[weak self] result in
            switch result{
            case .success(let states):
                self?.states = states
            case .failure(let error):
                print(error)
            }
        
        })
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }



}
extension FilterViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell",
                                                  for: indexPath)
        cell.textLabel?.text = states[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let state = states[indexPath.row]
        guard let complete = completion else {
            dismiss(animated: true, completion:  nil)
            return}
        complete(state)
        dismiss(animated: true, completion:  nil)
    }
}
