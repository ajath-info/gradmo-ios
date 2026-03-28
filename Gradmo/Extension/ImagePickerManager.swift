//
//  ImagePickerManager.swift
//  Motivaid
//
//  Created by Rishabh   on 25/11/25.
//

import UIKit
import UniformTypeIdentifiers

protocol ImagePickerManagerDelegate: AnyObject {
    func imagePickerManager(_ manager: ImagePickerManager, didPick image: UIImage, fileName: String)
    func imagePickerManagerDidCancel(_ manager: ImagePickerManager)
}

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    weak var delegate: ImagePickerManagerDelegate?
    weak var presentingVC: UIViewController?
    
    init(presentingVC: UIViewController, delegate: ImagePickerManagerDelegate) {
        self.presentingVC = presentingVC
        self.delegate = delegate
    }
    
    // MARK: - Show Picker Sheet
    func showOptions() {
        let alert = UIAlertController(title: "Upload Screenshot", message: "Choose an option", preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Files", style: .default) { _ in self.openFilePicker() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        presentingVC?.present(alert, animated: true)
    }
    
    // MARK: - Camera
     func openCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        presentingVC?.present(picker, animated: true)
    }
    
    // MARK: - Gallery
     func openGallery() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        presentingVC?.present(picker, animated: true)
    }
    
    // MARK: - Files
     func openFilePicker() {
        let types: [UTType] = [.image, .pdf, .item]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = self
        presentingVC?.present(picker, animated: true)
    }
    
    // MARK: - ImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            let fileName = "image_\(Int(Date().timeIntervalSince1970)).jpg"
            delegate?.imagePickerManager(self, didPick: image, fileName: fileName)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        delegate?.imagePickerManagerDidCancel(self)
    }
    
    // MARK: - DocumentPicker
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first,
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data)
        else { return }
        
        delegate?.imagePickerManager(self, didPick: image, fileName: url.lastPathComponent)
    }
}
