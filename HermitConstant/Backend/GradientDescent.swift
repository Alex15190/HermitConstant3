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
    static let fourDimMatrix = Matrix([[1.0, 0.5, -0.5, 0.5], [0.5, 1, -0.5, 0.5], [-0.5, -0.5, 1.0, 0], [0.5, 0.5, 0, 1.0]])
    static let sevenDimMatrix = Matrix(rows: 7, columns: 7, grid: [1.0, 0.5, 0.0, -0.5, 0.5, 0.0, 0.0, 0.5, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -0.5, 0.5, 0.0, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.5, 0.5, -0.5, 0.0, 1.0, 0.0, 0.5, 0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.5, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 1.0])
    static let eightDimMatrix = Matrix(rows: 8, columns: 8, grid: [1.0, 0.5, 0.0, -0.5, 0.5, 0.0, 0.0, 0.0, 0.5, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -0.5, 0.5, 0.0, 0.0, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.0, 0.5, 0.5, -0.5, 0.0, 1.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.5, 0.5, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 1.0])
    static let nineDimMatrix = Matrix(rows: 9, columns: 9, grid: [1.0, 0.5, 0.0, -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -0.5, 0.5, 0.0, 0.0, 0.0, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.5, 0.5, -0.5, 0.0, 1.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.5, 0.5, 0.25, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.0, 0.0, 1.0])
    static let tenDimMatrix = Matrix(rows: 10, columns: 10, grid: [1.0, 0.5, 0.0, -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, -0.5, 0.5, 0.0, 0.0, 0.0, 0.0, -0.5, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.5, 0.5, -0.5, 0.0, 1.0, 0.0, 0.5, 0.0, 0.0, 0.25, 0.0, 0.0, 0.5, 0.0, 0.0, 1.0, 0.5, 0.5, 0.25, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0])
    static let allFoundMatrix = [twoDimMatrix, threeDimMatrix, fourDimMatrix, sevenDimMatrix, eightDimMatrix, nineDimMatrix, tenDimMatrix]
    static let maxFoundDim = 10

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
        guard dim > 1, iteration < GradientDescent.maxIteration else {
            return nil
        }
        iteration += 1
        guard !GradientDescent.allFoundMatrix.contains(matrix) else {
            return matrix
        }
        let inPolygon = InPolygon(matrix: matrix)
        return inPolygon.findRightMatrix()
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
        case 7:
            return GradientDescent.sevenDimMatrix
        case 8:
            return GradientDescent.eightDimMatrix
        case 9:
            return GradientDescent.nineDimMatrix
        case 10:
            return GradientDescent.tenDimMatrix
        default:
            let n = dim - 1
            var firstMatrix = createFirstPoint(n)
            firstMatrix.addRowsAndColumns(dim - firstMatrix.rows, dim - firstMatrix.columns)
            return firstMatrix
        }
    }
}
