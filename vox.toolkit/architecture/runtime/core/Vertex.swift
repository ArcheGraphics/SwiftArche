//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import vox_math

/// Holds information about a single vertex, and provides methods for averaging between many.
/// - Remark: All values are optional. Where not present a default value will be substituted if necessary.
public final class Vertex {
    lazy var m_Position = Vector3()
    lazy var m_Color = Color()
    lazy var m_Normal = Vector3()
    lazy var m_Tangent = Vector4()
    lazy var m_UV0 = Vector2()
    lazy var m_UV2 = Vector2()
    lazy var m_UV3 = Vector4()
    lazy var m_UV4 = Vector4()
    lazy var m_Attributes: Attributes = Position

    /// The position in model space.
    public var position: Vector3 {
        get {
            m_Position
        }
        set {
            hasPosition = true
            m_Position = newValue
        }
    }

    /// Vertex color.
    public var color: Color {
        get {
            m_Color
        }
        set {
            hasColor = true
            m_Color = newValue
        }
    }

    /// Unit vector normal.
    public var normal: Vector3 {
        get {
            m_Normal
        }
        set {
            hasNormal = true
            m_Normal = newValue
        }
    }

    /// Vertex tangent (sometimes called binormal).
    public var tangent: Vector4 {
        get {
            m_Tangent
        }
        set {
            hasTangent = true
            m_Tangent = newValue
        }
    }

    /// UV 0 channel. Also called textures.
    public var uv0: Vector2 {
        get {
            return m_UV0
        }
        set {
            hasUV0 = true
            m_UV0 = newValue
        }
    }

    /// UV 2 channel.
    public var uv2: Vector2 {
        get {
            m_UV2
        }
        set {
            hasUV2 = true
            m_UV2 = newValue
        }
    }

    /// UV 3 channel.
    public var uv3: Vector4 {
        get {
            m_UV3
        }
        set {
            hasUV3 = true
            m_UV3 = newValue
        }
    }

    /// UV 4 channel.
    public var uv4: Vector4 {
        get {
            return m_UV4
        }
        set {
            hasUV4 = true
            m_UV4 = newValue
        }
    }

    internal var attributes: Attributes {
        get {
            m_Attributes
        }
    }

    /// Find if a vertex attribute has been set.
    /// - Parameter attribute: The attribute or attributes to test for.
    /// - Returns: True if this vertex has the specified attributes set, false if they are default values.
    public func HasArrays(attribute: Attributes) -> Bool {
        return (m_Attributes.rawValue & attribute.rawValue) == attribute.rawValue
    }

