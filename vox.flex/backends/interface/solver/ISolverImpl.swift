//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math

public protocol ISolverImpl {
    // MARK: - Lifecycle

    func Destroy()

//    // MARK: - Inertial Frame
//
//    func InitializeFrame(translation: Vector4, scale: Vector4, rotation: Quaternion)
//    func UpdateFrame(translation: Vector4, scale: Vector4, rotation: Quaternion, deltaTime: Float)
//    func ApplyFrame(worldLinearInertiaScale: Float, worldAngularInertiaScale: Float, deltaTime: Float)
//
//    // MARK: - Particles
//
//    func ParticleCountChanged(solver: ObiSolver)
//    func SetActiveParticles(indices: ObiNativeIntList)
//    func InterpolateDiffuseProperties(properties: ObiNativeVector4List, diffusePositions: ObiNativeVector4List,
//                                      diffuseProperties: ObiNativeVector4List, neighbourCount: ObiNativeIntList,
//                                      diffuseCount: Int)
//
//    // MARK: - Rigidbodies
//
//    func SetRigidbodyArrays(solver: ObiSolver)
//
//    // MARK: - Constraints
//
//    func CreateConstraintsBatch(Oni.ConstraintType type) -> IConstraintsBatchImpl
//    func DestroyConstraintsBatch(batch: IConstraintsBatchImpl)
//    func GetConstraintCount(Oni.ConstraintType type) -> Int
//    func GetCollisionContacts(Oni.Contact[] contacts, int count)
//    func GetParticleCollisionContacts(Oni.Contact[] contacts, int count)
//    func SetConstraintGroupParameters(Oni.ConstraintType type, ref Oni.ConstraintParameters parameters)
//
//    // MARK: - Update
//
//    func CollisionDetection(stepTime: Float) -> IObiJobHandle
//    func Substep(stepTime: Float, substepTime: Float, substeps: Int) -> IObiJobHandle
//    func ApplyInterpolation(startPositions: ObiNativeVector4List, startOrientations: ObiNativeQuaternionList,
//                            stepTime: Float, unsimulatedTime: Float)
//
//    // MARK: - Simplices
//
//    func GetDeformableTriangleCount() -> Int
//    func SetDeformableTriangles(indices: [Int], num: Int, destOffset: Int)
//    func RemoveDeformableTriangles(num: Int, sourceOffset: Int) -> Int
//
//    func SetSimplices(simplices: ObiNativeIntList, counts: SimplexCounts)
//
//    // MARK: - Utils
//
//    func SetParameters(Oni.SolverParameters parameters)
//    func GetBounds(min: inout Vector3, max: inout Vector3)
//    func ResetForces()
//    func GetParticleGridSize() -> Int
//    func GetParticleGrid(cells: ObiNativeAabbList)
//    func SpatialQuery(shapes: ObiNativeQueryShapeList, transforms: ObiNativeAffineTransformList, results: ObiNativeQueryResultList)
//    func ReleaseJobHandles()
}
