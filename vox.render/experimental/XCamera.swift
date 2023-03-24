//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

/// A Camera objec used for rendering standard perspective or parallel setups.
/// The camera object has only six writable properties:
///  `position`, `direction`, and `up` define the orientation and position of the camera
///  `nearPlane` and `farPlane` define the projection planes.
///  `viewAngle` defines the view angle in radians.
///  All other properties are generated from these values.
class XCamera {
    // Internally generated camera data used/defined by the renderer
    var _cameraParams = XCameraParams()
    // Boolean value that denotes if the internal data structure needs rebuilding
    var _cameraParamsDirty: Bool = false

    // The camera uses either perspective or parallel projection, depending on a defined angle OR a defined width.
    // Full view angle inradians for perspective view; 0 for parallel view.
    var _viewAngle: Float = 0
    // Width of back plane for parallel view; 0 for perspective view.
    var _width: Float = 0
    // Direction of the camera; is normalized.
    var _direction = Vector3()
    // Position of the camera/observer point.
    var _position = Vector3()
    // Up direction of the camera; perpendicular to _direction.
    var _up = Vector3()
    // Distance of the near plane to _position in world space.
    var _nearPlane: Float = 0
    // Distance of the far plane to _position in world space.
    var _farPlane: Float = 0
    // Aspect ratio of the horizontal against the vertical (widescreen gives < 1.0 value).
    var _aspectRatio: Float = 0
    // Offset projection (used by TAA or to stabilize cascaded shadow maps).
    var _projectionOffset = Vector2()
    // Corners of the camera frustum in world space.
    var _frustumCorners = [Vector3](repeating: Vector3(), count: 8);
}
