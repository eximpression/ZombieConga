//
//  GameScene.swift
//  ZombieConga
//
//  Created by ZhangChao on 15/10/1.
//  Copyright (c) 2015年 ZhangChao. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zomebieMovePointsPerSec:CGFloat = 480
    let catMovePointsPerSec: CGFloat = 480
    var velocity = CGPointZero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    
    let zomebieAnimation: SKAction
    
    var zombieBlink:Bool = false
    
    let catCollistionSound: SKAction = SKAction.playSoundFileNamed("hitCat", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady", waitForCompletion: false)
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableHeight = size.width/maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        self.playableRect = CGRectMake(0.0, playableMargin, size.width, playableHeight)
        
        var textures:[SKTexture] = []
        for i in 1...4{
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        
        zomebieAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        super.init(size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        //playableRect = CGRectZero
        //super.init(coder: aDecoder)
        fatalError("not implementation ")
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed:"background1")
        self.addChild(background)
        background.position = CGPointMake(size.width/2, size.height/2)
        //background.zRotation = CGFloat(M_PI)/8
        
        background.zPosition = -1
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        self.addChild(zombie)
        self.debugDrawPlayableArea()
        self.runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(4.0)])))
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnCat),SKAction.waitForDuration(1.0)])))
        
    }
    

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastUpdateTime > 0{
            dt = currentTime - lastUpdateTime
        }
        else{
            dt = 0
        }
        lastUpdateTime = currentTime
    
        if let lastTouchLocation = self.lastTouchLocation{
            
            //self.moveSprite(zombie, velocity: velocity)
            if (zombie.position - lastTouchLocation).length() >  (velocity * CGFloat(dt)).length(){
                self.rotateSprite(zombie, direction: velocity,rotateRadiansPerSec: zombieRotateRadiansPerSec)
                self.moveSprite(zombie, velocity: velocity)
                self.boundsCheckSprite(zombie)
            }
            else{
                zombie.position = lastTouchLocation
                velocity = CGPointZero
                stopZombieAnimation()
            }
        }
        moveTrain()

    }
    
    override func didEvaluateActions() {
        super.didEvaluateActions()
        self.checkCollisions()
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = velocity * CGFloat(dt) // CGPoint(x: velocity.x * CGFloat(dt), y: velocity.y * CGFloat(dt))
        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove//CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }

    
    func sceneTouched(touchLocation:CGPoint){
        moveSpriteToward(zombie, location: touchLocation)
    }
    
    func moveSpriteToward(sprite: SKSpriteNode, location: CGPoint){
        startZombieAnimation()
        let offset =  location - sprite.position//CGPoint(x: location.x-sprite.position.x, y: location.y-sprite.position.y)
        let distance = offset.length() //sqrt(pow(offset.x,2)+pow(offset.y,2))
        let unit =  offset / distance //CGPoint(x: offset.x/distance, y: offset.y/distance)
        velocity = unit * zomebieMovePointsPerSec //CGPointMake(zomebieMovePointsPerSec * unit.x, zomebieMovePointsPerSec * unit.y)
        
        
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        // Your code here!
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    func boundsCheckSprite(sprite: SKSpriteNode)
    {
        let bottomLeft = CGPointMake(0, CGRectGetMinY(self.playableRect))
        let topRight = CGPointMake(self.size.width,CGRectGetMaxY(self.playableRect) )
        
        if sprite.position.x <= bottomLeft.x{
            sprite.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if sprite.position.x >= topRight.x{
             zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if sprite.position.y <= bottomLeft.y{
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if sprite.position.y >= topRight.y{
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
        
    }
    
    func debugDrawPlayableArea(){
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, self.playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 14.0
        addChild(shape)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let touch = touches.first!
        self.lastTouchLocation = touch.locationInNode(self)
        self.sceneTouched(self.lastTouchLocation!)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        let touch = touches.first!
        self.lastTouchLocation = touch.locationInNode(self)
        self.sceneTouched(self.lastTouchLocation!)
    }
    
    func spawnEnemy(){
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height/2, max: CGRectGetMaxY(playableRect) - enemy.size.height/2))
        enemy.name = "enemy"
        self.addChild(enemy)
        let actionRemove = SKAction.removeFromParent()
        let actionMove =
            SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        enemy.runAction(SKAction.sequence([actionMove,actionRemove]))
        
        
    }
    
    func spawnCat(){
        let cat  = SKSpriteNode(imageNamed: "cat")
        cat.position = CGPointMake(CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxX(playableRect)))
        cat.setScale(0)
        cat.name = "cat"
        addChild(cat)

        let appear = SKAction.scaleTo(1.0, duration: 3)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle =  leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle,rightWiggle])
        //let wiglleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp,scaleDown,scaleUp,scaleDown])
        let group = SKAction.group([fullScale,fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
            
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear,groupWait, disappear,removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    func startZombieAnimation(){
        if zombie.actionForKey("animation") == nil{
            zombie.runAction(zomebieAnimation, withKey: "animation")
        }
    }
    
    func stopZombieAnimation(){
        zombie.removeActionForKey("animation")
    }
    
    func zombieHitCat(cat: SKSpriteNode){
        self.runAction(catCollistionSound)
        cat.removeFromParent()
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode){
        self.zombieBlink = true
        self.runAction(enemyCollisionSound)
        //enemy.removeFromParent()
        blinkSprite(zombie)
        
    }
    
    func blinkSprite(sprite: SKSpriteNode)
    {
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) {
            node , elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        sprite.runAction(blinkAction){
            [unowned self] in
            self.zombieBlink = false
        }
    }
    
    func checkCollisions(){
        
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat"){
            node, _ in
            let cat  = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame){
                hitCats.append(cat)
            }
        }
        for cat in hitCats{
            //zombieHitCat(cat)
            changCatToTrain(cat)
        }
        if self.zombieBlink == false {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy"){
                node, _ in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(CGRectInset(enemy.frame, 20, 20), self.zombie.frame){
                    hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies{
                zombieHitEnemy(enemy)
            }
        }
    }
    
    func changCatToTrain(cat:SKSpriteNode){
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        cat.runAction(SKAction.sequence([
            SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2),
            //SKAction.colorizeWithColorBlendFactor(0.0, duration: 1.0)
            ]))
       
    }
    
    func moveTrain() {
        
        var targetPosition = zombie.position
        
        enumerateChildNodesWithName("train") { node, stop in
            if !node.hasActions() {
                
                let actionDuration = 0.1
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
            
        }
    }
    
}
