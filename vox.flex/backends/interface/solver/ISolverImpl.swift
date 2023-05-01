//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ISolverImpl {
    // MARK: - Lifecycle

    func Destroy()

    // MARK: - Inertial Frame

    func InitializeFrame(translation: Vector4, scale: Vector4, rotation: Quaternion)
    func UpdateFrame(translation: Vector4, scale: Vector4, rotation: Quaternion, deltaTime: Float)
    func ApplyFrame(worldLinearInertiaScale: Float, worldAngularInertiaScale: Float, deltaTime: Float)

    // MARK: - Particles

    func ParticleCountChanged(solver: ObiSolver)
    func SetActiveParticles(indices: [Int])
    func InterpolateDiffuseProperties(properties: [Vector4], diffusePositions: [Vector4],
                                      diffuseProperties: [Vector4], neighbourCount: [Int],
                                      diffuseCount: Int)

    // MARK: - Rigidbodies

    func SetRigidbodyArrays(solver: ObiSolver)

    // MARK: - Constraints

    func CreateConstraintsBatch(type: Oni.ConstraintType) -> IConstraintsBatchImpl
    func DestroyConstraintsBatch(batch: IConstraintsBatchImpl)
    func GetConstraintCount(type: Oni.ConstraintType) -> Int
    func GetCollisionContacts(contacts: [Oni.Contact], count: Int)
    func GetParticleCollisionContacts(contacts: [Oni.Contact], count: Int)
    func SetConstraintGroupParameters(type: Oni.ConstraintType, parameters: Oni.ConstraintParameters)

    // MARK: - Update

    func CollisionDetection(stepTime: Float)
    func Substep(stepTime: Float, substepTime: Float, substeps: Int)
    func ApplyInterpolation(startPositions: [Vector4], startOrientations: [Quaternion],
                            stepTime: Float, unsimulatedTime: Float)

    // MARK: - Simplices

    func GetDeformableTriangleCount() -> Int
    func SetDeformableTriangles(indices: [Int], num: Int, destOffset: Int)
    func RemoveDeformableTriangles(num: Int, sourceOffset: Int) -> Int

    func SetSimplices(simplices: [Int], counts: SimplexCounts)

    // MARK: - Utils

    func SetParameters(parameters: Oni.SolverParameters)
    func GetBounds(min: inout Vector3, max: inout Vector3)
    func ResetForces()
    func GetParticleGridSize() -> Int
    func GetParticleGrid(cells: [Aabb])
    func SpatialQuery(shapes: [QueryShape], transforms: [AffineTransform], results: [QueryResult])
    func ReleaseJobHandles()
}
