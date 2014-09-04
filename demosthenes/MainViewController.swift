import Cocoa
import SceneKit
import AVFoundation
import CoreMedia

// delay before audio playback, in seconds
let audioPlaybackDelay = 0.2

class MainViewController: NSViewController, SCNSceneRendererDelegate {

    var sceneView: SCNView!
    var overlayScene: OverlayScene!
    let scene: SCNScene
    let rootNode: SCNNode
    let cursor: Cursor
    let audioPlayer: AVAudioPlayer
    var startTime: NSDate?

    let camera: SCNCamera
    let cameraNode: SCNNode // used to move the camera relative to the global position (cameraHandle)
    let cameraHandle: SCNNode // used to control the global position in world space
    let cameraPitch: SCNNode // used to rotate the position around the x axis

    let ambientLight: SCNLight
    let ambientLightNode: SCNNode
    let omniLight: SCNLight
    let omniLightNode: SCNNode
    let floor: SCNFloor
    let floorNode: SCNNode

    required init(coder: NSCoder!) {
        // scene
        scene = SCNScene()
        rootNode = scene.rootNode

        // audio
        cursor = Cursor()
        audioPlayer = AVAudioPlayer(wav: "TacoTree")

        // cameras
        camera = SCNCamera()
        camera.xFov = 100.0 // increase for wide angle
        camera.yFov = 80.0
        cameraHandle = SCNNode()
        rootNode.addChildNode(cameraHandle)
        cameraPitch = SCNNode()
        cameraHandle.addChildNode(cameraPitch)
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 1, 100)
        cameraPitch.addChildNode(cameraNode)

        // lights
        ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = NSColor(deviceWhite: 0.1, alpha: 1.0)
        ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight

        omniLight = SCNLight()
        omniLight.type = SCNLightTypeOmni
        omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3Make(0, 80, 80)

        // floor
        floor = SCNFloor()
        floor.reflectionFalloffEnd = 3.0
        floorNode = SCNNode(geometry: floor)

        rootNode.addChildNode(cameraNode)
        rootNode.addChildNode(ambientLightNode)
        rootNode.addChildNode(omniLightNode)
        rootNode.addChildNode(floorNode)

        super.init(coder: coder)

    }

    override func awakeFromNib() {
        sceneView = self.view as SCNView
        sceneView.jitteringEnabled = true
        sceneView.backgroundColor = NSColor.grayColor()
        sceneView.scene = scene
        sceneView.delegate = self
        sceneView.pointOfView = cameraNode
        sceneView.playing = true
        sceneView.loops = true

        setSkybox("desert")
//        cameraNode.setRotation(vector: SCNVector3Make(0, 1, 0), duration: 100.0)



        start()

        let agave = SCNNode(resourceName: "agave_palm")
        rootNode.addChildNode(agave)
        agave.scale(0.4)
        agave.rotate(-M_PI/2.0, x: 1, y: 0, z: 0)
        agave.position = SCNVector3Make(0, 0, 50)

        
//        saguaro.setRotation(vector: SCNVector3Make(1, 0, -1), duration: 100.0)

// WARN: TRY THIS ON OSX 10.10
//        overlayScene = OverlayScene(size: sceneView.bounds.size)
//        overlayScene.setImage("atari_bluenoise")
//        sceneView.overlaySKScene = overlayScene // NEED OSX 10.10


}

    func start() {
        audioPlayer.prepareToPlay()
        startTime = NSDate()
        audioPlayer.playAtTime(audioPlayer.deviceCurrentTime + audioPlaybackDelay)
    }


    func setSkybox(name: String) {
        scene.setSkybox(name)
        floor.setCubemap(name)
    }

    func nodeForKey(key: UnsafePointer<()>) -> SCNNode {
        let node : SCNNode! = objc_getAssociatedObject(self, key) as SCNNode!
        return node
    }

    func saveNode(node: SCNNode, withKey key: UnsafePointer<()>) {
        objc_setAssociatedObject(self, key, node, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }

}
