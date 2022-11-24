//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import vox_math

class AnimationParser: Parser {
    override func parse(_ context: ParserContext) {
        let glTFResource = context.glTFResource!
        let gltf = glTFResource.gltf!

        if gltf.animations.isEmpty {
            return
        }
        let animationClipCount = gltf.animations.count
        var animationClips: [AnimationClip] = []
        var sampleDataCollection: [SampleData] = []
        for i in 0..<animationClipCount {
            if (context.animationIndex != nil && context.animationIndex! != i) {
                continue
            }
            let gltfAnimation = gltf.animations[i]
            let animationClip = AnimationClip(gltfAnimation.name ?? "AnimationClip\(i)")

            for j in 0..<gltfAnimation.samplers.count {
                let gltfSampler = gltfAnimation.samplers[j]

                var samplerInterpolation: InterpolationType = .Linear
                switch gltfSampler.interpolationMode {
                case .linear:
                    samplerInterpolation = .Linear
                    break
                case .step:
                    samplerInterpolation = .Step
                    break
                case .cubic:
                    samplerInterpolation = .CubicSpine
                    break
                default:
                    break
                }

                sampleDataCollection.append(SampleData(input: gltfSampler.input, output: gltfSampler.output, interpolation: samplerInterpolation))
            }

            for j in 0..<gltfAnimation.channels.count {
                let gltfChannel = gltfAnimation.channels[j]
                let target = gltfChannel.target
                let channelTargetEntity = glTFResource.entities[target.node!.index]
                var relativePath = ""
                var entity: Entity? = channelTargetEntity
                while (entity!.parent != nil) {
                    relativePath = relativePath == "" ? "\(entity!.name)" : "\(entity!.name)/\(relativePath)"
                    entity = entity!.parent
                }

                switch target.path {
                case "translation":
                    let curve: AnimationCurve<Vector3, AnimationVector3Curve> = _addCurve(gltfChannel, sampleDataCollection)
                    animationClip.addCurveBinding(relativePath, Transform.self, .Position, curve)
                    break
                case "rotation":
                    let curve: AnimationCurve<Quaternion, AnimationQuaternionCurve> = _addCurve(gltfChannel, sampleDataCollection)
                    animationClip.addCurveBinding(relativePath, Transform.self, .Rotation, curve)
                    break
                case "scale":
                    let curve: AnimationCurve<Vector3, AnimationVector3Curve> = _addCurve(gltfChannel, sampleDataCollection)
                    animationClip.addCurveBinding(relativePath, Transform.self, .Scale, curve)
                    break
                case "weights":
                    let curve: AnimationCurve<[Float], AnimationArrayCurve> = _addCurve(gltfChannel, sampleDataCollection)
                    animationClip.addCurveBinding(relativePath, SkinnedMeshRenderer.self, .BlendShapeWeights, curve)
                    break
                default:
                    break
                }
            }
            animationClips.append(animationClip)
        }

        glTFResource.animations = animationClips
    }

    private func _addCurve<V: KeyframeValueType, Calculator: IAnimationCurveCalculator>(
            _ gltfChannel: GLTFAnimationChannel,
            _ sampleDataCollection: [SampleData]
    ) -> AnimationCurve<V, Calculator> where Calculator.V == V, V == V.TangentType {

        let sampleData = sampleDataCollection[gltfChannel.sampler.index]
        let curve = AnimationCurve<V, Calculator>()
        curve.interpolation = sampleData.interpolation
        let outputAccessorSize = sampleData.output.count / sampleData.input.count

        var input = [Float](repeating: 0, count: sampleData.input.count)
        GLTFUtil.convert(sampleData.input, out: &input)
        var output: [V] = []
        if sampleData.interpolation == .CubicSpine {
            output = [V](repeating: V(), count: sampleData.output.count * 3 * outputAccessorSize)
        } else {
            output = [V](repeating: V(), count: sampleData.output.count * outputAccessorSize)
        }
        GLTFUtil.convert(sampleData.output, out: &output)

        for i in 0..<sampleData.input.count {
            let keyframe = Keyframe<V>()
            keyframe.time = input[i]
            if sampleData.interpolation == .CubicSpine {
                keyframe.value = output[i * 3]
                keyframe.inTangent = output[i * 3 + 1]
                keyframe.outTangent = output[i * 3 + 2]
            } else {
                keyframe.value = output[i]
            }

            curve.addKey(keyframe)
        }
        return curve
    }
}

struct SampleData {
    var input: GLTFAccessor
    var output: GLTFAccessor
    var interpolation: InterpolationType
}