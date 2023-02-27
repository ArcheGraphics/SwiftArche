//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// This script is responsible for casting rays and spherecasts
/// It is instantiated by the 'Mover' component at runtime
public class Sensor {
    /// Basic raycast parameters
    public var castLength: Float = 1
    public var sphereCastRadius: Float = 0.2

    /// Starting point of (ray-)cast
    private var origin = Vector3()

    /// Enum describing local transform axes used as directions for raycasting
    public enum CastDirection {
        case Forward
        case Right
        case Up
        case Backward
        case Left
        case Down
    }

    private var castDirection: CastDirection = .Forward

    /// Raycast hit information variables
    private var hasDetectedHit: Bool = false
    private var hitPosition = Vector3()
    private var hitNormal = Vector3()
    private var hitDistance: Float = 0
    private var hitColliders: [Entity] = []
    private var hitTransforms: [Transform] = []

    /// Backup normal used for specific edge cases when using spherecasts
    private var backupNormal = Vector3()

    /// References to attached components
    private var tr: Transform

    /// Enum describing different types of ground detection methods
    public enum CastType {
        case Raycast
        case RaycastArray
        case Spherecast
    }

    public var castType = CastType.Raycast
    public var layermask: Layer = Layer.Layer8

    /// Layer number for 'Ignore Raycast' layer
    var ignoreRaycastLayer: Layer = []

    //MARK: - Spherecast settings

    /// Cast an additional ray to get the true surface normal
    public var calculateRealSurfaceNormal = false
    /// Cast an additional ray to get the true distance to the ground
    public var calculateRealDistance = false

    //MARK: - Array raycast settings

    ///Number of rays in every row
    public var arrayRayCount: Int = 9
    ///Number of rows around the central ray
    public var ArrayRows: Int = 3
    ///Whether or not to offset every other row
    public var offsetArrayRows: Bool = false

    ///Array containing all array raycast start positions (in local coordinates)
    private var raycastArrayStartPositions: [Vector3] = []

    ///Optional list of colliders to ignore when raycasting
    private var ignoreList: [Collider] = []

    ///Array to store layers of colliders in ignore list
    private var ignoreListLayers: [Layer] = []

    ///Whether to draw debug information (hit positions, hit normals...) in the editor
    public var isInDebugMode = false

    var arrayNormals: [Vector3] = []
    var arrayPoints: [Vector3] = []

    //Constructor
    public init(_ transform: Transform, _ collider: Collider? = nil) {
        tr = transform

        if let collider = collider {
            //Add collider to ignore list
            ignoreList = [collider]

            //Store "Ignore Raycast" layer number for later
            // ignoreRaycastLayer = LayerMask.NameToLayer("Ignore Raycast")

            //Setup array to store ignore list layers
            ignoreListLayers = [Layer](repeating: [], count: ignoreList.count)
        }
    }

    //Reset all variables related to storing information on raycast hits
    private func ResetFlags() {
        hasDetectedHit = false
        hitPosition = Vector3()
        hitNormal = -GetCastDirection()
        hitDistance = 0
        hitColliders = []
        hitTransforms = []
    }

    //Returns an array containing the starting positions of all array rays (in local coordinates) based on the input arguments
    public static func GetRaycastStartPositions(sensorRows: Int, sensorRayCount: Int, offsetRows: Bool, sensorRadius: Float) -> [Vector3] {
        //Initialize list used to store the positions
        var _positions: [Vector3] = []

        //Add central start position to the list
        _positions.append(Vector3())

        for i in 0..<sensorRows {
            //Calculate radius for all positions on this row
            let _rowRadius: Float = Float(i + 1) / Float(sensorRows)

            for j in 0..<sensorRayCount * (i + 1) {
                //Calculate angle (in degrees) for this individual position
                var _angle = (Float(360) / Float(sensorRayCount * (i + 1))) * Float(j)

                //If 'offsetRows' is set to 'true', every other row is offset
                if (offsetRows && i % 2 == 0) {
                    _angle += (Float(360) / Float(sensorRayCount * (i + 1))) / Float(2)
                }
                //Combine radius and angle into one position and add it to the list
                let _x = _rowRadius * cos(MathUtil.degreeToRadFactor * _angle)
                let _y = _rowRadius * sin(MathUtil.degreeToRadFactor * _angle)

                _positions.append(Vector3(_x, 0, _y) * sensorRadius)
            }
        }
        //Convert list to array and return array
        return _positions
    }

