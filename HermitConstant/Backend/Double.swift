//
//  Double.swift
//  HermitConstant
//
//  Created by Alex Chekodanov on 12.05.2021.
//  Copyright © 2021 Alex Chekodanov. All rights reserved.
//

import Foundation

extension Double {
    func rounded(to places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
