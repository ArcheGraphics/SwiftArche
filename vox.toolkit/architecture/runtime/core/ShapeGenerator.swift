//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

/// Describes each primitive ProBuilder can create by default. Pass to @"UnityEngine.ProBuilder.ShapeGenerator.CreateShape" to get a primitive with default parameters.
public enum ShapeType {
    /// Cube shape.
    case Cube
    /// Stair shape.
    case Stair
    /// Curved stairs shape.
    case CurvedStair
    /// A prism shape.
    case Prism
    /// Cylinder shape.
    case Cylinder
    /// A 10x10 plane with 2 subdivisions.
    case Plane
    /// Door shape.
    case Door
    /// Pipe shape.
    case Pipe
    /// Cone shape.
    case Cone
    /// A 1x1 quad.
    case Sprite
    /// A 180 degree arch.
    case Arch
    /// Sphere shape. Also called icosphere, or icosahedron.
    case Sphere
    /// Torus shape.
    /// - Remark:
    /// The tastiest of all shapes.
    case Torus
}

/// Functions for creating ProBuilderMesh primitives.
public class ShapeGenerator {
    static let k_IcosphereVertices: [Vector3] = [
        Vector3(-1, Math.phi, 0),
        Vector3(1, Math.phi, 0),
        Vector3(-1, -Math.phi, 0),
        Vector3(1, -Math.phi, 0),

        Vector3(0, -1, Math.phi),
        Vector3(0, 1, Math.phi),
        Vector3(0, -1, -Math.phi),
        Vector3(0, 1, -Math.phi),

        Vector3(Math.phi, 0, -1),
        Vector3(Math.phi, 0, 1),
        Vector3(-Math.phi, 0, -1),
        Vector3(-Math.phi, 0, 1)
    ]

    static let k_IcosphereTriangles: [Int] = [
        0, 11, 5,
        0, 5, 1,
        0, 1, 7,
        0, 7, 10,
        0, 10, 11,

        1, 5, 9,
        5, 11, 4,
        11, 10, 2,
        10, 7, 6,
        7, 1, 8,

        3, 9, 4,
        3, 4, 2,
        3, 2, 6,
        3, 6, 8,
        3, 8, 9,

        4, 9, 5,
        2, 4, 11,
        6, 2, 10,
        8, 6, 7,
        9, 8, 1
    ]

    /// A set of 8 vertices forming the template for a cube mesh.
    static let k_CubeVertices: [Vector3] = [
        // bottom 4 verts
        Vector3(-0.5, -0.5, 0.5), // 0
        Vector3(0.5, -0.5, 0.5), // 1
        Vector3(0.5, -0.5, -0.5), // 2
        Vector3(-0.5, -0.5, -0.5), // 3

        // top 4 verts
        Vector3(-0.5, 0.5, 0.5), // 4
        Vector3(0.5, 0.5, 0.5), // 5
        Vector3(0.5, 0.5, -0.5), // 6
        Vector3(-0.5, 0.5, -0.5)        // 7
    ]

    /// A set of triangles forming a cube with reference to the k_CubeVertices array.
    static let k_CubeTriangles: [Int] = [
        0, 1, 4, 5, 1, 2, 5, 6, 2, 3, 6, 7, 3, 0, 7, 4, 4, 5, 7, 6, 3, 2, 0, 1
    ]

