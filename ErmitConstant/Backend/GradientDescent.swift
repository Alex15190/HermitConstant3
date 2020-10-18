//
//  GradientDescent.swift
//  ErmitConstant
//
//  Created by Alex Chekodanov on 18.10.2020.
//  Copyright © 2020 Alex Chekodanov. All rights reserved.
//

import Foundation

class GradientDescent {
    static let maxIteration = 10000
    var matrix: Matrix

    init(matrix: Matrix) {
        self.matrix = matrix
    }

    func startSearch(startPoint: ECPoint?) -> ECPoint? {
        return recFunc(startPoint ?? createFirstPoint())
    }

    func createFirstPoint() -> ECPoint {
        return ECPoint()
    }

    func nextPoint(_ currentPoint: ECPoint) -> ECPoint {
        return ECPoint()
    }

    func recFunc(_ point: ECPoint, iteration: Int = 0) -> ECPoint? {
        guard iteration < GradientDescent.maxIteration else { return nil }
        if isInPolyhedron(point) {
            return point
        } else {
            return recFunc(nextPoint(point), iteration: iteration + 1)
        }
    }

    func isInPolyhedron(_ point: ECPoint) -> Bool {
        let tmp = point.matrix.transpose() <*> matrix <*> point.matrix
        return tmp.scalar >= 1
    }
}
