//
//  GameViewController.swift
//  ios-spritekit-flappy-flying-bird
//
//  Created by Astemir Eleev on 02/05/2018.
//  Copyright © 2018 Astemir Eleev. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

enum Scenes: String {
    case title = "TitleScene"
    case game = "GameScene"
    case setting = "SettingsScene"
    case score = "ScoreScene"
    case pause = "PauseScene"
    case failed = "FailedScene"
    case characters = "CharactersScene"
}

extension Scenes {
    func getName() -> String {
        let padId = " iPad"
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        return isPad ? self.rawValue + padId : self.rawValue
    }
}

enum NodeScale: Float {
    case gameBackgroundScale
}

extension NodeScale {
    
    func getValue() -> Float {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        switch self {
        case .gameBackgroundScale:
            return isPad ? 1.5 : 1.25
        }
    }
}

extension CGPoint {
    init(x: Float, y: Float) {
        self.init()
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}


class GameViewController: UIViewController {

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneName = Scenes.title.getName()
        
        if let scene = SKScene(fileNamed: sceneName) as? TitleScene {

            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFit
            
            // Present the scene
            if let view = self.view as! SKView? {
                view.presentScene(scene)
                
                view.ignoresSiblingOrder = true
//                view.showsFPS = true
//                view.showsNodeCount = true
//                view.showsPhysics = true
            }
        }
        HolyCentralManager.shared.delegate = self
        GlobalVariables.GVCp = self
        GlobalVariables.queue.async {
            if GlobalVariables.isConnected { return }
            print("Searching for the first sensor...")
            while HolyCentralManager.shared.centralManager.state != .poweredOn {
                usleep(10)
            }
            HolyCentralManager.shared.startScan()
            while !GlobalVariables.isConnected {
                usleep(10)
            }
            HolyCentralManager.shared.stopScan()
            print("Successfully bound!")
            while !(GlobalVariables.device!.turnOn()) {
                //print("Failed to activate the sensor!")
                usleep(100)
            }
            print("Sensor online")
            _ = GlobalVariables.device!.turnOn()
            if GlobalVariables.device == nil {
                print("Something didn't make sense")
            }
            GlobalVariables.device!.requestSensorsReadiness()
            GlobalVariables.GVCp!.bind(GlobalVariables.device!)
            GlobalVariables.device?.setNotifyValue(true, for: SensorType.accelerometer)
            GlobalVariables.device?.setNotifyValue(true, for: SensorType.gyroscope)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: HolyCentralManagerProtocol {
    func detected(device: HolyDevice) {
        print("Sensor detected")
        device.connect()
        GlobalVariables.device = device
    }
    
    func connected(_ deviceId: String) {
        print("Sensor connected")
        GlobalVariables.isConnected = true
    }
    
    func disconnected(_ deviceId: String) {
        print("Sensor disconnected")
        GlobalVariables.isConnected = false
        GlobalVariables.device = nil
    }
    
    func bluetoothPoweredOff() {
        
    }
}

extension GameViewController: HolyDeviceProtocol {
    func holyDevice(_ holyDevice: HolyDevice, didReceiveAccData data: AccelerometerData) {
        if data.z < -1.1 && false {
            print("Do not touch me!")
            GlobalVariables.isTriggered = true
        }
    }
    
    func holyDevice(_ holyDevice: HolyDevice, didReceiveGyroData data: GyroscopeData) {
        if (data.x > 130 || data.y>130 || data.z>130) && true {
            print("Do not touch me")
            GlobalVariables.isTriggered = true
        }
    }
    
    func holyDevice(_ holyDevice: HolyDevice, didReceiveMagnetoData data: MagnetometerData) {
        print("Do not touch me")
    }
    
    func holyDevice(_ holyDevice: HolyDevice, didReceiveBarometerValue value: Int) {
        print("Do not touch me")
    }
    
    func holyDevice(_ holyDevice: HolyDevice, didReceiveHumidityValue value: Float) {
        print("Do not touch me")
    }
    
    func holyDevice(_ holyDevice: HolyDevice, didReceiveTemperatureValue value: Float) {
        print("Do not touch me")
    }
    
    func holyDevice(_ holyDevice: HolyDevice, didReceiveSFLData data: SFLData) {
        print("Do not touch me")
    }
    
    func connected(_ holyDevice: HolyDevice) {
        // do nothing
    }
    
    func disconnected(_ holyDevice: HolyDevice) {
        // do nothing
    }
    
    func sensorReady(_ holyDevice: HolyDevice, sensorType: SensorType) {
        print("I'm ready")
    }
    
    func bind(_ device: HolyDevice) {
        device.delegate = self
    }
}
