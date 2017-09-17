//
//  AppDelegate.swift
//  JetType
//
//  Created by Steve Kerney on 9/5/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        // Insert code here to tear down your application
    }
    
    //MARK: Menu Actions
    @IBAction func resetHighScoreClicked(_ sender: Any)
    {
        UserDefaults.standard.set(0, forKey: "highScore");
        UserDefaults.standard.synchronize();
        guard let vc = NSApplication.shared().windows.first?.contentViewController as? ViewController else { return; }
        guard let vGameScene = vc.skView.scene as? GameScene else { return; }
        vGameScene.resetHighScore();
    }
}
