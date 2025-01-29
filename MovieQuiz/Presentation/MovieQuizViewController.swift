import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private var questionWord: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    
    let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter()
        statisticService = StatisticService()
        
        questionFactory?.requestNextQuestion()
        
        // Присвоение правильных шрифтов для Label (косяк Xcode16)
        initFonts()
        
        // Отрисовка первого вопроса
       
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    
    // MARK: - Alert
    
    func showAlert() {
        guard let statisticService else { return }
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let df = DateFormatter()
        df.dateFormat = "dd.MM.YY hh:mm"
        
        let message = """
                Ваш результат \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(questionsAmount) (\(df.string(from: statisticService.bestGame.date)))
                Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        
        let model = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: {
                self.resetAll()
            }
        )
        
        guard let alertPresenter else { return }
        self.present(alertPresenter.show(quiz: model), animated: true, completion: nil)
    }
    
    func resetAll() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.hideBorder()
        self.questionFactory?.requestNextQuestion()
    }
    
    
    private func initFonts() {
        questionWord.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
 
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            self.showAlert()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            hideBorder()
        }
    }
    
    private func hideBorder() {
        imageView.layer.borderWidth = 0
    }
    
    private func changeBorder(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        changeBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func userAnsverHandler(userAnsver: Bool) {
        guard let currentQuestion else {return}
        let correctAnsver: Bool = currentQuestion.correctAnswer
        showAnswerResult(isCorrect: correctAnsver == userAnsver)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        userAnsverHandler(userAnsver: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        userAnsverHandler(userAnsver: false)
    }
    
}
