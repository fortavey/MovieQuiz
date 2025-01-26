//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Anton Shapoval on 26.01.2025.
//

import Foundation
import UIKit

protocol AlertPresenterProtocol {
    func show(quiz result: AlertModel) -> UIAlertController
}
