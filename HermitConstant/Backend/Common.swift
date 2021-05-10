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

    var genVect: Matrix<Double>
    var v: Matrix<Double>
    var type: ResultType = .positive
    var history = 0.0 //for higherOneCase
    
    var vm = [Matrix<Double>]()

    init(f: Matrix<Double>) {
        let dim = f.rows
        self.f = f
        d = f
        p = Matrix<Double>.eye(rows: dim, columns: dim)
        genVect = Matrix<Double>(rows: 1, columns: dim, repeatedValue: 0)
        v = Matrix<Double>(rows: 1, columns: dim, repeatedValue: 0)
    }

    func findWrongVectors() {
        let result = recConfigPD(i: 0)
        wrongVectors = generateWrongVectors(type: result.0, index: result.1)
    }

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
        self.type = type
        switch type {
        case .zero:
            vectors = zeroCase(a: a, b: b, n: index)
        case .negative:
            vectors = negativeCase(a: a, b: b, n: index)
        case .positive:
            vectors = positiveCase(a: a, b: b, n: index)
        }
        return vectors.filter { !$0.isZero() }
    }

    func zeroCase(a: Matrix<Double>, b: Matrix<Double>, n: Int) -> [Matrix<Double>] {
        for i in n ..< a.rows {
            genVect.grid[i] = 1.0;
        }
        reverseRecGenVectorForZeroCase(d: d, p: p, n: n)
        return [genVect]
    }

    func negativeCase(a: Matrix<Double>, b: Matrix<Double>, n: Int) -> [Matrix<Double>] {
        var vectors = [Matrix<Double>]()
        let first = d.sumOfDiagonalElement(from: 0, to: n - 1) - 1 //or index - 1
        let second = -d.item(n, n) // -d[n][n];
        genVect.grid[n] = sqrt(first / second)
        for k in (0 ... n-1).reversed() {
            var temp = 0.0
            for i in k + 1 ... n {
                temp -= b.item(k, i) * genVect.grid[i]
            }
            genVect.grid[k] = temp
        }
//        for i in (0 ... n - 2).reversed() {
//            var x = 0.0
//            for k in 1 ..< n {
//                x += b.item(k, i) * genVect.grid[k]
//            }
//            genVect.grid[i] = x; //Thread 1: Fatal error: Index out of range n == 1
//        }
        vectors.append(genVect)
        return vectors
    }

    func positiveCase(a: Matrix<Double>, b: Matrix<Double>, n: Int) -> [Matrix<Double>] {
        var genVect = Matrix<Double>(rows: 1, columns: f.columns, repeatedValue: 0)
        genVect.grid[n] = abs(1.0 / a.item(n, n))
        v.grid[n] = genVect.grid[n]
        history = pow(genVect.grid[n], 2) * d.item(n, n)
        let vectors = reverseRecGenVectorForHigherZeroCase(d: d, p: p, n: n)
        return vectors
    }

    func reverseRecGenVectorForZeroCase(d: Matrix<Double>, p: Matrix<Double>, n: Int) {
        var d = d
        var p = p
        if (n > 0) {
            //востановить
            for i in n ..< d.rows {
                let coof = p.item(i, n - 1) * (-1);
                //i += j * k
                d.addJtoIwithC(i: i, j: n-1, c: coof) //или наоборот
                p.addJtoIwithC(i: i, j: n-1, c: coof) //или наоборот
            }
            d.makeSymmetrical()
            //посчитать элемент вектора n-1
            let coof = d.item(n-1, n-1)
            var xi = 0.0
            for i in n ..< d.rows {
                xi -= d.item(i, n-1) / coof;
            }
            genVect.grid[n-1] = xi
            //рекурсивный вызов
            reverseRecGenVectorForZeroCase(d: d, p: p, n: n-1)
        }
    }

    func reverseRecGenVectorForHigherZeroCase(d: Matrix<Double>, p: Matrix<Double>, n: Int) -> [Matrix<Double>] {
        if (n > 0) {
//            var vm = [Matrix<Double>]()
            var vReverce = [Int]()
            for k in (-1) * Int(genVect.grid[n]) ... Int(genVect.grid[n]) {
                vReverce.append(k)
                v.grid[n] = Double(k)
                higherZeroCaseRecFunc(d: d, p: p, n: n-1, vReverce: vReverce)
                vReverce.removeLast()
            }
//            generatedVectors = vm;
        }
        return vm
    }

    func higherZeroCaseRecFunc(d: Matrix<Double>, p: Matrix<Double>, n: Int, vReverce: [Int]) {
        var d = d
        var p = p
        var vReverce = vReverce
        if (n > 0) {
            //востановить
            for i in n+1 ..< d.rows {
                let coof = p.item(i, n) * (-1)
                d.addJtoIwithC(i: i, j: n, c: coof) //d = d.comb(i, n, coof);
                p.addJtoIwithC(i: i, j: n, c: coof) //p = p.comb(i, n, coof);
            }
            //
            d.makeSymmetrical()
            //посчитать элемент вектора n-1
            var a = 0.0;

            for i in n+1 ..< d.rows {
                a += d.item(i, n) * v.grid[i]
            }
            //
            let b = 1 - history
            let c = p.item(n, n)
            let xi = sqrt(abs(b / c)) - a

            genVect.grid[n] = abs(xi)
            let coof = d.item(n, n)
            history += coof * (pow(v.grid[n] + a, 2))
            //рекурсивный вызов
            for k in (-1) * Int(genVect.grid[n]) ... Int(genVect.grid[n]) {
                vReverce.append(k)
                v.grid[n] = Double(k)
                higherZeroCaseRecFunc(d: d, p: p, n: n - 1, vReverce: vReverce)
                vReverce.removeLast()
            }
        } else {
            for k in (-1) * Int(genVect.grid[n]) ... Int(genVect.grid[n]) {
                vReverce.append(k)
                v.grid[n] = Double(k)
                let vReverceDouble = vReverce.reversed().compactMap { Double($0) }
                vm.append(Matrix(rows: 1, columns: vReverceDouble.count, grid: vReverceDouble))
                vReverce.removeLast()
            }
        }
    }
}

extension Matrix {
    func isZero() -> Bool {
        if let grid = grid as? [Double] {
            return grid.filter({ $0 != 0 }).count == 0
        }
        return false
    }
}
