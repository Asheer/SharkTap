//
//  ViewController.m
//  Fish App
//
//  Created by Asheer Tanveer on 6/7/14.
//  Copyright (c) 2014 Asheer Tanveer. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "MainMenu.h"

@implementation ViewController


/*
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MainMenu sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}
*/

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    	
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [MainMenu sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
 		       // Present the scene.
        [skView presentScene:scene];
    }
}
- (BOOL)shouldAutorotate
{
    return NO;
}

-(BOOL) prefersStatusBarHidden {
    return YES;
    
}
- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
