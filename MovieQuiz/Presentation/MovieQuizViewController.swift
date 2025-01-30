import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    func didLoadDataFromServer() {
        guard let questionFactory else { return }
        if questionFactory.fullMoviesResponseObject?.errorMessage != "" {
            activityIndicator.isHidden = true
            showNetworkError(message: questionFactory.fullMoviesResponseObject?.errorMessage ?? "Ошибка сервера")
        }else {
            hideLoadingIndicator()
            questionFactory.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    @IBOutlet private var questionWord: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBlock: UIView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    
    let df = DateFormatter()
    
    let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter()
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory?.loadData()
                
        // Присвоение правильных шрифтов для Label (косяк Xcode16)
        initFonts()
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                showLoadingIndicator()
                questionFactory?.loadData()
            }
        
        guard let alertPresenter else { return }
        self.present(alertPresenter.show(quiz: model), animated: true, completion: nil)
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicatorBlock.isHidden = true
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
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
        self.questionFactory?.requestNextQuestion()
        self.hideBorder()
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
        hideBorder()
        enableButtons()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image)
        
        return QuizStepViewModel(
            image: image ?? UIImage(),
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
    
    private func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons()
        userAnsverHandler(userAnsver: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        userAnsverHandler(userAnsver: false)
    }
    
}
