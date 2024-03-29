//  Copyright (c) 2023 Feng Yang
//
//  I am making my contributions/submissions to this project solely in my
//  personal capacity and am not conveying any rights to any intellectual
//  property of any third parties.

@testable import vox_render
import XCTest

final class SceneDecodeTests: XCTestCase {
    var canvas: Canvas!
    var engine: Engine!
    var jsonEncode: JSONEncoder!

    override func setUpWithError() throws {
        canvas = Canvas(frame: CGRect())
        engine = Engine(canvas: canvas)

        jsonEncode = JSONEncoder()
        jsonEncode.outputFormatting = .prettyPrinted
    }

    override func tearDownWithError() throws {
        canvas = nil
        Engine.destroy()
        engine = nil
    }

    func testSceneDecode() throws {
        let scene = Engine.sceneManager.activeScene!
        scene.name = "SceneName"

        let data = try! jsonEncode.encode(scene)
        // print(String(data: data, encoding: .utf8)!)

        let newScene = try! Engine.makeDecoder().decode(Scene.self, from: data)
        XCTAssertEqual(scene.name, newScene.name)
    }

    func testSceneWithEntityDecode() throws {
        let scene = Engine.sceneManager.activeScene!
        scene.name = "SceneName"
        let rootEntity = scene.createRootEntity()
        rootEntity.name = "EntityName"

        let data = try! jsonEncode.encode(scene)
        // print(String(data: data, encoding: .utf8)!)

        let newScene = try! Engine.makeDecoder().decode(Scene.self, from: data)
        XCTAssertEqual(rootEntity.name, newScene.rootEntities[0].name)
    }

    func testSceneWithChildEntityDecode() throws {
        let scene = Engine.sceneManager.activeScene!
        scene.name = "SceneName"
        let rootEntity = scene.createRootEntity()
        rootEntity.name = "EntityName"
        let childEntity = rootEntity.createChild("ChildName")
        let camera = childEntity.addComponent(Camera.self)
        camera.fieldOfView = 10

        let data = try! jsonEncode.encode(scene)
        // print(String(data: data, encoding: .utf8)!)

        let newScene = try! Engine.makeDecoder().decode(Scene.self, from: data)
        XCTAssertEqual(childEntity.name, newScene.rootEntities[0].children[0].name)
    }
}
