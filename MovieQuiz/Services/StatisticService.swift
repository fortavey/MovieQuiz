//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Anton Shapoval on 26.01.2025.
//

import Foundation

private enum Keys: String {
    case correct
    case bestGame
    case gamesCount
}

final class StatisticService {
    private let storage: UserDefaults = .standard
}

// или реализуем протокол с помощью расширения
extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let date = storage.object(forKey: "date") ?? Date()
            let correct = storage.integer(forKey: "correct")
            let total = storage.integer(forKey: "total")
            
            return GameResult(
                correct: correct,
                total: total,
                date: date as! Date
            )
        }
        set {
            storage.set(newValue.correct, forKey: "correct")
            storage.set(bestGame.total + newValue.correct, forKey: "total")
            storage.set(Date(), forKey: "date")
        }
    }
    
    var totalAccuracy: Double {
        if bestGame.total == 0 {
            return 0
        }
        return Double(bestGame.total) / Double(gamesCount * 10) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        if count > bestGame.correct {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
    
     
}
