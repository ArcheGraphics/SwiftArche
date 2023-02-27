//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

/// This is a static helper class that offers various methods for calculating and modifying vectors (as well as float values)
public class VectorMath {
    //Calculate signed angle (ranging from -180 to +180) between '_vector_1' and '_vector_2'
    public static func GetAngle(_ _vector1: Vector3, _ _vector2: Vector3, _ _planeNormal: Vector3) -> Float {
        //Calculate angle and sign
        let _angle = Vector3.angle(from: _vector1, to: _vector2)
        let _sign = Vector3.dot(left: _planeNormal, right: Vector3.cross(left: _vector1, right: _vector2)).sign

        //Combine angle and sign
        let _signedAngle = _angle * Float(_sign.rawValue)

        return _signedAngle
    }

    //Returns the length of the part of a vector that points in the same direction as '_direction' (i.e., the dot product)
    public static func GetDotProduct(_ _vector: Vector3, _ _direction: Vector3) -> Float {
        var _direction = _direction
        //Normalize vector if necessary
        if (_direction.lengthSquared() != 1) {
            _ = _direction.normalize()
        }

        return Vector3.dot(left: _vector, right: _direction)
    }

    //Remove all parts from a vector that are pointing in the same direction as '_direction'
    public static func RemoveDotVector(_ _vector: Vector3, _ _direction: Vector3) -> Vector3 {
        var _vector = _vector
        var _direction = _direction
        //Normalize vector if necessary
        if (_direction.lengthSquared() != 1) {
            _ = _direction.normalize()
        }

        let _amount = Vector3.dot(left: _vector, right: _direction)

        _vector -= _direction * _amount

        return _vector
    }

    /// Extract and return parts from a vector that are pointing in the same direction as '_direction'
    public static func extractDotVector(_ vector: Vector3, direction: Vector3) -> Vector3 {
        //Normalize vector if necessary
        var direction = direction
        if (direction.lengthSquared() != 1) {
            direction = direction.normalize()
        }

        let _amount = Vector3.dot(left: vector, right: direction)

        return direction * _amount
    }

    /// Rotate a vector onto a plane defined by '_planeNormal'
    public static func RotateVectorOntoPlane(_ _vector: Vector3, _ _planeNormal: Vector3, _ _upDirection: Vector3) -> Vector3 {
        //Calculate rotation
        let _rotation = Quaternion.shortestRotation(from: _upDirection, target: _planeNormal)

        //Apply rotation to vector
        return Vector3.transformByQuat(v: _vector, quaternion: _rotation)
    }

    /// Project a point onto a line defined by '_lineStartPosition' and '_lineDirection'
    public static func ProjectPointOntoLine(_ _lineStartPosition: Vector3, _ _lineDirection: Vector3, _ _point: Vector3) -> Vector3 {
        //Caclculate vector pointing from '_lineStartPosition' to '_point'
        let _projectLine = _point - _lineStartPosition

        let dotProduct = Vector3.dot(left: _projectLine, right: _lineDirection)

        return _lineStartPosition + _lineDirection * dotProduct
    }

    /// Increments a vector toward a target vector, using '_speed' and '_deltaTime'
    public static func IncrementVectorTowardTargetVector(_ _currentVector: Vector3, _ _speed: Float,
                                                         _ _deltaTime: Float, _ _targetVector: Vector3) -> Vector3 {
        return Vector3.moveTowards(current: _currentVector, target: _targetVector,
                                   maxDistanceDelta: _speed * _deltaTime)
    }
}
