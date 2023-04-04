//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Metal

/// Stencil state.
public class StencilState {
    /// Whether to enable stencil test.
    public var enabled: Bool = false
    /// Write the reference value of the stencil buffer.
    public var referenceValue: UInt32 = 0
    /// Specifying a bit-wise mask that is used to AND the reference value and the stored stencil value when the test is done.
    public var mask: UInt32 = 0xFF
    /// Specifying a bit mask to enable or disable writing of individual bits in the stencil planes.
    public var writeMask: UInt32 = 0xFF
    /// The comparison function of the reference value of the front face of the geometry and the current buffer storage value.
    public var compareFunctionFront: MTLCompareFunction = .always
    /// The comparison function of the reference value of the back of the geometry and the current buffer storage value.
    public var compareFunctionBack: MTLCompareFunction = .always
    /// specifying the function to use for front face when both the stencil test and the depth test pass.
    public var passOperationFront: MTLStencilOperation = .keep
    /// specifying the function to use for back face when both the stencil test and the depth test pass.
    public var passOperationBack: MTLStencilOperation = .keep
    /// specifying the function to use for front face when the stencil test fails.
    public var failOperationFront: MTLStencilOperation = .keep
    /// specifying the function to use for back face when the stencil test fails.
    public var failOperationBack: MTLStencilOperation = .keep
    /// specifying the function to use for front face when the stencil test passes, but the depth test fails.
    public var zFailOperationFront: MTLStencilOperation = .keep
    /// specifying the function to use for back face when the stencil test passes, but the depth test fails.
    public var zFailOperationBack: MTLStencilOperation = .keep

    func _apply(_ depthStencilDescriptor: MTLDepthStencilDescriptor,
                _ renderEncoder: MTLRenderCommandEncoder)
    {
        if enabled {
            // apply stencil func.
            depthStencilDescriptor.frontFaceStencil.stencilCompareFunction = compareFunctionFront
            depthStencilDescriptor.frontFaceStencil.readMask = mask

            depthStencilDescriptor.backFaceStencil.stencilCompareFunction = compareFunctionBack
            depthStencilDescriptor.backFaceStencil.readMask = mask

            renderEncoder.setStencilReferenceValue(referenceValue)
        }

        // apply stencil operation.
        depthStencilDescriptor.frontFaceStencil.stencilFailureOperation = failOperationFront
        depthStencilDescriptor.frontFaceStencil.depthFailureOperation = zFailOperationFront
        depthStencilDescriptor.frontFaceStencil.depthStencilPassOperation = passOperationFront

        depthStencilDescriptor.backFaceStencil.stencilFailureOperation = failOperationBack
        depthStencilDescriptor.backFaceStencil.depthFailureOperation = zFailOperationBack
        depthStencilDescriptor.backFaceStencil.depthStencilPassOperation = passOperationBack

        // apply write mask.
        depthStencilDescriptor.frontFaceStencil.writeMask = writeMask
        depthStencilDescriptor.backFaceStencil.writeMask = writeMask
    }
}
