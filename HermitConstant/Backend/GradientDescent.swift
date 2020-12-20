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
//    static let fourDimMatrix = Matrix([[1.0, 0.5], [0.5, 1.0]])
    static let allFoundMatrix = [twoDimMatrix, threeDimMatrix]

    var dim: Int
    let lambda = 0.001
    var matrix: Matrix<Double>
    var yArray: [Matrix<Double>] = []
    private var iteration = 0
    
    var MAXN: Int {
        return dim * (dim - 1) / 2
    }
//    double a[MAXN]; //used to generate matrix
//    double zeroArr[MAXN];
    var generatedVectors = [Matrix<Double>]() // that x^T F x < 1
    var genVect = [Double]()
    var v = [Double]()

    //todo create recursive generate vector for > 0 case
    var history = 0.0 //for higherOneCase

    init(dim: Int) {
        self.dim = dim
        matrix = GradientDescent.twoDimMatrix
        matrix = createFirstPoint(dim)
    }

    func findMatrix() -> Matrix<Double>? {
        guard dim > 1 else {
            return nil
        }
        guard iteration < GradientDescent.maxIteration else {
            iteration = 0
            return matrix
        }
        iteration += 1
        guard !GradientDescent.allFoundMatrix.contains(matrix),
              let y = findWrongVector(),
              let firstY = y.first else {
            return matrix
        }
        yArray.append(contentsOf: y)
        let coof = (transpose(firstY) * firstY)[0, 0]
        matrix = addNum(matr: matrix, lambda * coof)
        return findMatrix()
    }
    
    private func findWrongVector() -> [Matrix<Double>]? {
        return nil
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
//        case 4:
//            return GradientDescent.fourDimMatrix
        default:
            let n = dim - 1
            let firstMatrix = createFirstPoint(n)
            var newMatrixArray = [Double]()
            firstMatrix.array.enumerated().forEach { (index, item) in
                newMatrixArray.append(item)
                if (index + 1) % firstMatrix.rows == 0 {
                    newMatrixArray.append(0)
                    if index + 1 == firstMatrix.array.count {
                        for i in 0 ..< dim {
                            let value = i == dim - 1 ? 1.0 : 0
                            newMatrixArray.append(value)
                        }
                    }
                }
            }
            let newMatrix = Matrix(rows: dim, columns: dim, grid: newMatrixArray)
            return newMatrix
        }
    }
}

extension GradientDescent { //Cpp functions
    func generateVectorsFor(_ f: Matrix<Double>) {
//        generatedVectors.clear();
//        Matrix e = Matrix(N, zeroArr);
        let e = Matrix(rows: dim, columns: dim, repeatedValue: 0)
        let isNeededGenVect = recGenerateVectors(f, e, 0)
        //create vertor/vectors from int to Matrix
        if isNeededGenVect {
//            std::cout << "Is needed to generate vectors" << endl;
            if (!isAllZeros()) {
                //clear zeros and
                //generatedVectors = generateVector();
            } else {
                return
            }
        } else {
            var vect = [Double]()
            for i in 0 ..< dim {
                vect.append(Double(genVect[i]))
            }
            generatedVectors.append(Matrix(vect: vect))
        }
    }
    
    func recGenerateVectors(_ d: Matrix<Double> , _ p: Matrix<Double> , _ n: Int ) -> Bool {
        var d = d
        var p = p
        if (d[n][n] > 0) {
            if (n < d.rows - 1) {
                //преобразования....
                for i in n+1 ..< d.rows {
                    let coof = (d[i][n] / d[n][n]) * (-1)
                    d.comb(i, n, coof)
                    p.comb(i, n, coof)
                }
                //
                d.updateDiagonalMatrix()
                return recGenerateVectors(d, p, n + 1)
            } else {
                genVect[n] = abs(1 / Double(d[n][n]))
                v[n] = genVect[n]
                //cout << "1 / (double)d[n][n] = " << 1 / (double)d[n][n] << " v["<< n << "] = " << v[n] << endl;
                history = pow(genVect[n], 2) * d[n][n]
                reverceRecGenVectorForHigherZeroCase(d: d, p: p, n: n)
                return true
            }
        } else if d[n][n] == 0 {
            for i in n ..< d.rows {
                genVect[i] = 1
            }
            reverseRecGenVectorForZeroCase(d: d, p: p, n: n)
            return false
        } else {
            let first = sumOfDiagonalElements(d, n - 1)
            let second = -d[n][n]
            let b = p′
            genVect[n] = sqrt(first / second)
            
            for i in (0 ... n-2).reversed() {
                var x = 0.0
                for k in 1 ..< n {
                    x += b[k][i] * genVect[k]
                }
                genVect[i] = x
            }
            //found solution
            return false
        }
    }

