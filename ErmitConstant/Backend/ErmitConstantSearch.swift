//
//  ErmitConstantSearch.swift
//  ErmitConstant
//
//  Created by Alex Chekodanov on 18.10.2020.
//  Copyright © 2020 Alex Chekodanov. All rights reserved.
//

import Foundation

class ErmitConstantSearch {
    static let maxIteration = 10000
    static let maxInPolIteration = 10000
    var matrix = 0

    init(matrix: Int) {
        self.matrix = matrix
    }

    func startSearch(startPoint: ECPoint?) -> ECPoint? {
        if let result = recFunc(startPoint ?? createFirstPoint()) {
            return searchInPolyhedron(startPoint: result)
        } else {
            return nil
        }
    }

    func searchInPolyhedron(startPoint: ECPoint) -> ECPoint?  {
        return recFuncInPol(startPoint)
    }

    func createFirstPoint() -> ECPoint {
        return ECPoint()
    }

    func nextPoint(_ currentPoint: ECPoint) -> ECPoint {
        return ECPoint()
    }

    func recFunc(_ point: ECPoint, iteration: Int = 0) -> ECPoint? {
        guard iteration < ErmitConstantSearch.maxIteration else { return nil }
        if isInPolyhedron(point) {
            return point
        } else {
            return recFunc(nextPoint(point), iteration: iteration + 1)
        }
    }

    func recFuncInPol(_ point: ECPoint, iteration: Int = 0) -> ECPoint? {
        guard iteration < ErmitConstantSearch.maxInPolIteration else { return nil }
        if isOnTheBorder(point) {
            return point
        } else {
            return recFuncInPol(nextPointInPol(point), iteration: iteration + 1)
        }
    }

    func isInPolyhedron(_ point: ECPoint) -> Bool {
        return false
    }

    func isOnTheBorder(_ point: ECPoint) -> Bool {
        return false
    }

    func nextPointInPol(_ currentPoint: ECPoint) -> ECPoint {
        //find new point
        var newPoint = currentPoint
        if !isInPolyhedron(newPoint) {
            //use other method
        }
        return newPoint
    }
}

class ECPoint {
    var matrix = Matrix(rows: 1, columns: 2, repeatedValue: 0)

    init() {
        matrix = Matrix(rows: 1, columns: 2, repeatedValue: 0)
    }

    init(_ array: Array<Double>) {
        matrix = Matrix(rows: 1, columns: array.count, grid: array)
    }
}
