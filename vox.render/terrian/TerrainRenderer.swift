//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Math
import Metal

public class TerrainRenderer: Renderer {
    // Terrain rendering data
    var _terrainData: TerrianData!

    // Tesselation data
    var _visiblePatchesTessFactorBfr: MTLBuffer
    var _visiblePatchIndicesBfr: MTLBuffer
    var _tessellationScale: Float

    var _iabBufferIndex_PplTerrainMainView: Int = 1

    public private(set) var terrainParamsBuffer: MTLBuffer
    public private(set) var terrainHeight: MTLTexture
    public private(set) var terrainNormalMap: MTLTexture!
    public private(set) var terrainPropertiesMap: MTLTexture!

    override func _updateBounds(_ worldBounds: inout BoundingBox) {
        worldBounds.setMinMax(Vector3(TERRAIN_SCALE / -2.0, 0, TERRAIN_SCALE / -2.0),
                Vector3(TERRAIN_SCALE / 2.0, TERRAIN_HEIGHT, TERRAIN_SCALE / 2.0))
    }

    required init() {
        let terrainShadingFunc = Engine.library().makeFunction(name: "terrain_fragment")!
        let paramsEncoder = terrainShadingFunc.makeArgumentEncoder(bufferIndex: 1)
        terrainParamsBuffer = Engine.device.makeBuffer(length: paramsEncoder.encodedLength, options: .storageModeManaged)!
        paramsEncoder.setArgumentBuffer(terrainParamsBuffer, offset: 0)

        let EncodeParamsFromData = { (encoder: MTLArgumentEncoder,
                                      curHabitat: TerrainHabitatType,
                                      terrainTextures: [TerrianData.HabitatTextures]) in
            encoder.setTexture(terrainTextures[Int(curHabitat.rawValue)].diffSpecTextureArray,
                    index: TerrainRenderer.IabIndexForHabitatParam(habType: curHabitat, memberId: .diffSpecTextureArray))
            encoder.setTexture(terrainTextures[Int(curHabitat.rawValue)].normalTextureArray,
                    index: TerrainRenderer.IabIndexForHabitatParam(habType: curHabitat, memberId: .normalTextureArray))
        }
        // Configure the various terrain "habitats."
        // - these are the look-and-feel of visually distinct areas that differ by elevation
        var curHabitat: TerrainHabitatType = .Sand
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeStrength, value: 100.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeThreshold, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationStrength, value: 100.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationThreshold, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .specularPower, value: 32.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .textureScale, value: 0.0010)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .flipNormal, value: false)
        EncodeParamsFromData(paramsEncoder, curHabitat, _terrainData.terrainTextures)

        curHabitat = .Grass
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeStrength, value: 100.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeThreshold, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationStrength, value: 40.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationThreshold, value: 0.146)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .specularPower, value: 32.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .textureScale, value: 0.001)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .flipNormal, value: false)
        EncodeParamsFromData(paramsEncoder, curHabitat, _terrainData.terrainTextures)

        curHabitat = .Rock
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeStrength, value: 100.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeThreshold, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationStrength, value: 40.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationThreshold, value: 0.28)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .specularPower, value: 32.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .textureScale, value: 0.002)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .flipNormal, value: false)
        EncodeParamsFromData(paramsEncoder, curHabitat, _terrainData.terrainTextures)

        curHabitat = .Snow
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeStrength, value: 43.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .slopeThreshold, value: 0.612)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationStrength, value: 100.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .elevationThreshold, value: 0.39)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .specularPower, value: 32.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .textureScale, value: 0.002)
        TerrainRenderer.EncodeParam(with: paramsEncoder, habType: curHabitat, memberId: .flipNormal, value: false)
        EncodeParamsFromData(paramsEncoder, curHabitat, _terrainData.terrainTextures)

        TerrainRenderer.EncodeParam(with: paramsEncoder, memberId: .ambientOcclusionScale, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, memberId: .ambientOcclusionContrast, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, memberId: .ambientLightScale, value: 0.0)
        TerrainRenderer.EncodeParam(with: paramsEncoder, memberId: .atmosphereScale, value: 0.0)

        terrainParamsBuffer.didModifyRange(0..<terrainParamsBuffer.length)

        // MARK: - Use a height map to define the initial terrain topography
        let heightMapWidth = _terrainData.targetHeightmap.width
        let heightMapHeight = _terrainData.targetHeightmap.height

        let _srcTex = _terrainData.targetHeightmap
        _srcTex.label = "SourceTerrain"

        var texDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float,
                width: heightMapWidth,
                height: heightMapHeight, mipmapped: false)
        texDesc.usage = [texDesc.usage, .shaderRead, .shaderWrite]
        texDesc.storageMode = .private
        let _dstTex = Engine.device.makeTexture(descriptor: texDesc)!
        _dstTex.label = "CopiedTerrain"
        terrainHeight = _dstTex

        let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)
        assert(((heightMapWidth / 16) * 16) == heightMapWidth)
        assert(((heightMapHeight / 16) * 16) == heightMapHeight)

        _tessellationScale = 25.0
        _visiblePatchIndicesBfr
                = Engine.device.makeBuffer(length: MemoryLayout<UInt32>.stride
                                           * Int(TERRAIN_PATCHES) * Int(TERRAIN_PATCHES),
                options: .storageModePrivate)!

        _visiblePatchesTessFactorBfr
                = Engine.device.makeBuffer(length: MemoryLayout<MTLQuadTessellationFactorsHalf>.stride
                                           * Int(TERRAIN_PATCHES) * Int(TERRAIN_PATCHES),
                options: .storageModePrivate)!

        super.init()

        if let commandBuffer = Engine.commandQueue.makeCommandBuffer() {
            if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
                computeEncoder.label = "CopyRG16ToR16"
                computeEncoder.setTexture(_srcTex, index: 0)
                computeEncoder.setTexture(_dstTex, index: 1)
                computeEncoder.dispatchThreads(MTLSizeMake(heightMapWidth, heightMapHeight, 1),
                                               threadsPerThreadgroup: threadsPerThreadgroup)

                computeEncoder.endEncoding()
                commandBuffer.commit()
            }

            //MARK: - Create normals and props textures
            texDesc = MTLTextureDescriptor()
            texDesc.width = heightMapWidth
            texDesc.height = heightMapHeight
            texDesc.pixelFormat = .rg11b10Float
            texDesc.usage = [.shaderRead, .shaderWrite]
            texDesc.mipmapLevelCount = Int(log2(Float(max(heightMapWidth, heightMapHeight)))) + 1
            texDesc.storageMode = .private
            terrainNormalMap = Engine.device.makeTexture(descriptor: texDesc)!
            generateTerrainNormalMap(with: commandBuffer)

            texDesc.pixelFormat = .rgba8Unorm
            terrainPropertiesMap = Engine.device.makeTexture(descriptor: texDesc)!

            // We need to clear the properties map as 'GenerateTerrainPropertiesMap' will only fill in specific color channels
            if let encoder = commandBuffer.makeComputeCommandEncoder() {
                encoder.setTexture(terrainPropertiesMap, index: 0)
                encoder.dispatchThreads(MTLSize(width: heightMapWidth, height: heightMapHeight, depth: 1),
                        threadsPerThreadgroup: MTLSize(width: 8, height: 8, depth: 1))
                encoder.endEncoding()
            }
            generateTerrainPropertiesMap(with: commandBuffer)

            if let blit = commandBuffer.makeBlitCommandEncoder() {
                blit.generateMipmaps(for: terrainNormalMap)
                blit.generateMipmaps(for: terrainPropertiesMap)
                blit.endEncoding()
            }
            commandBuffer.commit()
        }
    }

    func generateTerrainNormalMap(with commandBuffer: MTLCommandBuffer) {
        if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {

            let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)
            assert(((terrainHeight.width / 16) * 16) == terrainHeight.width)
            assert(((terrainHeight.height / 16) * 16) == terrainHeight.height)

            computeEncoder.setTexture(terrainHeight, index: 0)
            computeEncoder.setTexture(terrainNormalMap, index: 1)
            computeEncoder.dispatchThreads(MTLSizeMake(terrainHeight.width, terrainHeight.height, 1),
                    threadsPerThreadgroup: threadsPerThreadgroup)
            computeEncoder.endEncoding()
        }
    }

    func generateTerrainPropertiesMap(with commandBuffer: MTLCommandBuffer) {
        let GenerateSamplesBuffer = { (device: MTLDevice, numSamples: Int) in
            var res: [SIMD2<Float>] = []

            let sampleRadius: Float = 32.0
            for _ in 0..<numSamples {
                let u = Float.random(in: 0..<1)
                let v = Float.random(in: 0..<1)

                let r = sqrtf(u)
                let theta = 2.0 * Float.pi * v

                res.append(SIMD2<Float>(cos(theta), sin(theta)) * r * sampleRadius)
            }

            return device.makeBuffer(bytes: res, length: MemoryLayout<SIMD2<Float>>.stride * res.count, options: .storageModeManaged)
        }
        var numSamples = 256
        let sampleBuffer = GenerateSamplesBuffer(commandBuffer.device, numSamples)

        if let computeEncoder = commandBuffer.makeComputeCommandEncoder() {
            computeEncoder.setTexture(terrainHeight, index: 0)
            computeEncoder.setTexture(terrainPropertiesMap, index: 1)
            computeEncoder.setBuffer(sampleBuffer, offset: 0, index: 0)
            computeEncoder.setBytes(&numSamples, length: MemoryLayout<Int>.stride, index: 1)

            var invSize = SIMD2<Float>(1.0 / Float(terrainHeight.width), 1.0 / Float(terrainHeight.height))
            computeEncoder.setBytes(&invSize, length: MemoryLayout<SIMD2<Float>>.stride, index: 2)
            computeEncoder.dispatchThreads(MTLSize(width: terrainHeight.width, height: terrainHeight.height, depth: 1),
                    threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1))
            computeEncoder.endEncoding()
        }
    }

    static func IabIndexForHabitatParam(habType: TerrainHabitatType,
                                        memberId: TerrainHabitat_MemberIds) -> Int {
        Int(TerrainHabitat_MemberIds.COUNT.rawValue) * Int(habType.rawValue) + Int(memberId.rawValue)
    }

    static func EncodeParam<T>(with paramsEncoder: MTLArgumentEncoder,
                               habType: TerrainHabitatType,
                               memberId: TerrainHabitat_MemberIds,
                               value: T) {
        var value = value
        let index = IabIndexForHabitatParam(habType: habType, memberId: memberId)
        paramsEncoder.constantData(at: index).copyMemory(from: &value, byteCount: MemoryLayout<T>.stride)
    }

    static func EncodeParam<T>(with paramsEncoder: MTLArgumentEncoder,
                               memberId: TerrainParams_MemberIds,
                               value: T) {
        var value = value
        let index = Int(memberId.rawValue)
        paramsEncoder.constantData(at: index).copyMemory(from: &value, byteCount: MemoryLayout<T>.stride)
    }
}