    func isAllZeros() -> Bool {
        var result = true
        genVect.forEach {
            if $0 != 0 {
                result = false
                return
            }
        }
        return result
    }
    
    func sumOfDiagonalElements(_ f: Matrix<Double> , _ n: Int) -> Double {
        var counter = 0.0
        for i in 0 ..< n {
            counter += f[i][i]
        }
        return counter
    }

    func reverseRecGenVectorForZeroCase(d: Matrix<Double>, p: Matrix<Double> , n: Int) {
        var d = d
        var p = p
        if (n > 0) {
            //востановить
            for i in n ..< d.rows {
                let coof = p[i][n - 1] * (-1)
                d.comb(i, n - 1, coof)
                p.comb(i, n - 1, coof)
            }
            d.updateDiagonalMatrix()
            //посчитать элемент вектора n-1
            let coof = d[n - 1][n - 1]
            var xi = 0.0
            for i in n ..< d.rows {
                xi -= d[i][n - 1] / coof
            }
            genVect[n - 1] = xi
            //рекурсивный вызов
            reverseRecGenVectorForZeroCase(d: d, p: p, n: n-1)
        }
    }

    func higherZeroCaseRecFunc(d: Matrix<Double>, p: Matrix<Double>, n: Int, vReverce: [Int], vm: inout [Matrix<Double>]) {
        var d = d
        var p = p
        var vReverce = vReverce
        let intGenVect = Int(genVect[n])
        if (n > 0) {
            //востановить
            //cout << "d.size - n-1 = " << d.size() - n - 1 << endl;
            //cout << "d" << endl << d << endl;
            //cout << "p" << endl << p << endl;
            //bad?
            for i in n + 1 ..< d.rows {
                let coof = p[i][n] * (-1)
                d.comb(i, n, coof)
                p.comb(i, n, coof)
            }
            //

            d.updateDiagonalMatrix()
            //посчитать элемент вектора n-1

            //
            //cout << "d new" << endl << d << endl;
            //cout << "p new" << endl << p << endl;
            var a = 0.0 //bad

            for i in n + 1 ..< d.rows {
                a += d[i][n] * Double(v[i])
            }
            //
            let b = 1 - history
            let c = p[n][n] //bad?
            let xi = sqrt(abs(b / c)) - a
            //cout << "history = " << history << endl;
            //cout << "xi = " << xi << endl;
            genVect[n] = abs(xi)
            let coof = d[n][n]
            history += coof * (pow(Double(v[n]) + a, 2))
            //рекурсивный вызов
            for k in (-1) * intGenVect ... intGenVect {
                vReverce.append(k)
                v[n] = Double(k)
                //cout << "if (n > 0) k = " << k << ", v[" << n << "] = " << v[n] << endl;
                higherZeroCaseRecFunc(d: d, p: p, n: n-1, vReverce: vReverce, vm: &vm)
                vReverce.removeLast()
            }
        } else {
            for k in (-1) * intGenVect ... intGenVect {
                vReverce.append(Int(Double(k)))
                v[n] = Double(k);
                //cout << "else k = " << k << ", v[" << n << "] = " << v[n] << endl;
                vReverce.reverse()
                vm.append(Matrix(vect: vReverce.compactMap { Double($0) }))
                vReverce.removeLast()
            }
        }
    }

    func reverceRecGenVectorForHigherZeroCase(d: Matrix<Double>, p: Matrix<Double>, n: Int) {
        //TODO: Create a recursive generate vector
        let intGenVect = Int(genVect[n])
        if (n > 0) {
            var vm = [Matrix<Double>]()
            var vReverce = [Int]()
            for k in (-1) * intGenVect ... intGenVect {
                vReverce.append(k)
                v[n] = Double(k)
                //cout << "vm k = " << k << ", v[" << n << "] = " << v[n] << endl;
                higherZeroCaseRecFunc(d: d, p: p, n: n-1, vReverce: vReverce, vm: &vm)
                vReverce.removeLast()
            }
            generatedVectors = vm;
        }
    }
    
    
    func addNum(matr: Matrix<Double>, _ x: Double) -> Matrix<Double> {
        let numMatr = Matrix(rows: dim, columns: dim, repeatedValue: x)
        return add(matr, numMatr)
    }
}

extension Matrix {
    init(vect: [Scalar]) {
        self.init(rows: vect.count, columns: 1, grid: vect)
    }

    mutating func comb(_ x: Int, _ y: Int, _ k: Scalar) {
        for i in 0 ..< columns {
            self[x, i] += k * self[y, i]
        }
    }
    
    mutating func updateDiagonalMatrix() {
        for i in 0 ..< columns {
            for j in 0 ... i {
                if (i != j) {
                    self[j, i] = self[i, j]
                }
            }
        }
    }
}
