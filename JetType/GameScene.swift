//
//  GameScene.swift
//  JetType
//
//  Created by Steve Kerney on 9/5/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //Game Nodes
    var player: SKSpriteNode?;
    var playerFireSFX: SKNode?;
    
    //UI Nodes
    var startButton: SKSpriteNode?;
    var characterLabel : SKLabelNode?
    var highScoreLabel: SKLabelNode?;
    var scoreLabel: SKLabelNode?;
    var score: Int = 0
    {
        didSet
        {
            scoreLabel?.text = "Score: \(score)";
        }
    }
    
    //Collision Bitmasks
    let playerCategoryBitMask: UInt32 = 2;
    let spikesCategoryBitMask: UInt32 = 3;
    
    //Gameplay
    let jumpPower = 200;
    let difficultyScalar = 2;
    let playerStartPos = CGPoint(x: 200, y: 500);
    var currChar: String = ""
    {
        didSet
        {
            characterLabel?.text = "\(currChar.uppercased())";
        }
    }
    var currKeyCode: Int?;
    
    //Input
    let characters = ["Click!","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","0","1","2","3","4","5","6","7","8","9"];
    let keycodes = [-1,0x00,0x0B,0x08,0x02,0x0E,0x03,0x05,0x04,0x22,0x26,0x28,0x25,0x2E,0x2D,0x1F,0x23,0x0C,0x0F,0x01,0x11,0x20,0x09,0x0D,0x07,0x10,0x06,0x1D,0x12,0x13,0x14,0x15,0x17,0x16,0x1A,0x1C,0x19];
    
    override func didMove(to view: SKView)
    {
        initScene();
    }
}

//MARK: Physics
extension GameScene
{
    func didBegin(_ contact: SKPhysicsContact)
    {
        let bodyA = contact.bodyA;
        let bodyB = contact.bodyB;
        
        if bodyA.categoryBitMask == spikesCategoryBitMask || bodyB.categoryBitMask == spikesCategoryBitMask
        {
            endGame();
        }
    }
}

//MARK: Input Funcs
extension GameScene
{
    //Keyboard
    override func keyDown(with event: NSEvent)
    {
        let eventKeyCode = event.keyCode;
        guard let vCurrKeyCode = currKeyCode else { return; }
        
        if vCurrKeyCode >= 0
        {
            switch eventKeyCode
            {
            //Spacebar
            case UInt16(vCurrKeyCode):
                jump();
            default:
                break;
            }
        }
    }
    
    //Mouse
    override func mouseDown(with event: NSEvent)
    {
        let clickLocation = event.location(in: self);
        let returnedNodes = nodes(at: clickLocation);
        
        for node in returnedNodes
        {
            if node.name == "startButton"
            {
                startGame();
            }
        }
        
        guard currKeyCode == -1 else { return; }
        jump();
    }
}

//MARK: Helper Funcs
extension GameScene
{
    fileprivate func initScene()
    {
        //GameObjects
        player = self.childNode(withName: "player") as? SKSpriteNode;
        playerFireSFX = self.childNode(withName: "playerDeathSFX");
        playerFireSFX?.alpha = 0.0;
        
        //UI
        startButton = self.childNode(withName: "//startButton") as? SKSpriteNode;
        scoreLabel = self.childNode(withName: "//currScore") as? SKLabelNode;
        highScoreLabel = self.childNode(withName: "//highScore") as? SKLabelNode
        highScoreLabel!.text? = fetchHighScore();
        characterLabel = self.childNode(withName: "//characterLabel") as? SKLabelNode
        characterLabel!.alpha = 0.0;
        
        //Scene
        physicsWorld.contactDelegate = self;
    }
    
    fileprivate func generateNextKey()
    {
        let randomIndex = Int(arc4random_uniform(UInt32(characters.count)));
        currChar = characters[randomIndex];
        currKeyCode = keycodes[randomIndex];
    }
    
    fileprivate func jump()
    {
        guard let vPlayer = player else { return; }
        vPlayer.physicsBody?.applyImpulse(CGVector(dx: 0, dy: (jumpPower - (score * difficultyScalar))));
        score += 1;
        generateNextKey();
    }
    
    fileprivate func startGame()
    {
        score = 0;
        generateNextKey();
        guard let vCharacterLabel = characterLabel else { return; }
        vCharacterLabel.alpha = 1.0;
        
        guard let vPlayer = player else { return; }
        vPlayer.position = playerStartPos;
        vPlayer.isHidden = false;
        vPlayer.physicsBody?.pinned = false;
        vPlayer.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100));
        
        guard let vPlayerDeathSFX = playerFireSFX else { return; }
        vPlayerDeathSFX.alpha = 0.0;
        
        guard let vStartButton = startButton else { return; }
        vStartButton.removeFromParent();
    }
    
    fileprivate func endGame()
    {
        updateHighScore();
        currChar = "";
        currKeyCode = nil;
        guard let vCharacterLabel = characterLabel else { return; }
        vCharacterLabel.alpha = 0.0;
        
        guard let vPlayer = player else { return; }
        vPlayer.physicsBody?.pinned = true;
        vPlayer.isHidden = true;
        
        guard let vPlayerDeathSFX = playerFireSFX else { return; }
        vPlayerDeathSFX.alpha = 1.0;
        
        guard let vStartButton = startButton else { return; }
        guard vStartButton.parent != self else { return; }
        addChild(vStartButton);
    }
    
    fileprivate func updateHighScore()
    {
        let currHighScore = UserDefaults.standard.integer(forKey: "highScore");
        guard score > currHighScore else { return; }
        UserDefaults.standard.set(score, forKey: "highScore");
        UserDefaults.standard.synchronize();
        
        guard let vHighScoreLabel = highScoreLabel else { return; }
        vHighScoreLabel.text? = "High Score: \(score)";
    }
    
    fileprivate func fetchHighScore() -> String
    {
        let currHighScore = UserDefaults.standard.integer(forKey: "highScore");
        return "High Score: \(currHighScore)";
    }
    
    func resetHighScore()
    {
        let fetchedScore = fetchHighScore();
        guard let vHighScoreLabel = highScoreLabel else { print("not yet init"); return; }
        vHighScoreLabel.text? = "\(fetchedScore)";
    }
}
