//
//  CreateHomeworkViewController.swift
//  Gradmo
//
//  Created by Philanderer on 10/05/26.
//

import UIKit

class CreateHomeworkViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var homeworkTitleTextfield: UITextField!
    @IBOutlet weak var homeworkContentTextview: UITextView!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var sendToStudentsButton: UIButton!

    var batchID: Int?
    var batchName: String?
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupUI()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton!){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendToStudentsButtonTapped(_ sender: UIButton!){
        let title = homeworkTitleTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content = homeworkContentTextview.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty else {
            showToastSafely("Enter homework heading")
            return
        }

        guard !content.isEmpty else {
            showToastSafely("Enter homework content")
            return
        }

        showToastSafely("Homework API is not connected yet")
    }

    @IBAction func browseButtonTapped(_ sender: UIButton!){
        showUploadOptions(from: sender)
    }

}

private extension CreateHomeworkViewController {
    func setupUI() {
        headerLabel.text = "Create Homework"
        homeworkTitleTextfield.placeholderSet(placeHolder: "Heading", color: .black)
        homeworkTitleTextfield.configureFormField(leftPadding: 12, rightPadding: 12)
        homeworkTitleTextfield.layer.cornerRadius = 8
        homeworkTitleTextfield.clipsToBounds = true

        homeworkContentTextview.text = ""
        homeworkContentTextview.layer.cornerRadius = 8
        homeworkContentTextview.clipsToBounds = true
        homeworkContentTextview.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        browseButton.layer.cornerRadius = 6
        browseButton.clipsToBounds = true

        sendToStudentsButton.layer.cornerRadius = 8
        sendToStudentsButton.clipsToBounds = true
    }

    func showUploadOptions(from sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }

        present(alert, animated: true)
    }

    func openGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func updateBrowseButtonSelectionState() {
        browseButton.setTitle("Image Selected", for: .normal)
    }
}

extension CreateHomeworkViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
        updateBrowseButtonSelectionState()
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