    /// Create a shape with default parameters.
    /// - Parameters:
    ///   - shape: The ShapeType to create.
    ///   - pivotType: Where the shape's pivot will be.
    /// - Returns: A new GameObject with the ProBuilderMesh initialized to the primitve shape.
    public static func CreateShape(_ shape: ShapeType, engine: Engine, pivotType: PivotLocation = PivotLocation.Center) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a set of stairs.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - size: The bounds of the stairs.
    ///   - steps: How many steps does the stairset have.
    ///   - buildSides: If true, build the side and back walls. If false, only the stair top and connecting planes will be built.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateStair(engine: Engine,pivotType: PivotLocation, size: Vector3, steps: Int, buildSides: Bool) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a set of curved stairs.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - stairWidth: The width of the stair set.
    ///   - height: The height of the stair set.
    ///   - innerRadius: The radius from center to inner stair bounds.
    ///   - circumference: The amount of curvature in degrees.
    ///   - steps: How many steps this stair set contains.
    ///   - buildSides: If true, build the side and back walls. If false, only the stair top and connecting planes will be built.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateCurvedStair(engine: Engine,pivotType: PivotLocation, stairWidth: Float, height: Float, innerRadius: Float,
                                           circumference: Float, steps: Int, buildSides: Bool) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Creates a stair set with the given parameters.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - steps: How many steps should this stairwell have?
    ///   - width: How wide (in meters) should this stairset be?
    ///   - height: How tall (in meters) should this stairset be?
    ///   - depth: How deep (in meters) should this stairset be?
    ///   - sidesGoToFloor: If true, stair step sides will extend to the floor.  If false, sides will only extend as low as the stair is high.
    ///   - generateBack: If true, a back face to the stairwell will be appended.
    ///   - platformsOnly: If true, only the front face and tops of the stairwell will be built.  Nice for when a staircase is embedded between geometry.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    internal static func GenerateStair(engine: Engine,pivotType: PivotLocation, steps: Int, width: Float, height: Float, depth: Float,
                                       sidesGoToFloor: Bool, generateBack: Bool, platformsOnly: Bool) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new cube with the specified size. Size is baked (ie, not applied as a scale value in the transform).
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - size: The bounds of the new cube.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateCube(engine: Engine,pivotType: PivotLocation, size: Vector3) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Creates a cylinder pb_Object with the supplied parameters.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - axisDivisions: How many divisions to create on the vertical axis.  Larger values = smoother surface.
    ///   - radius: The radius in world units.
    ///   - height: The height of this object in world units.
    ///   - heightCuts: The amount of divisions to create on the horizontal axis.
    ///   - smoothing: smoothing
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateCylinder(engine: Engine,pivotType: PivotLocation, axisDivisions: Int,
                                        radius: Float, height: Float, heightCuts: Int, smoothing: Int = -1) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new prism primitive.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - size: Scale to apply to the shape.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GeneratePrism(engine: Engine,pivotType: PivotLocation, size: Vector3) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a door shape suitable for placement in a wall structure.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - totalWidth: The total width of the door
    ///   - totalHeight: The total height of the door
    ///   - ledgeHeight: The height between the top of the door frame and top of the object
    ///   - legWidth: The width of each leg on both sides of the door
    ///   - depth: The distance between the front and back faces of the door object
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateDoor(engine: Engine,pivotType: PivotLocation, totalWidth: Float, totalHeight: Float,
                                    ledgeHeight: Float, legWidth: Float, depth: Float) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new plane shape.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - width: Plane width.
    ///   - height: Plane height.
    ///   - widthCuts: Divisions on the X axis.
    ///   - heightCuts: Divisions on the Y axis.
    ///   - axis: The axis to build the plane on. Ex: ProBuilder.Axis.Up is a plane with a normal of Vector3.up.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GeneratePlane(engine: Engine,pivotType: PivotLocation, width: Float, height: Float,
                                     widthCuts: Int, heightCuts: Int, axis: Axis) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new pipe shape.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - radius: Radius of the generated pipe.
    ///   - height: Height of the generated pipe.
    ///   - thickness: How thick the walls will be.
    ///   - subdivAxis: How many subdivisions on the axis.
    ///   - subdivHeight: How many subdivisions on the Y axis.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GeneratePipe(engine: Engine,pivotType: PivotLocation, radius: Float, height: Float,
                                    thickness: Float, subdivAxis: Int, subdivHeight: Int) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new cone shape.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - radius: Radius of the generated cone.
    ///   - height: How tall the cone will be.
    ///   - subdivAxis: How many subdivisions on the axis.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateCone(engine: Engine,pivotType: PivotLocation,
                                    radius: Float, height: Float, subdivAxis: Int) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new arch shape.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - angle: Amount of a circle the arch takes up.
    ///   - radius: Distance from origin to furthest extent of geometry.
    ///   - width: Distance from arch top to inner radius.
    ///   - depth: Depth of arch blocks.
    ///   - radialCuts: How many blocks compose the arch.
    ///   - insideFaces: Render inside faces toggle.
    ///   - outsideFaces: Render outside faces toggle.
    ///   - frontFaces: Render front faces toggle.
    ///   - backFaces: Render back faces toggle.
    ///   - endCaps: If true the faces capping the ends of this arch will be included. Does not apply if radius is 360 degrees.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateArch(engine: Engine,pivotType: PivotLocation, angle: Float, radius: Float, width: Float, depth: Float,
                                    radialCuts: Int, insideFaces: Bool, outsideFaces: Bool,
                                    frontFaces: Bool, backFaces: Bool, endCaps: Bool) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    /// Create a new icosphere shape.
    /// - Remark:
    /// This method does not build UVs, so after generating BoxProject for UVs.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - radius: The radius of the sphere.
    ///   - subdivisions: How many subdivisions to perform.
    ///   - weldVertices: If false this function will not extract shared indexes. This is useful when showing a preview, where speed of generation is more important than making the shape editable.
    ///   - manualUvs: For performance reasons faces on icospheres are marked as manual UVs. Pass false to this parameter to force auto unwrapped UVs
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateIcosahedron(engine: Engine,pivotType: PivotLocation, radius: Float, subdivisions: Int,
                                           weldVertices: Bool = true, manualUvs: Bool = true) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

    // Subdivides a set of vertices (wound as individual triangles) on an icosphere.
    //
    //   /\          /\
    //      /  \    ->      /--\
    // /____\      /_\/_\
    //
    static func SubdivideIcosahedron(vertices: [Vector3], radius: Float) -> [Vector3] {
        []
    }

    static func GetCirclePoints(segments: Int, radius: Float, circumference: Float, rotation: Quaternion, offset: Float) -> [Vector3] {
        []
    }

    /// Create a torus mesh.
    /// - Parameters:
    ///   - pivotType: Where the shape's pivot will be.
    ///   - rows: The number of horizontal divisions.
    ///   - columns: The number of vertical divisions.
    ///   - innerRadius: The distance from center to the inner bound of geometry.
    ///   - outerRadius: The distance from center to the outer bound of geometry.
    ///   - smooth: True marks all faces as one smoothing group, false does not.
    ///   - horizontalCircumference: The circumference of the horizontal in degrees.
    ///   - verticalCircumference: The circumference of the vertical geometry in degrees.
    ///   - manualUvs: A torus shape does not unwrap textures well using automatic UVs. To disable this feature and instead use manual UVs, pass true.
    /// - Returns: A new GameObject with a reference to the ProBuilderMesh component.
    public static func GenerateTorus(engine: Engine,pivotType: PivotLocation, rows: Int, columns: Int,
                                     innerRadius: Float, outerRadius: Float, smooth: Bool,
                                     horizontalCircumference: Float, verticalCircumference: Float, manualUvs: Bool = false) -> ProBuilderMesh {
        let entity = Entity(engine)
        return entity.addComponent(ProBuilderMesh.self)
    }

}
