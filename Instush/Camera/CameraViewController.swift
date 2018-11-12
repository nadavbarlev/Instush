//
//  CameraViewController.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    // MARK: Constants
    let placeholderCaption = "Write a caption..."
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.onClick(target: self, action: #selector(CameraViewController.onImageUploadClicked))
        }
    }
    @IBOutlet weak var textViewCaption: UITextView! {
        didSet {
            textViewCaption.text = placeholderCaption
            textViewCaption.textColor = UIColor.lightGray
            textViewCaption.delegate = self
        }
    }
    
    // MARK: Actions
    @IBAction func sharePost(_ sender: UIBarButtonItem) {
        
        /* Some Validations */
        guard let uploadImg = imageView.image, uploadImg != UIImage(named: "Placeholder-UplaodImg") else {
            self.showBottomToast(onView: view, withMessage: "Please choose image to share", duration: 1)
            return
        }
        guard let caption = textViewCaption.text, caption != placeholderCaption else {
            self.showBottomToast(onView: view, withMessage: "Please write a caption", duration: 1)
            return
        }
        guard let uploadImgData = uploadImg.jpegData(compressionQuality: 0.2) else {
            let errorMsg = "An error has occurred. Please try again"
            self.showBottomToast(onView: view, withMessage: errorMsg, duration: getDurationBy(messageLength: errorMsg.count))
            return
        }
        guard let userID = ServiceManager.auth.getUserID() else {
            let errorMsg = "An error has occurred. Please Sign out and Sign in again"
            self.showBottomToast(onView: view, withMessage: errorMsg, duration: getDurationBy(messageLength: errorMsg.count))
            return
        }
        
        let spinnerView = self.spinnerOn(self.view, withText: "Sharing...")
        let photoID = NSUUID().uuidString
        ServiceManager.storage.save(path: "posts", dataID: photoID, data: uploadImgData, onSuccess: { (imgUrl:URL) in
            
            /* Case: Storage - Sucesses */
            let dataToSave = ["photoURL": imgUrl.absoluteString, "caption": caption, "userID": userID]
            guard let postID = ServiceManager.database.getUniqueId(forPath: "posts") else { return }
            ServiceManager.database.setValue(path: "posts", dataID: postID, data: dataToSave) { (error: Error?) in
                
                /* Case: Storgae - Sucesses, Database - Sucesses */
                guard let errorMsg = error?.localizedDescription else {
                    self.spinnerOff(spinnerView)
                    self.showBottomToast(onView: self.view, withMessage: "Post shared successfully", duration: 1.0)
                    self.setDefaultComponentsValue()
                    return
                }
                
                /* Case: Storgae - Sucesses, Database - Failed */
                self.spinnerOff(spinnerView)
                self.showBottomToast(onView: self.view, withMessage: errorMsg, duration: self.getDurationBy(messageLength: errorMsg.count))
            }
            
        /* Case: Storage - Failed */
        }, onError: { (error: Error) in
            let errorMsg = error.localizedDescription
            self.spinnerOff(spinnerView)
            self.showBottomToast(onView: self.view, withMessage: errorMsg, duration: self.getDurationBy(messageLength: errorMsg.count))
        })
    }
    
    @IBAction func clearUI(_ sender: UIBarButtonItem) {
        self.setDefaultComponentsValue()
    }
    
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboardOnTapAround()
    }
    
    // MARK: Private Methods
    private func setDefaultComponentsValue() {
        self.imageView.image = UIImage(named: "Placeholder-UplaodImg")
        textViewCaption.text = placeholderCaption
        textViewCaption.textColor = UIColor.lightGray
    }
}

// MARK: Extension - TextView Events
extension CameraViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderCaption
            textView.textColor = UIColor.lightGray
        }
    }
}

// MARK: Extension - Image Picker Events
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @objc func onImageUploadClicked() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imgProfileSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = imgProfileSelected
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