    var hasPosition: Bool {
        get {
            return (m_Attributes.rawValue & Position.rawValue) == Position.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | Position.rawValue) : (m_Attributes.rawValue & ~(Position.rawValue)))
        }
    }

    var hasColor: Bool {
        get {
            return (m_Attributes.rawValue & Color_0.rawValue) == Color_0.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | Color_0.rawValue) : (m_Attributes.rawValue & ~(Color_0.rawValue)))
        }
    }

    var hasNormal: Bool {
        get {
            return (m_Attributes.rawValue & Normal.rawValue) == Normal.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | Normal.rawValue) : (m_Attributes.rawValue & ~(Normal.rawValue)))
        }
    }

    var hasTangent: Bool {
        get {
            return (m_Attributes.rawValue & Tangent.rawValue) == Tangent.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | Tangent.rawValue) : (m_Attributes.rawValue & ~(Tangent.rawValue)))
        }
    }

    var hasUV0: Bool {
        get {
            return (m_Attributes.rawValue & UV_0.rawValue) == UV_0.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | UV_1.rawValue) : (m_Attributes.rawValue & ~(UV_1.rawValue)))
        }
    }

    var hasUV2: Bool {
        get {
            return (m_Attributes.rawValue & UV_1.rawValue) == UV_1.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | UV_1.rawValue) : (m_Attributes.rawValue & ~(UV_1.rawValue)))
        }
    }

    var hasUV3: Bool {
        get {
            return (m_Attributes.rawValue & UV_2.rawValue) == UV_2.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | UV_2.rawValue) : (m_Attributes.rawValue & ~(UV_2.rawValue)))
        }
    }

    var hasUV4: Bool {
        get {
            return (m_Attributes.rawValue & UV_3.rawValue) == UV_3.rawValue
        }
        set {
            m_Attributes = Attributes(newValue ? (m_Attributes.rawValue | UV_3.rawValue) : (m_Attributes.rawValue & ~(UV_3.rawValue)))
        }
    }

    /// Initialize a Vertex with no values.
    public init() {
    }

    /// Compare the equality of vertex values. Uses the @"UnityEngine.ProBuilder.Math" Approx functions to compare float values.
    /// - Parameter other: The vertex to compare.
    /// - Returns: True if all values are the same (within float.Epsilon).
    public func Equals(other: Vertex) -> Bool {
        false
    }

    public func Equals(other: Vertex, mask: Attributes) -> Bool {
        false
    }

    /// Copy constructor.
    /// - Parameter vertex: The Vertex to copy field data from.
    public init(_ vertex: Vertex) {

    }

    /// Normalize all vector values in place.
    public func Normalize() {
    }

    /// Allocate and fill all attribute arrays. This method will fill all arrays, regardless of whether or not real data populates the values (check what attributes a Vertex contains with HasAttribute()).
    /// - Remark:
    /// If you are using this function to rebuild a mesh, use SetMesh instead. SetMesh handles setting null arrays where appropriate for you.
    /// - Parameters:
    ///   - vertices: The source vertices.
    ///   - position: A new array of the vertex position values.
    ///   - color: A new array of the vertex color values.
    ///   - uv0: A new array of the vertex uv0 values.
    ///   - normal: A new array of the vertex normal values.
    ///   - tangent: A new array of the vertex tangent values.
    ///   - uv2: A new array of the vertex uv2 values.
    ///   - uv3: A new array of the vertex uv3 values.
    ///   - uv4: A new array of the vertex uv4 values.
    public static func GetArrays(
            vertices: [Vertex],
            position: inout [Vector3],
            color: inout [Color],
            uv0: inout [Vector2],
            normal: inout [Vector3],
            tangent: inout [Vector4],
            uv2: inout [Vector2],
            uv3: inout [Vector4],
            uv4: inout [Vector4]) {
    }

    /// Allocate and fill the requested attribute arrays.
    /// - Remark:
    /// If you are using this function to rebuild a mesh, use SetMesh instead. SetMesh handles setting null arrays where appropriate for you.
    /// - Parameters:
    ///   - vertices: The source vertices.
    ///   - position: A new array of the vertex position values if requested by the attributes parameter, or null.
    ///   - color: A new array of the vertex color values if requested by the attributes parameter, or null.
    ///   - uv0: A new array of the vertex uv0 values if requested by the attributes parameter, or null.
    ///   - normal: A new array of the vertex normal values if requested by the attributes parameter, or null.
    ///   - tangent: A new array of the vertex tangent values if requested by the attributes parameter, or null.
    ///   - uv2: A new array of the vertex uv2 values if requested by the attributes parameter, or null.
    ///   - uv3: A new array of the vertex uv3 values if requested by the attributes parameter, or null.
    ///   - uv4: A new array of the vertex uv4 values if requested by the attributes parameter, or null.
    ///   - attributes: A flag with the MeshAttributes requested.
    public static func GetArrays(
            vertices: [Vertex],
            position: inout [Vector3],
            color: inout [Color],
            uv0: inout [Vector2],
            normal: inout [Vector3],
            tangent: inout [Vector4],
            uv2: inout [Vector2],
            uv3: inout [Vector4],
            uv4: inout [Vector4],
            attributes: Attributes) {
    }

    /// Replace mesh values with vertex array. Mesh is cleared during this function, so be sure to set the triangles after calling.
    /// - Parameters:
    ///   - mesh: The target mesh.
    ///   - vertices: The vertices to replace the mesh attributes with.
    public static func SetMesh(_ mesh: ModelMesh, vertices: [Vertex]) {

    }

    /// Average all vertices to a single vertex.
    /// - Parameters:
    ///   - vertices: A list of vertices.
    ///   - indexes: If indexes is null, all vertices will be averaged. If indexes is provided, only the vertices referenced by the indexes array are averaged.
    /// - Returns: An averaged vertex value.
    public static func Average(vertices: [Vertex], indexes: [Int]? = nil) -> Vertex {
        Vertex()
    }

    /// Linearly interpolate between two vertices.
    /// - Parameters:
    ///   - x: Left parameter.
    ///   - y: Right parameter.
    ///   - weight: The weight of the interpolation. 0 is fully x, 1 is fully y.
    /// - Returns: A new vertex interpolated by weight between x and y.
    public static func Mix(_ x: Vertex, and y: Vertex, weight: Float) -> Vertex {
        Vertex()
    }
}

