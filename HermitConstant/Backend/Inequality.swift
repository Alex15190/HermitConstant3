//
//  Inequality.swift
//  HermitConstant
//
//  Created by Alex Chekodanov on 26.05.2021.
//  Copyright © 2021 Alex Chekodanov. All rights reserved.
//

import Foundation
import Surge

class Inequality {
    var matrix: Matrix<Double>
    var alphaRow: Int
    var alphaColumn: Int
    var lowerBound = -10000.0
    var upperBound = 10000.0
    var genVectors = [[Double]]()

    init(matrix: Matrix<Double>, row: Int, column: Int) {
        self.matrix = matrix
        self.alphaRow = row
        self.alphaColumn = column
    }

    func generateVectors() {
        recGenVect(n: matrix.rows, arr: [])
    }

    func recGenVect(n: Int, arr: [Double]) {
        var arr = arr
        let range = 2 //Для n <= 8 используй range == 1
        if n > 0 {
            for i in -range ... range {
                arr.append(Double(i))
                recGenVect(n: n - 1, arr: arr)
                arr.removeLast()
            }
        } else {
            genVectors.append(arr)
        }
    }

    func findBounds() {
        generateVectors()
        genVectors.forEach { vect in
            guard vect.count == matrix.rows else { return }
            if let result = calcAlpha(vect: vect) {
                if result.isPositive {
                    if result.alpha > lowerBound {
                        lowerBound = result.alpha
                    }
                } else {
                    if result.alpha < upperBound {
                        upperBound = result.alpha
                    }
                }
            }
            
        }
    }

    func calcAlpha(vect: [Double]) -> (alpha: Double, isPositive: Bool)? {
        var leftSide = 0.0
        var rightSide = 1.0
        for row in 0 ..< matrix.rows {
            for column in row ..< matrix.columns {
                if row == column {
                    rightSide -= vect[row] * vect[row]
                } else if (row == alphaRow && column == alphaColumn) || (row == alphaColumn && column == alphaRow) {
                    leftSide += 2 * (vect[row] * vect[column] + matrix.item(row, column))
                } else {
                    rightSide -= 2 * matrix.item(row, column) * vect[row] * vect[column]
                }
            }
        }
        guard leftSide != 0 else { return nil }
        let isPositive = leftSide >= 0
        let alpha = rightSide / leftSide
        return (alpha, isPositive)
    }
}
