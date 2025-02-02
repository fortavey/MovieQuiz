//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Anton Shapoval on 01.02.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    var questionsAmount: Int = 10
    var correctAnswers = 0
    weak var viewController: MovieQuizViewControllerProtocol?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol = StatisticService()
    
    init(viewController: MovieQuizViewControllerProtocol) {
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        self.viewController = viewController
        viewController.showLoadingIndicator()
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        guard let viewController else { return }
        
        didAnswer(isCorrectAnswer: isCorrect)
        viewController.changeBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        
        return QuizStepViewModel(
            image: image ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isYes: Bool) {
        guard let viewController else { return }
        viewController.disableButtons()
        userAnsverHandler(userAnsver: isYes)
    }
    
    private func userAnsverHandler(userAnsver: Bool) {
        guard let currentQuestion else {return}
        let correctAnsver: Bool = currentQuestion.correctAnswer
        proceedWithAnswer(isCorrect: correctAnsver == userAnsver)
    }
    
    private func proceedToNextQuestionOrResults() {
        guard let viewController else { return }
        if self.isLastQuestion() {
            viewController.showAlert()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isCorrectAnswer isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func didLoadDataFromServer() {
        guard let questionFactory else { return }
        if questionFactory.fullMoviesResponseObject?.errorMessage != "" {
            viewController?.hideIndicator()
            viewController?.showNetworkError(message: questionFactory.fullMoviesResponseObject?.errorMessage ?? "Ошибка сервера")
        }else {
            viewController?.hideLoadingIndicator()
            questionFactory.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    func yesButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func resetAll() {
        restartGame()
        questionFactory?.requestNextQuestion()
    }
}
