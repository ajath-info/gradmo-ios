//
//  TeacherAttendanceViewController.swift
//  Gradmo
//
//  Created by Philanderer on 06/05/26.
//

import UIKit

private struct TeacherAttendanceStudent {
    let id: Int
    let name: String
    var mark: TeacherAttendanceMark
}

class TeacherAttendanceViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchStudenttextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    private var students: [TeacherAttendanceStudent] = [
        TeacherAttendanceStudent(id: 1, name: "Aarav Mehta", mark: .unmarked),
        TeacherAttendanceStudent(id: 2, name: "Diya Shah", mark: .unmarked),
        TeacherAttendanceStudent(id: 3, name: "Ishaan Patel", mark: .unmarked),
        TeacherAttendanceStudent(id: 4, name: "Kiara Sharma", mark: .unmarked),
        TeacherAttendanceStudent(id: 5, name: "Rohan Verma", mark: .unmarked),
        TeacherAttendanceStudent(id: 6, name: "Anaya Rao", mark: .unmarked),
        TeacherAttendanceStudent(id: 7, name: "Vivaan Iyer", mark: .unmarked),
        TeacherAttendanceStudent(id: 8, name: "Myra Singh", mark: .unmarked),
        TeacherAttendanceStudent(id: 9, name: "Kabir Joshi", mark: .unmarked),
        TeacherAttendanceStudent(id: 10, name: "Saanvi Nair", mark: .unmarked)
    ]
    private var filteredStudents: [TeacherAttendanceStudent] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredStudents = students
        setupSearchField()
        setupTableView()
        saveButton.layer.cornerRadius = 12
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
}

private extension TeacherAttendanceViewController {
    func setupSearchField() {
        searchStudenttextfield.layer.cornerRadius = self.searchStudenttextfield.frame.height/2
        searchStudenttextfield.setLeftPaddingPoints(40)
        searchStudenttextfield.borderStyle = .none
        searchStudenttextfield.clipsToBounds = true
        searchStudenttextfield.delegate = self
        searchStudenttextfield.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerXib(TeacherAttendanceTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 71
        tableView.backgroundColor = .clear
    }

    @objc func searchTextChanged() {
        let query = searchStudenttextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !query.isEmpty else {
            filteredStudents = students
            tableView.reloadData()
            return
        }

        filteredStudents = students.filter {
            $0.name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
        }
        tableView.reloadData()
    }

    func updateStudentMark(studentID: Int, mark: TeacherAttendanceMark) {
        guard let studentIndex = students.firstIndex(where: { $0.id == studentID }) else { return }
        students[studentIndex].mark = mark

        if let filteredIndex = filteredStudents.firstIndex(where: { $0.id == studentID }) {
            filteredStudents[filteredIndex].mark = mark
        }
    }
}

extension TeacherAttendanceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredStudents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TeacherAttendanceTableViewCell.self),for: indexPath) as? TeacherAttendanceTableViewCell else {
            return UITableViewCell()
        }

        let student = filteredStudents[indexPath.row]
        cell.configure(
            number: indexPath.row + 1,
            studentName: student.name,
            image: UIImage(named: "student_placeholder"),
            mark: student.mark
        )
        cell.onMarkChanged = { [weak self] mark in
            self?.updateStudentMark(studentID: student.id, mark: mark)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        71
    }
}

extension TeacherAttendanceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
