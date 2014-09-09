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
    let omniLightANode: SCNNode
    let omniLightBNode: SCNNode
    let omniLightCNode: SCNNode
    let floor: SCNFloor
    let floorNode: SCNNode

    let glitchPlane1: SCNNode
    let glitchPlane2: SCNNode
    let agave: SCNNode

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

        let omniLightA = SCNLight()
        omniLightA.type = SCNLightTypeOmni
        omniLightANode = SCNNode()
        omniLightANode.light = omniLightA
        omniLightANode.position = SCNVector3Make(0, 80, 80)

        let omniLightB = SCNLight()
        omniLightB.type = SCNLightTypeOmni
        omniLightBNode = SCNNode()
        omniLightBNode.light = omniLightB
        omniLightBNode.position = SCNVector3Make(0, 0, 100)

        let omniLightC = SCNLight()
        omniLightC.type = SCNLightTypeOmni
        omniLightCNode = SCNNode()
        omniLightCNode.light = omniLightC
        omniLightCNode.position = SCNVector3Make(0, -80, 40)

        // floor
        floor = SCNFloor()
        floor.reflectionFalloffEnd = 3.0
        floorNode = SCNNode(geometry: floor)

        rootNode.addChildNode(cameraNode)
        rootNode.addChildNode(ambientLightNode)
        rootNode.addChildNode(omniLightANode)
        rootNode.addChildNode(omniLightBNode)
        rootNode.addChildNode(omniLightCNode)
//        rootNode.addChildNode(floorNode)

        //////////// CUSTOM

        let box = SCNBox(width: 50, height: 100, length: 80, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.blackColor();
        material.ambient.contents = NSColor.blackColor()
        box.firstMaterial = material
        let blackBox = SCNNode(geometry: box)
        blackBox.position = SCNVector3Make(0, 0, -80)
        cameraNode.addChildNode(blackBox)       

        let plane = SCNPlane(width: 100.0, height: 100.0)
//        plane.firstMaterial = SCNMaterial(cubeMap: "powderpeak")
        plane.widthSegmentCount = 10
        plane.heightSegmentCount = 10
        glitchPlane1 = SCNNode(geometry: plane)
        glitchPlane1.position = SCNVector3Make(0, 0, -80)
//        glitchPlane1.setGeometryShader("bumps_geom1")
//        glitchPlane1.setFragmentShader("video_frag")
//        glitchPlane1.setRotation(vector: SCNVector3Make(0, 0, 1), duration: 50.0)
//        cameraNode.addChildNode(glitchPlane1)

        let plane2 = SCNPlane(width: 100.0, height: 100.0)
        plane2.firstMaterial = SCNMaterial(cubeMap: "endset")
        plane2.widthSegmentCount = 10
        plane2.heightSegmentCount = 10
        glitchPlane2 = SCNNode(geometry: plane2)
        glitchPlane2.position = SCNVector3Make(0, 0, -90)
        glitchPlane2.rotate(M_PI/4.0, x: 0, y: 0, z: 1)
        glitchPlane2.setGeometryShader("bumps_geom2")
        glitchPlane2.setFragmentShader("video_frag")
//        cameraNode.addChildNode(glitchPlane2)

        agave = SCNNode(resourceName: "agave_palm")
        agave.scale(0.6)
        agave.rotate(-M_PI/2.0, x: 1, y: 0, z: 0)
        agave.position = SCNVector3Make(-23, -40, -40)
        cameraNode.addChildNode(agave)

//        let aloe = SCNNode(resourceName: "aloe")
//        aloe.scale(0.1)
//        aloe.rotate(-M_PI/2.0, x: 1, y: 0, z: 0)
//        aloe.position = SCNVector3Make(-15, -25, -30)
//        cameraNode.addChildNode(aloe)


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

        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setDefaults()
        colorControls.setValue(3.0, forKey: "inputSaturation")
        let bloomFilter = CIFilter(name: "CIBloom")
        bloomFilter.setDefaults()
        let hexagonal = CIFilter(name: "CIHexagonalPixellate")
        hexagonal.setDefaults()


        let kaleidoscope = CIFilter(name: "CIOpTile")
        kaleidoscope.setValue(CIVector(x: 0, y: 0), forKey: "inputCenter")
//        kaleidoscope.setValue(CIVector(x: 50, y: 50), forKey: "inputInsetPoint1")
//        kaleidoscope.setValue(20, forKey: "inputCount")
        kaleidoscope.setDefaults()
        agave.filters = [colorControls, bloomFilter]
//        glitchPlane1.filters = [hexagonal]
        glitchPlane2.filters = []


        setSkybox("desert")
//        cameraNode.setRotation(vector: SCNVector3Make(0, 1, 0), duration: 100.0)



        start()



        cameraNode.setRotation(vector: SCNVector3Make(1, 0, -1), duration: 100.0)


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
