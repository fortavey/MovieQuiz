//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Anton Shapoval on 02.02.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert()
    func changeBorder(isCorrect: Bool)
    func disableButtons()
    func hideIndicator()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