    //Cast a ray (or sphere or array of rays) to check for colliders
    public func Cast(engine: Engine) {
        ResetFlags()

        //Calculate origin and direction of ray in world coordinates
        let _worldDirection = GetCastDirection()
        let _worldOrigin = Vector3.transformCoordinate(v: origin, m: tr.worldMatrix)

        //Check if ignore list length has been changed since last frame
        if (ignoreListLayers.count != ignoreList.count) {
            //If so, setup ignore layer array to fit new length
            ignoreListLayers = [Layer](repeating: [], count: ignoreList.count)
        }

        //(Temporarily) move all objects in ignore list to 'Ignore Raycast' layer
        for i in 0..<ignoreList.count {
            ignoreListLayers[i] = ignoreList[i].entity.layer
            ignoreList[i].entity.layer = ignoreRaycastLayer
        }

        //Depending on the chosen mode of detection, call different functions to check for colliders
        switch (castType) {
        case CastType.Raycast:
            CastRay(engine, _worldOrigin, _worldDirection)
            break
        case CastType.Spherecast:
            CastSphere(_worldOrigin, _worldDirection)
            break
        case CastType.RaycastArray:
            CastRayArray(engine, _worldOrigin, _worldDirection)
            break
        }

        //Reset collider layers in ignoreList
        for i in 0..<ignoreList.count {
            ignoreList[i].entity.layer = ignoreListLayers[i]
        }
    }

    //Cast an array of rays into '_direction' and centered around '_origin'
    private func CastRayArray(_ engine: Engine, _ _origin: Vector3, _ _direction: Vector3) {
        //Calculate origin and direction of ray in world coordinates
        var _rayStartPosition = Vector3()
        let rayDirection = GetCastDirection()

        //Clear results from last frame
        arrayNormals = []
        arrayPoints = []

        //Cast array
        for i in 0..<raycastArrayStartPositions.count {
            //Calculate ray start position
            _rayStartPosition = _origin + Vector3.transformToVec3(v: raycastArrayStartPositions[i], m: tr.worldMatrix)

            if let _hit = engine.physicsManager.raycast(Ray(origin: _rayStartPosition, direction: rayDirection),
                    distance: castLength, layerMask: layermask) {
                hitColliders.append(_hit.entity!)
                hitTransforms.append(_hit.entity!.transform)
                arrayNormals.append(_hit.normal)
                arrayPoints.append(_hit.point)
            }
        }

        //Evaluate results
        hasDetectedHit = (arrayPoints.count > 0)

        if (hasDetectedHit) {
            //Calculate average surface normal
            var _averageNormal = Vector3()
            for i in 0..<arrayNormals.count {
                _averageNormal += arrayNormals[i]
            }

            _ = _averageNormal.normalize()

            //Calculate average surface point
            var _averagePoint = Vector3()
            for i in 0..<arrayPoints.count {
                _averagePoint += arrayPoints[i]
            }

            _averagePoint /= Float(arrayPoints.count)

            hitPosition = _averagePoint
            hitNormal = _averageNormal
            hitDistance = VectorMath.extractDotVector(_origin - hitPosition, direction: _direction).length()
        }
    }

    //Cast a single ray into '_direction' from '_origin'
    private func CastRay(_ engine: Engine, _ _origin: Vector3, _ _direction: Vector3) {
        if let _hit = engine.physicsManager.raycast(Ray(origin: _origin, direction: _direction),
                distance: castLength, layerMask: layermask) {
            hitPosition = _hit.point
            hitNormal = _hit.normal

            hitColliders.append(_hit.entity!)
            hitTransforms.append(_hit.entity!.transform)

            hitDistance = _hit.distance
        }
    }

    //Cast a sphere into '_direction' from '_origin'
    private func CastSphere(_ _origin: Vector3, _ _direction: Vector3) {
    }

    //Calculate a direction in world coordinates based on the local axes of this gameobject's transform component
    func GetCastDirection() -> Vector3 {
        switch (castDirection) {
        case CastDirection.Forward:
            return tr.worldForward

        case CastDirection.Right:
            return tr.worldRight

        case CastDirection.Up:
            return tr.worldUp

        case CastDirection.Backward:
            return -tr.worldForward

        case CastDirection.Left:
            return -tr.worldRight

        case CastDirection.Down:
            return -tr.worldUp
        }
    }
}
