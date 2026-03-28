//
//  RegisterAsViewController.swift
//  Gradmo
//
//  Created by Philanderer on 21/03/26.
//

import UIKit

final class RegisterAsViewController: UIViewController {

    @IBOutlet private weak var studentButton: UIButton!
    @IBOutlet private weak var studentTeacher: UIButton!
    @IBOutlet private weak var studentInstitute: UIButton!

    private enum RoleButtonTag {
        static let student = 1
        static let teacher = 2
        static let institute = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Setup

private extension RegisterAsViewController {

    func setupUI() {
        [studentButton, studentTeacher, studentInstitute].forEach {
            $0?.layer.cornerRadius = 12
            $0?.titleLabel?.font = UIFont.GilroySemiBold(ofSize: 16)
        }

        studentButton.tag = RoleButtonTag.student
        studentTeacher.tag = RoleButtonTag.teacher
        studentInstitute.tag = RoleButtonTag.institute
    }

    func role(for sender: UIButton) -> UserRole? {
        switch sender.tag {
        case RoleButtonTag.student:
            return .student
        case RoleButtonTag.teacher:
            return .teacher
        case RoleButtonTag.institute:
            return .institute
        default:
            return nil
        }
    }

    func continueFlow(for role: UserRole) {
        UserCache.saveSelectedUserRole(role)

        let viewController = storyboard?.instantiateViewController(
            withIdentifier: "SignupViewController"
        ) as! SignupViewController
        viewController.selectedRole = role
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Actions

extension RegisterAsViewController {

    @IBAction func studentButtonTapped(_ sender: UIButton) {
        guard let role = role(for: sender) else { return }
        continueFlow(for: role)
    }

    @IBAction func teacherButtonTapped(_ sender: UIButton) {
        guard let role = role(for: sender) else { return }
        continueFlow(for: role)
    }

    @IBAction func instituteButtonTapped(_ sender: UIButton) {
        guard let role = role(for: sender) else { return }
        continueFlow(for: role)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton!) {
        // Login entry from this screen has been removed from the onboarding flow.
    }
    
}
