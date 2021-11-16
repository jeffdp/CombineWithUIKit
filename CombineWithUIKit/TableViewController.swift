//
//  TableViewController.swift
//  CombineWithUIKit
//
//  Created by Jeffrey Porter on 11/15/21.
//

import UIKit
import Combine

class TableViewController: UITableViewController {
    let itemAdded = PassthroughSubject<Date, Never>()

    private var times: [Date] = []
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observer itemAdded for new times to add to the table.
        itemAdded
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] (newTime: Date) in
                self?.times.append(newTime)
                self?.tableView.reloadData()
            })
            .store(in: &subscriptions)
    }
    
    @objc func addItem() {
        // Mimic new items by directly sending them to the publisher
        itemAdded.send(Date.now)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateTableViewCell")!
        cell.textLabel?.text = "\(times[indexPath.row])"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 50
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
       headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
       
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(addItem), for: .touchUpInside)
        headerView.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return headerView
    }

}
