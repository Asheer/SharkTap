//
//  GameOver.m
//  Fish App
//
//  Created by Asheer Tanveer on 6/7/14.
//  Copyright (c) 2014 Asheer Tanveer. All rights reserved.
//

#import "GameOver.h"
#import "MyScene.h"
#import "MainMenu.h"
#import <AVFoundation/AVFoundation.h>
#import <Social/Social.h>


@interface GameOver()
@property (nonatomic) SKSpriteNode *background;
@property (nonatomic) SKLabelNode *bestScoreEver;
@property (nonatomic) SKSpriteNode *gameOver;
@property (nonatomic) SKSpriteNode *retry;
@property (nonatomic) SKSpriteNode *done;
@property (nonatomic) SKSpriteNode *bestMenu;
@property (nonatomic) SKAction *moveFish;
@property (nonatomic) SKAction *moveMenu;
@property (nonatomic) SKSpriteNode *fish;
@property (nonatomic) NSString *scoreString;
@property (nonatomic) NSString *bestString;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *bestScoreLabel;
@property (nonatomic) AVAudioPlayer *player;
@end

@implementation GameOver

-(instancetype) initWithSize:(CGSize)size {
    
    if(self == [super initWithSize:size]) {

        self.background = [SKSpriteNode spriteNodeWithImageNamed:@"underwater"];
        self.background.size = CGSizeMake(self.size.width, self.size.height);
        self.background.position = CGPointMake(self.size.width/2,self.size.height/2);
        [self addChild:self.background];
       
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    
    self.scoreString = [self.userData valueForKey:@"score"];
    self.bestString = [self.userData valueForKey:@"bestscore"];
    
    [self gameOverStuff];
    [self addFish:self.size];
}


-(void) gameOverStuff {
    
    [self best];
    
    self.gameOver = [SKSpriteNode spriteNodeWithImageNamed:@"gameover.png"];

    self.done = [SKSpriteNode spriteNodeWithImageNamed:@"Done.png"];

    self.retry = [SKSpriteNode spriteNodeWithImageNamed:@"Retry.png"];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.gameOver.size = CGSizeMake(self.gameOver.size.width + 400, self.gameOver.size.height + 100);
        self.gameOver.position = CGPointMake(self.size.width/2,self.size.height - 80);
        self.done.size = CGSizeMake(200, 50);
        self.retry.size = CGSizeMake(200, 50);
        self.done.position = CGPointMake(self.bestMenu.position.x - 80, self.bestMenu.position.y + 240);
    } else {
        self.done.position = CGPointMake(self.bestMenu.position.x - 40, self.bestMenu.position.y + 180);
        self.gameOver.position = CGPointMake(self.size.width/2,self.size.height - 40);
    }
    
    self.retry.position = CGPointMake(self.done.position.x + self.done.size.width, self.done.position.y);
    
    [self addChild:self.gameOver];
    [self addChild:self.done];
    [self addChild:self.retry];
}

-(void) addFish:(CGSize)size{
    
    self.fish = [SKSpriteNode spriteNodeWithImageNamed:@"fish.png"];
    self.fish.position = CGPointMake(self.retry.position.x - 10, self.retry.position.y + 260);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.fish.size = CGSizeMake(158, 160);
            self.moveFish = [SKAction moveToY:self.retry.position.y + 80 duration:1.0];
    }else
    {
        self.fish.size = CGSizeMake(70, 76);
            self.moveFish = [SKAction moveToY:self.retry.position.y + 50 duration:1.0];
    }
    

    [self.fish runAction:self.moveFish];
    
    [self addChild:self.fish];
}

-(void) best {
    
    self.bestMenu = [SKSpriteNode spriteNodeWithImageNamed:@"bestScore.png"];

    self.bestMenu.position = CGPointMake(self.size.width/2, -50);
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPS-BoldItalicMT"];
    self.scoreLabel.text = self.scoreString;
    self.scoreLabel.fontColor = [SKColor redColor];
    
    self.scoreLabel.zPosition = 200;
    self.scoreLabel.position = CGPointMake(62, -10);
    
    self.bestScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Verdana-BoldItalic"];
    self.bestScoreLabel.text = self.bestString;
    self.bestScoreLabel.position = CGPointMake(240, 0);
    self.bestScoreLabel.fontColor = [SKColor blueColor];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        SKAction *moveScore = [SKAction moveToY:self.size.height/2 + 40 duration:0.7];
        SKAction *moveBestScore = [SKAction moveToY:self.size.height/2 + 40 duration:0.9];
        self.moveMenu = [SKAction moveToY:self.size.height/2 + 40 duration:0.5];
        self.bestMenu.size = CGSizeMake(720, 400);
        self.scoreLabel.fontSize = 60;
        self.bestScoreLabel.fontSize = 50;
        self.scoreLabel.position = CGPointMake(160, -10);
        self.bestScoreLabel.position = CGPointMake(570, 0);
        [self.scoreLabel runAction:moveScore];
        [self.bestScoreLabel runAction:moveBestScore];
    }else
    {
        SKAction *moveScore = [SKAction moveToY:self.size.height/2 + 20 duration:0.7];
        SKAction *moveBestScore = [SKAction moveToY:self.size.height/2 + 20 duration:0.9];
        self.moveMenu = [SKAction moveToY:self.size.height/2 + 20 duration:0.5];
        self.bestMenu.size = CGSizeMake(300, 160);
        self.scoreLabel.fontSize = 30;
        self.bestScoreLabel.fontSize = 30;
        self.scoreLabel.position = CGPointMake(62, -10);
        self.bestScoreLabel.position = CGPointMake(240, 0);
        [self.scoreLabel runAction:moveScore];
        [self.bestScoreLabel runAction:moveBestScore];
    }
    
    [self.bestMenu runAction:self.moveMenu];
    
    [self addChild:self.bestMenu];
    [self addChild:self.scoreLabel];
    [self addChild:self.bestScoreLabel];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    if ([self.done containsPoint:location]) {
        MainMenu *firstScene = [MainMenu sceneWithSize:self.size];
        [self.view presentScene:firstScene transition:[SKTransition doorsOpenHorizontalWithDuration:2.0]];
    }
    
    if ([self.retry containsPoint:location]) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"water" ofType:@"mp3"]];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [self.player play];
        MyScene *retryScene= [MyScene sceneWithSize:self.size];
        [self.view presentScene:retryScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.6]];
    }
}



@end

