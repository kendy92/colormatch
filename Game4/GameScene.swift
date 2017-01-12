//
//  GameScene.swift
//  Game4
//
//  Created by Dinh Cong Thang on 2016-12-26.
//  Copyright © 2016 Dinh Cong Thang. All rights reserved.
//  Du an Game Color Match

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct BodyMask {
        static let player: UInt32 = 0x1 << 1
        static let box: UInt32 = 0x1 << 2
    }

    
    //khai bao bien
    var player = SKShapeNode()
    var box = SKShapeNode()
    var smokeEffect = SKEmitterNode()
    
    var boxSizeW = 0
    var boxSizeH = 40
    var boxCol = 8
    var boxRow = 1
    var boxMargin = 10
    var offsetX = 10
    var isDie = false
    
    var restartBtn = SKSpriteNode()
    var scorelbl = SKLabelNode()
    var score = 0{
        didSet{
            scorelbl.text = "\(score)"
        }
    }
    
    func getRandomColor() -> UIColor{
        let colorArray = [UIColor.blue,UIColor.brown,UIColor.orange,UIColor.purple,UIColor.red,UIColor.white]
        let index:Int = Int(arc4random_uniform(UInt32(colorArray.count)))
        let randomColor = colorArray[index]
        return randomColor
    }
    
    func addSmokeEffect(){
        smokeEffect = SKEmitterNode(fileNamed: "smoke.sks")!
        smokeEffect.position = box.position
        smokeEffect.particleColor = box.fillColor
        self.addChild(smokeEffect)
    }
    
    func addBox(){
                box.name = "box"
                let randColor = getRandomColor()
                box = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 700, height: boxSizeH))
                box.position = CGPoint(x: 0, y: frame.size.height)
                box.fillColor = randColor
                box.strokeColor = UIColor.clear
                box.physicsBody = SKPhysicsBody(rectangleOf: box.frame.size)
                box.physicsBody?.affectedByGravity = false
                box.physicsBody?.isDynamic = false
                box.physicsBody?.categoryBitMask = BodyMask.box
                box.physicsBody?.contactTestBitMask = BodyMask.player
                box.physicsBody?.collisionBitMask = 0
                box.zPosition = 1
        self.addChild(box)
        
        let moveBox = SKAction.moveTo(y: -50, duration: TimeInterval(8.0))
        let removeBox = SKAction.removeFromParent()
        box.run(SKAction.sequence([moveBox,removeBox]))
    }
    
    func spawnBox(){
        let spawnBox = SKAction.run({
            () in self.addBox()
        })
        let delaySpawn = SKAction.wait(forDuration: TimeInterval(4.5))
        self.run(SKAction.repeatForever(SKAction.sequence([spawnBox,delaySpawn])))
        
    }

    
    func initScene(){
        
        self.physicsWorld.contactDelegate = self
        
        //add Score
        scorelbl.text = "0"
        scorelbl.fontSize = 50.0
        scorelbl.fontColor = UIColor.white
        scorelbl.position = CGPoint(x: frame.size.width/2, y: frame.size.height - 100)
        scorelbl.zPosition = 3
        self.addChild(scorelbl)
        
        //create player
        player = SKShapeNode(circleOfRadius: CGFloat(boxSizeH))
        player.position = CGPoint(x: frame.size.width/2, y: 50)
        player.fillColor = getRandomColor()
        player.strokeColor = UIColor.clear
       
        player.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(boxSizeH))
        player.physicsBody?.affectedByGravity = false
        //player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = BodyMask.player
        player.physicsBody?.contactTestBitMask = BodyMask.box
        player.physicsBody?.collisionBitMask = 0
        player.zPosition = 2
        self.addChild(player)
        spawnBox()
    }
    
    func createBtn(){
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width: 200, height: 100)
        restartBtn.position = CGPoint(x: frame.width/2, y: frame.height/2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    func restartGame(){
        self.removeAllActions()
        self.removeAllChildren()
        score = 0
        isDie = false
        initScene()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let nodeA = contact.bodyA.node as? SKShapeNode, let nodeB = contact.bodyB.node as? SKShapeNode {
            if nodeA.fillColor != nodeB.fillColor {
                enumerateChildNodes(withName: "box", using: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions()
                }))
                
                if(isDie == false){
                    isDie = true
                 self.run(SKAction.playSoundFileNamed("sound/break.wav", waitForCompletion: true))
                    createBtn()
                }
            }else{
                self.run(SKAction.playSoundFileNamed("sound/match.wav", waitForCompletion: true))
                score = score + 1
                addSmokeEffect()
                smokeEffect.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),SKAction.removeFromParent()]))
                box.removeFromParent()
                player.run(SKAction.moveBy(x: 0, y: 40, duration: TimeInterval(1.0)))
            }
        }
        
        
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.fillColor = getRandomColor()
        
        for touch in touches{
            let location = touch.location(in: self)
            
            if(isDie == true){
                if(restartBtn.contains(location)){
                    restartGame()
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
     self.run(SKAction.playSoundFileNamed("sound/bg_sound.mp3", waitForCompletion: true))
    initScene()

    }
    
    

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(player.position.y >= frame.size.height/2){
            player.position.y = frame.size.height/2
        }

    }
}
