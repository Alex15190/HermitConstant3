//
//  GradientDescent.swift
//  ErmitConstant
//
//  Created by Alex Chekodanov on 18.10.2020.
//  Copyright © 2020 Alex Chekodanov. All rights reserved.
//

import Foundation
import Surge

class GradientDescent {
    static let maxIteration = 1000
    static let twoDimMatrix = Matrix([[1.0, 0.5], [0.5, 1.0]])
    static let threeDimMatrix = Matrix([[1.0, 0.5, -0.5], [0.5, 1.0, -0.5], [-0.5, -0.5, 1]])
    static let fourDimMatrix = Matrix([[1.0, 0.5], [0.5, 1.0]])
    static let allFoundMatrix = [twoDimMatrix, threeDimMatrix, fourDimMatrix]

    var dim: Int
    var matrix: Matrix<Double>
    var yArray: [Matrix<Double>] = []
    private var iteration = 0

    init(dim: Int) {
        self.dim = dim
        matrix = GradientDescent.twoDimMatrix
        matrix = createFirstPoint(dim)
    }

    func findMatrix() -> Matrix<Double>? {
        guard iteration < GradientDescent.maxIteration else {
            return nil
        }
        iteration += 1
        guard !GradientDescent.allFoundMatrix.contains(matrix), let y = findWrongVector() else {
            return matrix
        }
        yArray.append(contentsOf: y)
        y.forEach { y in
            matrix = transpose(y) * matrix * y //+ det((transpose(y) * y))^2
        }
        return findMatrix()
    }
    
    private func findWrongVector() -> [Matrix<Double>]? {
        return [matrix]
    }

    private func createFirstPoint(_ dim: Int) -> Matrix<Double> {
        guard dim > 1 else {
            debugPrint("dim should be > 1")
            return GradientDescent.twoDimMatrix
        }
        switch dim {
        case 2:
            return GradientDescent.twoDimMatrix
        case 3:
            return GradientDescent.threeDimMatrix
        case 4:
            return GradientDescent.fourDimMatrix
        default:
            let n = dim - 1
            let firstMatrix = createFirstPoint(n)
            //create new matrix of change firstMatrix
            return firstMatrix
        }
    }
}