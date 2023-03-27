//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation
import Metal

/// Aligns a value to the next multiple of the alignment.
func alignUp(value: Int, alignment: Int) -> Int {
    (value + (alignment - 1)) & ~(alignment - 1)
}

/// Divides a value, rounding up.
func divideRoundUp(numerator: Int, denominator: Int) -> Int {
    (numerator + denominator - 1) / denominator
}

func divideRoundUp(numerator: MTLSize, denominator: MTLSize) -> MTLSize {
    MTLSize(width: divideRoundUp(numerator: numerator.width, denominator: denominator.width),
            height: divideRoundUp(numerator: numerator.height, denominator: denominator.height),
            depth: divideRoundUp(numerator: numerator.depth, denominator: denominator.depth))
}

// Returns name of App/Executable.
func getAppName() -> String {
    var bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    if (bundleName == nil) {
        bundleName = String(utf8String: getprogname())
    }
    return bundleName!
}

// Returns/creates a file path usable for storing application data.
func getOrCreateApplicationSupportPath() -> String? {
    let asdRoots = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
    assert(asdRoots.count != 0)

    let asdRoot = asdRoots[0]
    var asdPath: String? = asdRoot + String(format: "/%@", getAppName())

    do {
        try FileManager.default.createDirectory(atPath: asdPath!, withIntermediateDirectories: true)
    } catch {
        asdPath = nil
    }

    return asdPath
}

func newComputePipelineState(library: MTLLibrary, functionName: String, label: String,
                             functionConstants: MTLFunctionConstantValues?) -> MTLComputePipelineState? {
    let descriptor = MTLComputePipelineDescriptor()
    descriptor.label = label

    let functionDescriptor = MTLFunctionDescriptor()
    functionDescriptor.name = functionName
    if let functionConstants {
        functionDescriptor.constantValues = functionConstants
    }

    descriptor.computeFunction = try? library.makeFunction(descriptor: functionDescriptor)
    let result = try? library.device.makeComputePipelineState(descriptor: descriptor, options: MTLPipelineOption())
    return result?.0
}