extension Vertex: Hashable {
    public func hash(into hasher: inout Hasher) {

    }

    public static func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        lhs.Equals(other: rhs)
    }
}

extension Vertex {
    /// Addition is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side addition parameter.
    ///   - b: Right side addition parameter.
    /// - Returns: A new Vertex with the sum of a + b.
    public static func +(a: Vertex, b: Vertex) -> Vertex {
        Add(a, b)
    }

    /// Addition is performed component-wise for every property.
    /// - Remark:
    ///Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side addition parameter.
    ///   - b: Right side addition parameter.
    /// - Returns: A new Vertex with the sum of a + b.
    public static func Add(_ a: Vertex, _ b: Vertex) -> Vertex {
        let v = Vertex(a)
        v.Add(b)
        return v
    }

    /// Addition is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameter b: Right side addition parameter.
    public func Add(_ b: Vertex) {

    }
}


extension Vertex {
    /// Subtraction is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side subtraction parameter.
    ///   - b: Right side subtraction parameter.
    /// - Returns: A new Vertex with the sum of a - b.
    public static func -(a: Vertex, b: Vertex) -> Vertex {
        Subtract(a, b)
    }

    /// Subtraction is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side subtraction parameter.
    ///   - b: Right side subtraction parameter.
    /// - Returns: A new Vertex with the sum of a - b.
    public static func Subtract(_ a: Vertex, _ b: Vertex) -> Vertex {
        let c = Vertex(a)
        c.Subtract(b)
        return c
    }

    /// Subtraction is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameter b: Right side subtraction parameter.
    public func Subtract(_ b: Vertex) {

    }
}

extension Vertex {
    /// Multiplication is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side multiplication parameter.
    ///   - value: Right side multiplication parameter.
    /// - Returns: A new Vertex with the sum of a * b.
    public static func *(a: Vertex, value: Float) -> Vertex {
        return Multiply(a, value)
    }

    /// Multiplication is performed component-wise for every property.
    /// - Parameters:
    ///   - a: Left side multiplication parameter.
    ///   - value: Right side multiplication parameter.
    /// - Returns: A new Vertex with the sum of a * b.
    public static func Multiply(_ a: Vertex, _ value: Float) -> Vertex {
        let v = Vertex(a)
        v.Multiply(value)
        return v
    }

    /// Multiplication is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameter value: Right side multiplication parameter.
    public func Multiply(_ value: Float) {
    }
}

extension Vertex {
    /// Division is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side division parameter.
    ///   - value: Right side division parameter.
    /// - Returns: A new Vertex with the sum of a / b.
    public static func /(a: Vertex, value: Float) -> Vertex {
        return Divide(a, value)
    }

    /// Division is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameters:
    ///   - a: Left side division parameter.
    ///   - value: Right side division parameter.
    /// - Returns: A new Vertex with the sum of a / b.
    public static func Divide(_ a: Vertex, _ value: Float) -> Vertex {
        let v = Vertex(a)
        v.Divide(value)
        return v
    }

    /// Division is performed component-wise for every property.
    /// - Remark:
    /// Color, normal, and tangent values are not normalized within this function. If you are expecting unit vectors, make sure to normalize these properties.
    /// - Parameter value: Right side Division parameter.
    public func Divide(_ value: Float) {

    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        ""
    }
}
