import Cocoa
import SceneKit

class MainViewController: NSViewController, MIDIPlayerDelegate {

    var sceneView: SCNView!
    var midiPlayer: MIDIPlayer?

    required init(coder: NSCoder!) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {


        sceneView = self.view as SCNView
        sceneView.backgroundColor = NSColor.grayColor()
        sceneView.scene = SCNScene()
        let rootNode = sceneView.scene.rootNode

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.xFov = 90 // increase for wide angle
        camera.yFov = 90
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 30, 90)
        rootNode.addChildNode(cameraNode)

        // lights
        let ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = NSColor(deviceWhite: 0.1, alpha: 1.0)
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        rootNode.addChildNode(ambientLightNode)

        let diffuseLight = SCNLight()
        diffuseLight.type = SCNLightTypeOmni
        let diffuseLightNode = SCNNode()
        diffuseLightNode.light = diffuseLight
        diffuseLightNode.position = SCNVector3Make(0, 80, 80)
        rootNode.addChildNode(diffuseLightNode)

        let flatShinyMaterial = SCNMaterial(cubeMap: "darkland")

        let floor = SCNFloor()
        floor.reflectionFalloffEnd = 200
        floor.materials = [flatShinyMaterial]
        let floorNode = SCNNode(geometry: floor)
        rootNode.addChildNode(floorNode)


        let animalgirlNode = SCNNode(resourceName: "animalgirl")
        animalgirlNode.rotate(-M_PI/3.0, x: 0, y: 1, z: 0)
        animalgirlNode.position = SCNVector3Make(0, -190, 0)
        animalgirlNode.scale(0.1)
        rootNode.addChildNode(animalgirlNode)

        let cube = SCNBox(size: 80.0)
        cube.materials = [flatShinyMaterial]
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.addRotation(vector: SCNVector3Make(1.0, 1.0, 1.0), duration: 5.0)
        flatShinyMaterial.addColorAnimation([
            NSColor.blueColor(),
            NSColor.blackColor()
            ], duration: 3.0, repeatCount: Float.infinity)
        rootNode.addChildNode(cubeNode)

        let sphere = SCNSphere(radius: 0.5)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(3.0, 0.0, 0.0)
        rootNode.addChildNode(sphereNode)

        let box = SCNBox(size: 80.0)
        let boxNode = SCNNode(geometry: box)
        boxNode.rotate(M_PI/2.0, x: 1, y: 0, z: 0)
        box.materials = [flatShinyMaterial]
        boxNode.addRotation(vector: SCNVector3Make(1, 0.5, 0), duration: 10.0)
        rootNode.addChildNode(boxNode)

        let text = SCNText(string: "☛", extrusionDepth: 4.0)
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3Make(-1, 2, 0)
        textNode.transform = CATransform3DScale(textNode.transform, 0.1, 0.1, 0.1)
        cubeNode.addChildNode(textNode)

        self.setupMIDI()
    }

    func setupMIDI() {
        midiPlayer = MIDIPlayer(filename: "SongInMyHead_RH")
        midiPlayer!.play()
    }

    // MARK: - MIDIPlayerDelegate
    func didReceiveNoteOnEvents(events: [MIDIEventNoteOn]) {
        print(events)
        print("\n")
    }


}
