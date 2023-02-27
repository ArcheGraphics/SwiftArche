//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class VectorMath {
    //Extract and return parts from a vector that are pointing in the same direction as '_direction';
    public static func extractDotVector(_ vector: Vector3, direction: Vector3) -> Vector3 {
        //Normalize vector if necessary;
        var direction = direction
        if(direction.lengthSquared() != 1) {
            direction = direction.normalize()
        }
        
        let _amount = Vector3.dot(left: vector, right: direction)
        
        return direction * _amount
    }
}
