//
//  Extensions.swift
//  Instush
//
//  Created by Nadav Bar Lev on 05/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import UIKit
import Foundation
import Toast_Swift

// MARK: Keyboard
extension UIViewController {
    
    func dismissKeyboardOnTapAround() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func registerKeyboardNotifications(willShowSelector: Selector, willHideSelector: Selector)
    {
        NotificationCenter.default.addObserver(self, selector: willShowSelector, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: willHideSelector, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: Spinner
extension UIViewController {
    
    func spinnerOn(_ onView: UIView, withText text: String) -> UIView {
        let viewWithSpinner = UIView.init(frame: onView.bounds)
        viewWithSpinner.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7)
        
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator.center = viewWithSpinner.center
        activityIndicator.startAnimating()
        
        let labelMsg = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        labelMsg.text = text
        labelMsg.font = .systemFont(ofSize: 18, weight: .medium)
        labelMsg.textColor = UIColor(white: 1, alpha: 0.9)
        labelMsg.center = viewWithSpinner.center
        labelMsg.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.async {
            viewWithSpinner.addSubview(activityIndicator)
            viewWithSpinner.addSubview(labelMsg)
            labelMsg.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 8.0).isActive = true
            labelMsg.centerXAnchor.constraint(equalTo: viewWithSpinner.centerXAnchor, constant: 0).isActive = true
            onView.addSubview(viewWithSpinner)
        }
 
        return viewWithSpinner
    }
    
    func spinnerOff(_ spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

// MARK: Toasts
extension UIViewController {

    var toastStyle: ToastStyle {
        var style = ToastStyle()
        style.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
        style.messageColor = .white
        style.messageAlignment = .center
        return style
    }
    
    func showTopToast(onView view: UIView, withMessage message: String) {
        let estimatedDuration = getDurationBy(messageLength: message.count)
        let duration = estimatedDuration > 1.0 ? estimatedDuration : 1.0
        view.makeToast(message, duration: duration, position: .top, style: toastStyle)
    }
    
    func showBottomToast(onView view: UIView, withMessage message: String) {
        let estimatedDuration = getDurationBy(messageLength: message.count)
        let duration = estimatedDuration > 1.0 ? estimatedDuration : 1.0
        view.makeToast(message, duration: duration, position: .bottom, style: toastStyle)
    }
    
    func showCenterToast(onView view: UIView, withMessage message: String) {
        let estimatedDuration = getDurationBy(messageLength: message.count)
        let duration = estimatedDuration > 1.0 ? estimatedDuration : 1.0
        view.makeToast(message, duration: duration, position: .center, style: toastStyle)
    }
    
    func getDurationBy(messageLength length: Int) -> Double {
        return Double(length) * 0.04
    }
}
