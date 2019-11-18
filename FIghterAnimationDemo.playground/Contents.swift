//: A UIKit based Playground for presenting user interface
  
import UIKit
import SceneKit
import GameplayKit
import PlaygroundSupport

class AnimationState: GKState {
    let node:SCNNode
    let animation:SCNAnimationProtocol
    let animationKey: String
    init(node: SCNNode, animation: SCNAnimationProtocol, animationKey: String) {
        self.node = node
        self.animation = animation
        self.animationKey = animationKey
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        if let previous = previousState as? AnimationState {
            node.removeAnimation(forKey: previous.animationKey, blendOutDuration: 0.5)
        }
        node.addAnimation(animation, forKey: animationKey)
    }
}

let baseNodeName = "Bip01"
let transition = 0.5

func animationForScene(sceneName: String, animationID: String) -> SCNAnimation? {
    guard let scene = SCNScene(named: sceneName) else {
        return nil
    }
    guard let baseNode = scene.rootNode.childNode(withName: baseNodeName, recursively: true) else {
        return nil
    }
    guard let animationPlayer = baseNode.animationPlayer(forKey: animationID) else {
        return nil
    }
    let animation = animationPlayer.animation
    animation.blendInDuration = transition
    animation.blendOutDuration = transition
    return animation
}

class IdleState: AnimationState {}
class AttackState: AnimationState {}
class WalkState: AnimationState {}
class RunState: AnimationState {}
class DieState: AnimationState {}

let scene = SCNScene()
let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 700, height: 700))
sceneView.scene = scene
sceneView.autoenablesDefaultLighting = true
let idleNode = SCNScene(named: "idle.scn")!.rootNode.clone()
let baseNode = idleNode.childNode(withName: baseNodeName, recursively: true)!

let idleAniamtion = baseNode.animationPlayer(forKey: "idleAnimationID")!.animation
idleAniamtion.blendInDuration = transition
idleAniamtion.blendOutDuration = transition
let attackANimation = animationForScene(sceneName: "attack.scn", animationID: "attackID")!
let walkAnimation = animationForScene(sceneName: "walk.scn", animationID: "WalkID")!
let runAnimation = animationForScene(sceneName: "run.scn", animationID: "RunID")!
let dieAnimation = animationForScene(sceneName: "die.scn", animationID: "DeathID")!

attackANimation.repeatCount = 0
dieAnimation.duration = 9000

let idleState = IdleState(node: baseNode, animation: idleAniamtion, animationKey: "idleAnimationID")
let attackState = AttackState(node: baseNode, animation: attackANimation, animationKey: "attackID")
let walkState = WalkState(node: baseNode, animation: walkAnimation, animationKey: "WalkID")
let runState = RunState(node: baseNode, animation: runAnimation, animationKey: "RunID")
let dieState = DieState(node: baseNode, animation: dieAnimation, animationKey: "DeathID")
let stateMachine = GKStateMachine(states: [idleState,attackState,walkState,runState,dieState])

scene.rootNode.addChildNode(idleNode)

PlaygroundPage.current.liveView = sceneView

DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
    stateMachine.enter(AttackState.self)
}
DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
    stateMachine.enter(WalkState.self)
}
DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
    stateMachine.enter(RunState.self)
}
DispatchQueue.global().asyncAfter(deadline: .now() + 7) {
    stateMachine.enter(IdleState.self)
}
DispatchQueue.global().asyncAfter(deadline: .now() + 9) {
    stateMachine.enter(DieState.self)
}
DispatchQueue.global().asyncAfter(deadline: .now() + 11) {
    stateMachine.enter(IdleState.self)
}
