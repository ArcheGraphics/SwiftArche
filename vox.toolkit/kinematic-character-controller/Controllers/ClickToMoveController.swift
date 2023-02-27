//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

//This controller provides basic 'click-to-move' functionality
//It can be used as a starting point for a variety of top-down (or isometric) games, which are primarily controlled via mouse input
public class ClickToMoveController: Script {
    public var OnJump: ((vox_math.Vector3) -> Void)?
    public var OnLand: ((vox_math.Vector3) -> Void)?

    //Controller movement speed
    public var movementSpeed: Float = 10
    //Downward gravity
    public var gravity: Float = 30

    var currentVerticalSpeed: Float = 0
    var isGrounded = false

    //Current position to move towards
    var currentTargetPosition = Vector3()
    //If the distance between controller and target position is smaller than this, the target is reached
    var reachTargetThreshold: Float = 0.001

    //Whether the user can hold down the mouse button to continually move the controller
    public var holdMouseButtonToMove = false

    //Whether the target position is determined by raycasting against an abstract plane or the actual level geometry
    //'AbstractPlane' is less accurate, but simpler (and will automatically ignore colliders between the camera and target position)
    //'Raycast' is more accurate, but ceilings or intersecting geometry (between camera and target position) must be handled separately
    public enum MouseDetectionType {
        case AbstractPlane
        case Raycast
    }

    public var mouseDetectionType = MouseDetectionType.AbstractPlane

    //Layermask used when 'Raycast' is selected
    public var raycastLayerMask: Layer = Layer.Everything

    //Timeout variables
    //If the controller is stuck walking against a wall, movement will be canceled if it hasn't moved at least a certain distance in a certain time
    //'timeOutTime' controls the time window during which the controller has to move (or else it stops moving)
    public var timeOutTime: Float = 1
    var currentTimeOutTime: Float = 1
    //This controls the minimum amount of distance needed to be moved (or else the controller stops moving)
    public var timeOutDistanceThreshold: Float = 0.05
    var lastPosition = Vector3()

    //Reference to the player's camera (used for raycasting)
    public var playerCamera: Camera?

    //Whether or not the controller currently has a valid target position to move towards
    var hasTarget = false

    var lastVelocity = Vector3()
    var lastMovementVelocity = Vector3()

    //Abstarct ground plane used when 'AbstractPlane' is selected
    var groundPlane: Plane!

    //Reference to attached 'Mover' and transform component
    var mover: Mover!
    var tr: Transform!

    public required init(_ entity: Entity) {
        super.init(entity)
    }

    public override func onStart() {
        //Get references to necessary components
        mover = entity.getComponent()
        tr = entity.transform

        if (playerCamera == nil) {
            logger.warning("No camera has been assigned to this controller!")
        }

        //Initialize variables
        lastPosition = tr.position
        currentTargetPosition = entity.transform.position
        groundPlane = Plane(tr.worldUp, tr.position)
    }

    public override func onUpdate(_ deltaTime: Float) {
        //Handle mouse input (check for input, determine new target position);
        HandleMouseInput()
    }

    public override func onPhysicsUpdate() {
        //Run initial mover ground check
        mover.CheckForGround()

        //Check whether the character is grounded
        isGrounded = mover.IsGrounded()

        //Handle timeout (stop controller if it is stuck)
        HandleTimeOut()

        //Calculate the final velocity for this frame
        var _velocity = CalculateMovementVelocity()
        lastMovementVelocity = _velocity

        //Calculate and apply gravity
        HandleGravity()
        _velocity += tr.worldUp * currentVerticalSpeed

        //If the character is grounded, extend ground detection sensor range
        mover.SetExtendSensorRange(isGrounded)
        //Set mover velocity
        mover.SetVelocity(_velocity)

        //Save velocity for later
        lastVelocity = _velocity
    }

