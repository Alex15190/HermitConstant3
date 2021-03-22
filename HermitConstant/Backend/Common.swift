//
//  Common.swift
//  HermitConstant
//
//  Created by Alex Chekodanov on 15.03.2021.
//  Copyright © 2021 Alex Chekodanov. All rights reserved.
//

import Foundation
import Surge

enum ResultType {
    case positive
    case negative
    case zero
}

class Common {
    var f: Matrix<Double>
    var p: Matrix<Double>
    var d: Matrix<Double>
    var wrongVectors = [Matrix<Double>]()
    
    init(f: Matrix<Double>) {
        let dim = f.rows
        self.f = f
        d = f
        p = Matrix<Double>.eye(rows: dim, columns: dim)
    }

    func findWrongVectors() {
        let result = recConfigPD(i: 0)
        wrongVectors = generateWrongVectors(type: result.0, index: result.1)
    }
//    среда 12 20
    //MARK: Split matrix
    func recConfigPD(i: Int) -> (ResultType, Int) {
        guard i >= 0 else {
            fatalError()
        }
        if d.item(i, i) == 0 {
            d.makeSymmetrical()
            return (ResultType.zero, i)
        } else if d.item(i, i) < 0 {
            d.makeSymmetrical()
            return (ResultType.negative, i)
        } else if i == d.rows - 1 {
            d.makeSymmetrical()
            return (ResultType.positive, i)
        } else {
            diagLine(i: i)
            return recConfigPD(i: i + 1)
        }
    }

    func diagLine(i: Int) {
        for j in i + 1 ..< d.rows {
            let coof = (d.item(j, i) / d.item(i, i)) * (-1)
            d.addJtoIwithC(i: j, j: i, c: coof)
            p.addJtoIwithC(i: j, j: i, c: coof)
        }
    }

    //MARK: Find wrong vectors
    func generateWrongVectors(type: ResultType, index: Int) -> [Matrix<Double>] {
        let a = d
        let b = inv(p) //Double check this
        var vectors = [Matrix<Double>]()
        switch type {
        case .zero:
            vectors = zeroCase(a: a, b: b, index: index)
        case .negative:
            vectors = negativeCase(a: a, b: b, index: index)
        case .positive:
            vectors = positiveCase(a: a, b: b, index: index)
        }
        return vectors
    }

    func zeroCase(a: Matrix<Double>, b: Matrix<Double>, index: Int) -> [Matrix<Double>] {
        var vectors = [Matrix<Double>]()
        return vectors
    }

    func negativeCase(a: Matrix<Double>, b: Matrix<Double>, index: Int) -> [Matrix<Double>] {
        var vectors = [Matrix<Double>]()
        return vectors
    }

    func positiveCase(a: Matrix<Double>, b: Matrix<Double>, index: Int) -> [Matrix<Double>] {
        var vectors = [Matrix<Double>]()
        return vectors
    }
}
