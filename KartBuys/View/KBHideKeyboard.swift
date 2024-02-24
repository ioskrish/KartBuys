//
//  KBHideKeyboard.swift
//  KartBuys
//
//  Created by Krishna Panchal on 06/01/24.
//
import UIKit

//Keyboard dismissal extension.
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