    //Calculate movement velocity based on the current target position
    func CalculateMovementVelocity() -> Vector3 {
        //Return no velocity if controller currently has no target
        if (!hasTarget) {
            return Vector3()
        }
        //Calculate vector to target position
        var _toTarget = currentTargetPosition - tr.position

        //Remove all vertical parts of vector
        _toTarget = VectorMath.RemoveDotVector(_toTarget, tr.worldUp)

        //Calculate distance to target
        let _distanceToTarget = _toTarget.length()

        //If controller has already reached target position, return no velocity
        if (_distanceToTarget <= reachTargetThreshold) {
            hasTarget = false
            return Vector3()
        }

        var _velocity = _toTarget.normalized() * movementSpeed

        //Check for overshooting
        if (movementSpeed * engine.physicsManager.fixedTimeStep > _distanceToTarget) {
            _velocity = _toTarget.normalized() * _distanceToTarget
            hasTarget = false
        }

        return _velocity
    }

    //Calculate current gravity
    func HandleGravity() {
        //Handle gravity
        if (!isGrounded) {
            currentVerticalSpeed -= gravity * engine.time.deltaTime
        } else {
            if (currentVerticalSpeed < 0) {
                if let OnLand = OnLand {
                    OnLand(tr.worldUp * currentVerticalSpeed)
                }
            }

            currentVerticalSpeed = 0
        }
    }

    //Handle mouse input (mouse clicks, [...])
    func HandleMouseInput() {
        //If no camera has been assigned, stop function execution
        if (playerCamera == nil) {
            return
        }

        //If a valid mouse press has been detected, raycast to determine the new target position
        if (!holdMouseButtonToMove && WasMouseButtonJustPressed() || holdMouseButtonToMove && IsMouseButtonPressed()) {
            //Set up mouse ray (based on screen position)
            let _mouseRay = playerCamera!.screenPointToRay(GetMousePosition(), Ray())

            if (mouseDetectionType == MouseDetectionType.AbstractPlane) {
                //Set up abstract ground plane
                groundPlane.setNormalAndPosition(tr.worldUp, tr.position)

                //Raycast against ground plane
                let enter = CollisionUtil.intersectsRayAndPlane(ray: _mouseRay, plane: groundPlane)
                if enter > -1 {
                    currentTargetPosition = _mouseRay.getPoint(distance: enter)
                    hasTarget = true
                }
                else {
                    hasTarget = false
                }
            } else if (mouseDetectionType == MouseDetectionType.Raycast) {
                //Raycast against level geometry
                if let _hit = engine.physicsManager.raycast(_mouseRay, distance: 100, layerMask: raycastLayerMask) {
                    currentTargetPosition = _hit.point
                    hasTarget = true
                } else {
                    hasTarget = false
                }
            }

        }
    }

    /// Handle timeout (stop controller from moving if it is stuck against level geometry)
    func HandleTimeOut() {
        //If controller currently has no target, reset time and return
        if (!hasTarget) {
            currentTimeOutTime = 0
            return
        }

        //If controller has moved enough distance, reset time
        if (Vector3.distance(left: tr.position, right: lastPosition) > timeOutDistanceThreshold) {
            currentTimeOutTime = 0
            lastPosition = tr.position
        }
        //If controller hasn't moved a sufficient distance, increment current timeout time
        else {
            currentTimeOutTime += engine.time.deltaTime

            //If current timeout time has reached limit, stop controller from moving
            if (currentTimeOutTime >= timeOutTime) {
                hasTarget = false
            }
        }
    }

    /// Get current screen position of mouse cursor
    /// This function can be overridden to implement other input methods
    func GetMousePosition() -> Vector2 {
        return Vector2()
    }

    /// Check whether mouse button is currently pressed down
    /// This function can be overridden to implement other input methods
    func IsMouseButtonPressed() -> Bool {
        return false
    }

    /// Check whether mouse button was just pressed down
    /// This function can be overridden to implement other input methods
    func WasMouseButtonJustPressed() -> Bool {
        return false
    }
}

extension ClickToMoveController: Controller {
    public func GetVelocity() -> vox_math.Vector3 {
        lastVelocity
    }

    public func GetMovementVelocity() -> Vector3 {
        lastMovementVelocity
    }

    public func IsGrounded() -> Bool {
        isGrounded
    }
}
