//
//  ViewController.swift
//  CounterExample
//
//  Created by Colin Eberhardt on 04/08/2016.
//  Copyright © 2016 Colin Eberhardt. All rights reserved.
//

import UIKit
import ReSwift

class ViewController: UIViewController, StoreSubscriber {
    
    typealias StoreSubscriberStateType = AppState
    var diffCalculator: TableViewDiffCalculator<String>?
    var names: [String] = [] {
        didSet {
            self.diffCalculator?.rows = names
        }
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStore.subscribe(self)

        self.diffCalculator = TableViewDiffCalculator(tableView: self.tableView, initialRows: self.names)
    }

    func newState(state: AppState) {
        self.names = state.names
    }

    func addCounter(with name: String) {
        mainStore.dispatch(CounterActionAdd(name: name))
    }

    @IBAction func showNameInput(_ sender: Any) {
        let controller = UIAlertController(title: nil, message: "Counter name", preferredStyle: .alert)
        controller.addTextField(configurationHandler: nil)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            guard let name = controller.textFields?.first?.text else {
                return
            }
            self?.addCounter(with: name)
        }
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }

}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainStore.state.names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CounterCell", for: indexPath) as! CounterCell
        guard let counter = mainStore.state.counter(at: indexPath.row) else {
            return cell
        }
        cell.label.text = "\(counter.name): \(counter.value)"
        cell.action = { actionType in
            
            switch actionType {
            case .increase:
                mainStore.dispatch(CounterActionIncrease(name: counter.name))
            case .decrease:
                mainStore.dispatch(CounterActionDecrease(name: counter.name))
            }
        }
        
        return cell
    }
  
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let name = mainStore.state.names[indexPath.row]
        mainStore.dispatch(CounterActionRemove(name: name))
    }
  
}

