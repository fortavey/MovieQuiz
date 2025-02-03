import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var questionWord: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorBlock: UIView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private var presenter: MovieQuizPresenter?
    private let df = DateFormatter()
    private var alertPresenter: AlertPresenterProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter()

        startApp()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked(sender)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked(sender)
    }
    
    private func startApp() {
        showLoadingIndicator()
        initFonts()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
    }
    
    private func initFonts() {
        questionWord.font = UIFont(name: "YSDisplay-Medium", size: 20)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    private func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    func hideIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                
                presenter?.restartGame()
                showLoadingIndicator()
                presenter?.questionFactory?.loadData()
            }
        
        guard let alertPresenter else { return }
        self.present(alertPresenter.show(quiz: model), animated: true, completion: nil)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicatorBlock.isHidden = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // MARK: - Alert
    
    func showAlert() {
        guard let presenter else { return }
        presenter.statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        df.dateFormat = "dd.MM.YY hh:mm"
        
        let message = """
                Ваш результат \(presenter.correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(presenter.statisticService.gamesCount)
                Рекорд: \(presenter.statisticService.bestGame.correct)/\(presenter.questionsAmount) (\(df.string(from: presenter.statisticService.bestGame.date)))
                Средняя точность: \(String(format: "%.2f", presenter.statisticService.totalAccuracy))%
            """
        
        let model = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: {
                self.presenter?.resetAll()
            }
        )
        
        guard let alertPresenter else { return }
        self.present(alertPresenter.show(quiz: model), animated: true, completion: nil)
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        hideBorder()
        enableButtons()
    }
    
    func hideBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func changeBorder(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    
    func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func resetAll() {
        guard let presenter else { return }
        presenter.resetAll()
        hideBorder()
    }
}
