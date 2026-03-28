//
//  StatePickerViewController.swift
//  Gradmo
//
//  Created by Philanderer on 18/03/26.
//

import UIKit

class StatePickerViewController: UIViewController {

    var states:[String] = []
    var filteredStates:[String] = []
    var onStateSelected: ((String) -> Void)?

    let searchBar = UISearchBar()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        filteredStates = states

        setupSearchBar()
        setupTableView()
    }

    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search State"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension StatePickerViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredStates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = filteredStates[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedState = filteredStates[indexPath.row]
        onStateSelected?(selectedState)
        dismiss(animated: true)
    }
}

extension StatePickerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            filteredStates = states
        } else {
            filteredStates = states.filter {
                $0.lowercased().contains(searchText.lowercased())
            }
        }

        tableView.reloadData()
    }
}


//MARK: - Usage (Copy and paste inside a button action)

//let vc = StatePickerViewController()
//
//vc.states = statesIndia
//
//vc.onStateSelected = { state in
//    self.state.text = state
//    self.textFieldDidChange()
//}
//
//let nav = UINavigationController(rootViewController: vc)
//present(nav, animated: true)
