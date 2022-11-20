//  Copyright (c) 2022 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

import Foundation

public class GLTFLoader {
    private let _engine: Engine
    public var asset: GLTFAsset?

    public init(_ engine: Engine, with name: String) {
        _engine = engine
        guard let assetUrl = Bundle.main.url(forResource: name, withExtension: nil) else {
            fatalError("Model: \(name) not found")
        }

        GLTFAsset.load(with: assetUrl, options: [:]) { (progress, status, maybeAsset, maybeError, _) in
            DispatchQueue.main.async { [self] in
                if status == .complete {
                    asset = maybeAsset!
                } else if let error = maybeError {
                    print("Failed to load glTF asset: \(error)")
                }
            }
        }
    }


}
