//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import ModelIO

// MARK: - MDLVertexDescriptor

extension MDLVertexDescriptor {

    /// Returns the vertex buffer attribute descriptor at the specified index.
    func attribute(_ index: UInt32) -> MDLVertexAttribute {
        guard let attributes = attributes as? [MDLVertexAttribute] else {
            fatalError()
        }
        return attributes[Int(index)]
    }

    /// Returns the vertex buffer layout descriptor at the specified index.
    func layout(_ index: UInt32) -> MDLVertexBufferLayout {
        guard let layouts = layouts as? [MDLVertexBufferLayout] else {
            fatalError()
        }
        return layouts[Int(index)]
    }

}
