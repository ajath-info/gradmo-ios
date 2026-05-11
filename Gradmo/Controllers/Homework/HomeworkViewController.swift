//
//  HomeworkViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/05/26.
//

import UIKit

class HomeworkViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createNewHomeworkButton: UIButton!

    var batchID: Int?
    var batchName: String?
    var homeworkItems: [HomeworkItem] = HomeworkItem.samples

    private var isTeacherFlow: Bool {
        UserCache.getUserRole() == .teacher
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createNewHomeworkButtonTapped(_ sender: UIButton!){
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let createHomeworkViewController = storyboard.instantiateViewController(
            withIdentifier: "CreateHomeworkViewController"
        ) as? CreateHomeworkViewController else {
            return
        }

        createHomeworkViewController.batchID = batchID
        createHomeworkViewController.batchName = batchName
        createHomeworkViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(createHomeworkViewController, animated: true)
    }

}

private extension HomeworkViewController {
    func setupUI() {
        headerLabel.text = "Homework"
        createNewHomeworkButton.isHidden = !isTeacherFlow
        createNewHomeworkButton.layer.cornerRadius = 8
        createNewHomeworkButton.clipsToBounds = true
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerXib(HomeworkTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 119
    }

    func openHomeworkDetail(for item: HomeworkItem) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Home", bundle: nil)
        guard let homeworkDetailViewController = storyboard.instantiateViewController(
            withIdentifier: "HomeworkDetailViewController"
        ) as? HomeworkDetailViewController else {
            return
        }

        homeworkDetailViewController.homeworkItem = item
        homeworkDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(homeworkDetailViewController, animated: true)
    }
}

extension HomeworkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeworkItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: HomeworkTableViewCell.self),
            for: indexPath
        ) as? HomeworkTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: homeworkItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openHomeworkDetail(for: homeworkItems[indexPath.row])
    }
}
