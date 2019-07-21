//
//  ViewController.swift
//  PokemonAR
//
//  Created by IZUMIRU on 2019/07/16.
//  Copyright © 2019 IZUMIRU. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var onceExec = OnceExec()

    // ARSCNViewの設定
    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        // fps情報などを表示
        sceneView.showsStatistics = true
        // デバッグ用に特徴点を表示
        // sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        //Viewに初期化したsceneをセット
        sceneView.scene = SCNScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Sessionの設定
        let configuration = ARWorldTrackingConfiguration()
        // 検知対象を指定する。水平面。（.verticalは垂直面）
        configuration.planeDetection = .horizontal
        // 空間から光の情報を取得し画面上のライトの情報に適応
        configuration.isLightEstimationEnabled = true
        
        // 一度（3Dモデル1体）だけ表示する
        onceExec.call {
            // sessionをスタート
            sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // sessionをストップ
        sceneView.session.pause()
    }

    // ARSCNViewDelegateのメソッド
    // 平面を新たに検知した際に、呼ばれるrenderer(_:didAdd:for:)で、検知したNodeに3DオブジェクトのNodeを追加
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {fatalError()}
        //sceneとnodeを読み込み
        guard let scene = SCNScene(named: "model.scn", inDirectory: "art.scnassets/Raikou") else {fatalError()}
        guard let bearNode = scene.rootNode.childNode(withName: "SketchUp", recursively: true) else {fatalError()}

        // nodeのスケールを調整する
        let (min, max) = bearNode.boundingBox
        let w = CGFloat(max.x - min.x)
        // 0.1mを基準にした縮尺を計算
        let magnification = 0.1 / w
        bearNode.scale = SCNVector3(magnification, magnification, magnification)
        // nodeのポジションを設定
        bearNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)

        // 作成したノードを追加
        DispatchQueue.main.async(execute: {
            node.addChildNode(bearNode)
        })
    }
}

class OnceExec {
    var isExec = false
    func call(onceExec: ()->()){
        if !isExec {
            onceExec()
            isExec = true
        }
    }
}
