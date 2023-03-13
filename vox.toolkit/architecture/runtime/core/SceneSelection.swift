//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_render
import Math

// This should not be public until there is something meaningful that can be done with it. However it has been
// public in the past, so we can't change it until the next major version increment.
public class SceneSelection {
    public var gameObject: Entity?
    public var mesh: ProBuilderMesh?

    var m_Vertices: [Int]
    var m_Edges: [Edge]
    var m_Faces: [Face]

    public var vertexes: [Int] {
        get {
            m_Vertices
        }
        set {
            m_Vertices = newValue
        }
    }

    public var edges: [Edge] {
        get {
            m_Edges
        }
        set {
            m_Edges = newValue
        }
    }

    public var faces: [Face] {
        get {
            m_Faces
        }
        set {
            m_Faces = newValue
        }
    }

    public var vertex: Int?

    public var edge: Edge?

    public var face: Face?

    public init(gameObject: Entity? = nil) {
        self.gameObject = gameObject
        m_Vertices = []
        m_Edges = []
        m_Faces = []
    }

    public convenience init(mesh: ProBuilderMesh?, vertex: Int) {
        self.init(mesh: mesh, vertexes: [vertex])
    }

    public convenience init(mesh: ProBuilderMesh?, edge: Edge) {
        self.init(mesh: mesh, edges: [edge])
    }

    public convenience init(mesh: ProBuilderMesh?, face: Face) {
        self.init(mesh: mesh, faces: [face])
    }

    internal convenience init(mesh: ProBuilderMesh?, vertexes: [Int]) {
        self.init(gameObject: mesh != nil ? mesh!.entity : nil)
        self.mesh = mesh
        m_Vertices = vertexes
        m_Edges = []
        m_Faces = []
    }

    internal convenience init(mesh: ProBuilderMesh?, edges: [Edge]) {
        self.init(gameObject: mesh != nil ? mesh!.entity : nil)
        self.mesh = mesh
        vertexes = []
        self.edges = edges
        faces = []
    }

    internal convenience init(mesh: ProBuilderMesh?, faces: [Face]) {
        self.init(gameObject: mesh != nil ? mesh!.entity : nil)
        self.mesh = mesh
        vertexes = []
        edges = []
        self.faces = faces
    }

    public func SetSingleFace(_ face: Face) {
        faces = []
        faces.append(face)
    }

    public func SetSingleVertex(_ vertex: Int) {
        vertexes = []
        vertexes.append(vertex)
    }

    public func SetSingleEdge(_ edge: Edge) {
        edges = []
        edges.append(edge)
    }

    public func Clear() {
        gameObject = nil
        mesh = nil
        faces = []
        edges = []
        vertexes = []
    }

    public func CopyTo(dst: SceneSelection) {
        dst.gameObject = gameObject
        dst.mesh = mesh
        dst.faces = []
        dst.edges = []
        dst.vertexes = []
        for x in faces {
            dst.faces.append(x)
        }
        for x in edges {
            dst.edges.append(x)
        }
        for x in vertexes {
            dst.vertexes.append(x)
        }
    }
}

extension SceneSelection: Hashable {
    public static func ==(lhs: SceneSelection, rhs: SceneSelection) -> Bool {
        if lhs === rhs {
            return true
        }
        return (lhs.gameObject == rhs.gameObject)
                && (lhs.mesh == rhs.mesh)
                && (lhs.vertexes == rhs.vertexes)
                && (lhs.edges == rhs.edges)
                && (lhs.faces == rhs.faces)
    }

    public func hash(into hasher: inout Hasher) {
        if let gameObject {
            hasher.combine(gameObject.instanceId)
        }

        if let mesh {
            // TODO: 
        }

        if !vertexes.isEmpty {
            hasher.combine(vertexes.hashValue)
        }

        if !edges.isEmpty {
            hasher.combine(edges.hashValue)
        }

        if !faces.isEmpty {
            hasher.combine(faces.hashValue)
        }
    }
}

struct VertexPickerEntry {
    public var mesh: ProBuilderMesh
    public var vertex: Int
    public var screenDistance: Float
    public var worldPosition: Vector3
}
