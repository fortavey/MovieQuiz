//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Anton Shapoval on 26.01.2025.
//

import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func show(quiz result: AlertModel) -> UIAlertController {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            result.completion()
        }
        alert.addAction(action)
        
        return alert
    }
}
