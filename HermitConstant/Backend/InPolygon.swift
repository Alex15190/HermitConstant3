//
//  InPolygon.swift
//  HermitConstant
//
//  Created by Alex Chekodanov on 19.04.2021.
//  Copyright © 2021 Alex Chekodanov. All rights reserved.
//

import Foundation
import Surge

class InPolygon {
    static let nonZeroElements = 2
    static let maxIterations = 1000000
    static let minAlpha = 0.5 * 0.5 * 0.5 * 0.5 * 0.5 * 0.5 * 0.5
    var iteration = 1
    var matrix: Matrix<Double>
    var genVectors = [[Int]]()
    var generatedMatrix = [Matrix<Double>]()
    var alpha = 0.5
    var isPositive: Bool {
        return alpha >= 0
    }
    var dim: Int {
        return matrix.rows
    }

    init(matrix: Matrix<Double>) {
        self.matrix = matrix
    }
    
    func recGenMatrix(n: Int, nonZeroItems: Int, arr: [Double]) {
        var arr = arr
        if n > 0 {
            if (n > nonZeroItems) {
                arr.append(0)
                recGenMatrix(n: n-1, nonZeroItems: nonZeroItems, arr: arr)
                arr.removeLast()
            }

            if (nonZeroItems > 0) {
                arr.append(-1)
                recGenMatrix(n: n-1, nonZeroItems: nonZeroItems-1, arr: arr)
                arr.removeLast()

                arr.append(1)
                recGenMatrix(n: n-1, nonZeroItems: nonZeroItems-1, arr: arr)
                arr.removeLast()
            }
        } else {
            let newMatrix = makeMatrixWithGrid(arr: arr)
            generatedMatrix.append(newMatrix)
        }
    }

    func generateMatrix() {
        generatedMatrix = []
        let n = ((dim-1) * dim / 2)
        recGenMatrix(n: n, nonZeroItems: InPolygon.nonZeroElements, arr: [])
    }

    
    func generateVectors() {
        recGenVect(n: 2, dim: matrix.rows, arr: [])
    }

    func recGenVect(n: Int, dim: Int, arr: [Int]) {
        var arr = arr
        if n > 0 {
            let lowPoint = arr.count == 0 ? 3 : 0
            for i in lowPoint ..< dim {
                if let last = arr.last {
                    if last == i {
                        continue
                    } else if last > i {
                        arr.append(i)
                        recGenVect(n: n - 1, dim: dim, arr: arr)
                        arr.removeLast()
                    }
                } else if arr.count == 0 {
                    arr.append(i)
                    recGenVect(n: n - 1, dim: dim, arr: arr)
                    arr.removeLast()
                }
            }
        } else {
            genVectors.append(arr)
        }
    }
    
    
    func findRightMatrix() -> Matrix<Double> {
        generateVectors()
//        genVectors = [[3, 0], [3, 1], [3, 2]]
        genVectors.forEach { vector in
            guard vector.count == 2 else { return }
            let row = vector[0]
            let column = vector[1]
            let inequality = Inequality(matrix: matrix, row: row, column: column)
            inequality.findBounds()
            var lowerBoundMatr = Matrix(rows: matrix.rows, columns: matrix.columns, grid: matrix.grid)
            var upperBoundMatr = Matrix(rows: matrix.rows, columns: matrix.columns, grid: matrix.grid)
            lowerBoundMatr.addAlphaTo(alpha: inequality.lowerBound, row, column)
            upperBoundMatr.addAlphaTo(alpha: inequality.upperBound, row, column)
            guard let matrixDet = det(matrix), let lowDet = det(lowerBoundMatr), let upDet = det(upperBoundMatr) else { return }
            if lowDet < upDet, lowDet < matrixDet, lowDet > 0 {
                matrix = lowerBoundMatr
            } else if upDet < matrixDet, upDet > 0 {
                matrix = upperBoundMatr
            } else {
                print("Can't go any further")
            }
        }
        
        
        
//        generateMatrix()
//        generatedMatrix.reversed().forEach { direction in
//            while (fabs(alpha) >= InPolygon.minAlpha) {
//                let newMatrix = makeNewMatrix(direction, alpha: alpha)
//                if (det(matrix) ?? 0 > det(newMatrix) ?? 0) {
//                    let common = Common(f: newMatrix)
//                    common.findWrongVectors()
//                    if (common.wrongVectors.count == 0), newMatrix.multOfDiagonalElements() != 0 {
//                        if common.type == .negative {
//                            if isPositive {
//                                alpha *= -1
//                            } else {
//                                alpha *= -1
//                                alpha *= 0.5
//                            }
//                            continue //TODO: Remove it! Added because inifinite adding to the matrix
//                        }
//                        matrix = newMatrix
//                        debugPrint("New matrix is: \n")
//                        debugPrint(newMatrix)
//                        debugPrint("Det = \(det(newMatrix) ?? 0.0)")
//                        continue
//                    } else {
//                        if isPositive {
//                            alpha *= -1
//                        } else {
//                            alpha *= -1
//                            alpha *= 0.5
//                        }
//                        continue
//                    }
//                } else {
//                    if isPositive {
//                        alpha *= -1
//                    } else {
//                        alpha *= -1
//                        alpha *= 0.5
//                    }
//                }
//            }
//            alpha = 0.5
//        }
        print("Matrix det = \(det(matrix))")
        return matrix
    }
    
    func makeNewMatrix(_ a: Matrix<Double>, alpha: Double) -> Matrix<Double> {
        return mult(a, alpha: alpha) + matrix
    }

    func makeMatrixWithGrid(arr: [Double]) -> Matrix<Double> {
        var grid = [Double]()
        var index = 0
        for i in 0 ..< dim * dim {
            let column = i % dim
            let row = i / dim
            if column > row {
                grid.append(arr[index])
                index += 1
            } else if column < row {
                let newIndex = row + column * dim
                grid.append(grid[newIndex])
            } else {
                grid.append(0)
            }
        }
        let newMatrix = Matrix(rows: dim, columns: dim, grid: grid)
        return newMatrix
    }
}

extension InPolygon {
    func mult(_ matrix: Matrix<Double>, alpha: Double) -> Matrix<Double> {
        let newGrid = matrix.grid.compactMap { $0 * alpha }
        return Matrix(rows: dim, columns: dim, grid: newGrid)
    }
}
