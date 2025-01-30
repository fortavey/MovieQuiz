import Foundation

protocol QuestionFactoryProtocol {
    var fullMoviesResponseObject: MostPopularMovies? { get }
    
    func requestNextQuestion()
    func loadData()
}
