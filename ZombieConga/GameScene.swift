//
//  GameScene.swift
//  ZombieConga
//
//  Created by ZhangChao on 15/10/1.
//  Copyright (c) 2015年 ZhangChao. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.whiteColor()
        let background = SKSpriteNode(imageNamed:"background1")
        self.addChild(background)
        background.position = CGPointMake(size.width/2, size.height/2)
        //background.zRotation = CGFloat(M_PI)/8
        
        background.zPosition = -1
        
        let zombie1 = SKSpriteNode(imageNamed: "zombie1")
        zombie1.position = CGPoint(x: 400, y: 400)
        self.addChild(zombie1)
    }
    

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
