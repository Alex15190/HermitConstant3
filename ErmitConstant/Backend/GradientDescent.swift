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
    static let maxIteration = 10000
    static let twoDimMatrix = Matrix([[1.0, 0.5], [0.5, 1.0]])
    
    var matrix: Matrix<Double>

    init(matrix: Matrix<Double>) {
        self.matrix = matrix
    }

    func startSearch(dim: Int) -> Matrix<Double>? {
        return createFirstPoint(dimension: dim)
    }

    func createFirstPoint(dimension: Int) -> Matrix<Double> {
        if dimension == 2 {
            return GradientDescent.twoDimMatrix
        } else {
            let firstMatrix = createFirstPoint(dimension: dimension - 1)
            let n = dimension - 1
            //create new matrix of change firstMatrix
            return firstMatrix
            
        }
    }

    func nextPoint(_ currentPoint: Matrix<Double>) -> Matrix<Double> {
        return Matrix()
    }

    func recFunc(_ point: Matrix<Double>, iteration: Int = 0) -> Matrix<Double>? {
        guard iteration < GradientDescent.maxIteration else { return nil }
        if isInPolyhedron(point) {
            return point
        } else {
            return recFunc(nextPoint(point), iteration: iteration + 1)
        }
    }

    func isInPolyhedron(_ point: Matrix<Double>) -> Bool {
        let tmp = transpose(point) * matrix * point
        guard let det = det(tmp) else {
            return false
        }
        return det >= 1
    }
}
