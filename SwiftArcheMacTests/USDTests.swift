//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import XCTest
import ModelIO

final class USDTests: XCTestCase {
    func testPrimitiveGeometry() throws {
        let mdl = MDLMesh(boxWithExtent: vector_float3(1, 2, 3), segments: vector_uint3(10, 10, 10),
                          inwardNormals: false, geometryType: .triangles, allocator: nil)
        let asset = MDLAsset()
        asset.add(mdl)
        
        // let useABC = MDLAsset.canExportFileExtension("abc")
        // let useOBJ = MDLAsset.canExportFileExtension("obj")
        // let usePLY = MDLAsset.canExportFileExtension("ply")
        // let useSTL = MDLAsset.canExportFileExtension("stl")
        // let useUSDA = MDLAsset.canExportFileExtension("usda")
        // let useUSDC = MDLAsset.canExportFileExtension("usdc")
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("scene.usda")
            print(fileURL)
            try? asset.export(to: fileURL)
        }
    }
}
