//
//  MyScene.m
//  Fish App
//
//  Created by Asheer Tanveer on 6/7/14.
//  Copyright (c) 2014 Asheer Tanveer. All rights reserved.
//

#import "MyScene.h"
#import "MainMenu.h"
#import "GameOver.h"
#import <AVFoundation/AVFoundation.h>

@interface MyScene() 

@property (nonatomic) SKSpriteNode *fish;
@property (nonatomic) SKSpriteNode *shark;
@property (nonatomic) NSString *sharkFile;
@property (nonatomic) SKSpriteNode *powerFishy;
@property (nonatomic) SKSpriteNode *waterGun;
@property (nonatomic) SKSpriteNode *readyLabel;
@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *liveLabel;
@property (nonatomic) SKLabelNode *tap;
@property (nonatomic) SKSpriteNode *bg1;
@property (nonatomic) SKSpriteNode *bg2;
@property (nonatomic) AVAudioPlayer *player;

@property (nonatomic) CGFloat distance;                 // distance between fish and shark
@property (nonatomic) BOOL fishyPower;
@property (nonatomic) BOOL changeTimer;
@property (nonatomic) BOOL incBack;
@property (nonatomic) BOOL changeSharks;
@property (nonatomic) int powerCount;
@property (nonatomic) int rand;
@property (nonatomic,strong) NSMutableArray *sharks;    // original container for sharks

@property (nonatomic) NSTimer *timer;

@property (nonatomic) int incShark;
@property (nonatomic) int score;
@property (nonatomic) int currentScore;
@property (nonatomic) int bestScore;
@property (nonatomic) int numOfLives;
@property (nonatomic) int range;

@end

static const uint32_t fishCategory = 1;
static const uint32_t sharkCategory = 2;
static const uint32_t powerCategory = 4;
static const uint32_t waterCategory = 8;

@implementation MyScene

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.bg1 = [SKSpriteNode spriteNodeWithImageNamed:@"underwater.png"];
        self.bg2 = [SKSpriteNode spriteNodeWithImageNamed:@"underwater.png"];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self ipadSettings];
            self.range = 200;
        } else {
             self.range = 100;
        }
        
        self.bg1.anchorPoint = CGPointZero;
        self.bg1.position = CGPointMake(0, 0);
        [self addChild:self.bg1];
        
        self.bg2.anchorPoint = CGPointZero;
        self.bg2.position = CGPointMake(self.bg1.size.width-1, 0);
        [self addChild:self.bg2];
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.sharks = [[NSMutableArray alloc]init];
        self.score = 0;
        self.numOfLives = 1;
        
        self.powerCount = 8;
       
        self.bestScore = [[NSUserDefaults standardUserDefaults] integerForKey: @"highScore"];
        self.fishyPower = NO;
        self.sharkFile = @"shark";
       	
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.7 target:self selector:@selector(addShark) userInfo:nil repeats:YES];
        
        [self addFish:size];
        [self createReadyLabel];
        [self createTapLabel];
        [self createScoreLabel];
        [self createLiveLabel];
        [self performSelector:@selector(addShark) withObject:nil afterDelay:1.9];
        [self performSelector:@selector(removeReadyLabel) withObject:nil afterDelay:1.5];
        [self performSelector:@selector(removeTapLabel) withObject:nil afterDelay:1.6];
    }
    
    return self;
}

- (void) changeScene
{
    [self.view setUserInteractionEnabled:YES];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameover" ofType:@"caf"]];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [self.player play];
    SKTransition *reveal = [SKTransition moveInWithDirection:SKTransitionDirectionDown duration:0.5];
    SKView * skView = (SKView *)self.view;
    SKScene *secondScene = [GameOver sceneWithSize:skView.bounds.size];
    secondScene.userData = [NSMutableDictionary dictionary];
    [secondScene .userData setObject:[NSString stringWithFormat:@"%i",self.score] forKey:@"score"];
   
    if(self.score > self.bestScore) {
        self.bestScore = self.score;
        [self saveScore];
    }
    
    [secondScene .userData setObject:[NSString stringWithFormat:@"%i",self.bestScore] forKey:@"bestscore"];
    secondScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.scene.view presentScene: secondScene transition:reveal];
}

-(void) createScoreLabel {
    
    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPS-BoldItalicMT"];
    self.scoreLabel.text = [NSString stringWithFormat:@"%i",self.score];
  
    self.scoreLabel.fontColor = [SKColor greenColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.scoreLabel.fontSize = 70;
          self.scoreLabel.position = CGPointMake(self.frame.size.width/2,self.frame.size.height - 60);
    }else
    {
        self.scoreLabel.fontSize = 30;
          self.scoreLabel.position = CGPointMake(self.frame.size.width/2,self.frame.size.height - 36);
    }
    
    
    [self addChild:self.scoreLabel];
}

-(void) createTapLabel {
    
    self.tap = [SKLabelNode labelNodeWithFontNamed:@"TimesNewRomanPS-BoldItalicMT"];
    self.tap.text = @"tap near sharks!";
    
    self.tap.fontColor = [SKColor orangeColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.tap.fontSize = 50;
        self.tap.position = CGPointMake(self.readyLabel.position.x,self.readyLabel.position.y - 118);
    }else
    {
        self.tap.fontSize = 25;
        self.tap.position = CGPointMake(self.readyLabel.position.x,self.readyLabel.position.y - 84);
    }
    
    
    [self addChild:self.tap];
}

-(void) removeTapLabel {
    [self.tap removeFromParent];
}


-(void)saveScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.bestScore forKey:@"highScore"];
    [defaults synchronize];
}

-(void) ipadSettings {
    
    self.bg1.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    self.bg2.size = CGSizeMake(self.frame.size.width,self.frame.size.height);
}

-(void) createLiveLabel {
    
    self.liveLabel = [SKLabelNode labelNodeWithFontNamed:@"ArialMT"];
    self.liveLabel.text = [NSString stringWithFormat:@"Lives: %i",self.numOfLives];
    self.liveLabel.fontColor = [SKColor blueColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.liveLabel.fontSize = 35;
        self.liveLabel.position = CGPointMake(66, self.frame.size.height - 35);
    }else
    {
        self.liveLabel.fontSize = 20;
        self.liveLabel.position = CGPointMake(36, self.frame.size.height - 20);
    }
    
    [self addChild:self.liveLabel];
}

-(void) createReadyLabel {
    self.readyLabel = [SKSpriteNode spriteNodeWithImageNamed:@"ready.png"];
    self.readyLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + 40);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.readyLabel.size = CGSizeMake(200,70);
    }
    
    [self addChild:self.readyLabel];
}

-(void) removeReadyLabel {
    [self.readyLabel removeFromParent];
}

-(void) removeFish {
    [self.fish removeFromParent];
}

-(void) addFish:(CGSize)size{
    
    self.fish = [SKSpriteNode spriteNodeWithImageNamed:@"fish"];
    self.fish.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
    
       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.fish.size = CGSizeMake(158, 160);
    }else
    {
        self.fish.size = CGSizeMake(70, 76);
    }

    self.fish.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.fish.frame.size];
    self.fish.physicsBody.categoryBitMask = fishCategory;
    self.fish.physicsBody.contactTestBitMask = sharkCategory | powerCategory;
    self.fish.physicsBody.dynamic = NO;
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"fish.atlas"];
    NSArray *orbiImageNames = [atlas textureNames];                     // name of files, not objects
    NSArray *sortedNames = [orbiImageNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *orbTextures = [NSMutableArray array];
    for(NSString *filename in sortedNames) {
        SKTexture *texture = [atlas textureNamed:filename];
        [orbTextures addObject:texture];
        
    }
    SKAction * swim = [SKAction animateWithTextures:orbTextures timePerFrame:0.2];
    SKAction *keepSwimming = [SKAction repeatActionForever:swim];
    [self.fish runAction:keepSwimming];
    
    [self addChild:self.fish];
}


-(void) createPowerFishy {
    self.powerFishy = [SKSpriteNode spriteNodeWithImageNamed:@"fish_friend"];
    self.powerFishy.physicsBody.dynamic = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.powerFishy.size = CGSizeMake(70, 95);
    } else
    {
         self.powerFishy.size = CGSizeMake(35, 55);
    }
   
    self.powerFishy.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.powerFishy.size.width/2];
    self.powerFishy.position = CGPointMake(self.frame.size.width - 20, arc4random_uniform(self.size.height - 20));
    self.powerFishy.physicsBody.categoryBitMask = powerCategory;
    self.powerFishy.name = @"fishy";
    
    [self addChild:self.powerFishy];
}

-(void) createWaterGun {
    
    self.waterGun = [SKSpriteNode spriteNodeWithImageNamed:@"Watergun.png"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
         self.waterGun.size = CGSizeMake(80, 80);
    }else
    {
         self.waterGun.size = CGSizeMake(60, 60);
    }
   
    self.waterGun.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.waterGun.frame.size];
    self.waterGun.physicsBody.categoryBitMask = waterCategory;
    self.waterGun.physicsBody.contactTestBitMask = sharkCategory;
    self.waterGun.physicsBody.dynamic = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
           self.waterGun.position = CGPointMake(self.fish.position.x + 90,self.fish.position.y - 45);
    }else
    {
          self.waterGun.position = CGPointMake(self.fish.position.x + 58,self.fish.position.y - 20);
    }
 
    self.waterGun.name = @"water";
    
    [self addChild:self.waterGun];
}

-(void) addShark {
  
    for(int i = 1; i <= self.incShark; i++) {
        self.shark = [SKSpriteNode spriteNodeWithImageNamed:self.sharkFile];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ! self.changeSharks)
        {
            self.shark.size = CGSizeMake(160, 180);
        }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && !self.changeSharks)
        {
              self.shark.size = CGSizeMake(80,100);
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.changeSharks)
        {
            self.shark.size = CGSizeMake(180, 200);
        }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.changeSharks)
        {
            self.shark.size = CGSizeMake(100,120);
        }
        
      
        self.shark.position = CGPointMake(self.frame.size.width - 14, arc4random_uniform(self.size.height - 20));
        self.shark.physicsBody.dynamic = NO;
        self.shark.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.shark.size.width/4];
        self.shark.physicsBody.categoryBitMask = sharkCategory;
        [self.sharks addObject:self.shark];
        
        [self addChild:self.shark];
    }
}

-(void) didBeginContact:(SKPhysicsContact *)contact {

    SKPhysicsBody *notTheFish;
    
    if(contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        notTheFish = contact.bodyB;
        
    }
    else {
        notTheFish = contact.bodyA;
    }
    
    if(notTheFish.categoryBitMask == sharkCategory && self.numOfLives == 1) {
        [self.view setUserInteractionEnabled:NO];
        [self performSelector:@selector(removeFish) withObject:nil afterDelay:.1];
        [self performSelector:@selector(changeScene) withObject:nil afterDelay:.2];
    }
    
    if(notTheFish.categoryBitMask == sharkCategory && self.numOfLives >=2) {
        [self.liveLabel removeFromParent];
        self.numOfLives--;
        [self createLiveLabel];
    }
    
    if(notTheFish.categoryBitMask == powerCategory) {
        
        [self.liveLabel removeFromParent];
        self.numOfLives++;
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"lifeup" ofType:@"wav"]];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        [self.player play];
        [self createLiveLabel];
        [self enumerateChildNodesWithName:@"fishy" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
    }
}

-(void) createMoreSharks:(int)num {
    
    for(int i = 1; i <= num; i++) {
        self.shark = [SKSpriteNode spriteNodeWithImageNamed:self.sharkFile];
        self.shark.size = CGSizeMake(40,60);
        
        self.shark.position = CGPointMake(self.frame.size.width - 20, arc4random_uniform(self.size.height - 10));
        
        self.shark.physicsBody.dynamic = NO;
        self.shark.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.shark.size.width/4];
        self.shark.physicsBody.categoryBitMask = sharkCategory;
        
        self.shark.name = [NSString stringWithFormat:@"sharkNumber%li", (long)i];
        
        [self.sharks addObject:self.shark];

        [self addChild:self.shark];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for(UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        CGPoint newPosition = CGPointMake(self.frame.size.width/4 ,location.y);
     
        if(newPosition.y < self.fish.size.height /2) {
            newPosition.y = self.fish.size.height/2;
        }
        
        if(newPosition.y > self.size.height - (self.fish.size.height/2)) {
            newPosition.y = self.size.height - (self.fish.size.height/2);
        }
        
        self.fish.position = newPosition;
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self enumerateChildNodesWithName:@"water" usingBlock:^(SKNode *node, BOOL *stop) {   // goes through waterguns and removes!
        [node removeFromParent];
    }];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self enumerateChildNodesWithName:@"water" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    SKSpriteNode *node;
    
    for(NSInteger i = 0; i < self.sharks.count; i++) {
        
        node = [self.sharks objectAtIndex:i];
        self.distance = SDistanceBetweenPoints(self.fish.position,node.position);
        if(self.distance < self.range) {
            [self.scoreLabel removeFromParent];
            SKAction *sound = [SKAction playSoundFileNamed:@"sharkhit.caf" waitForCompletion:NO];
            [self.scene runAction:sound];

            self.score +=1;
            self.currentScore = self.score;
            if(self.score % self.powerCount == 0) {
                [self createPowerFishy];
            }
            
            if(self.score == 30) {
                [self createMoreSharks:4];
            }
            
            if(self.score >= 34 && self.score <= 40) {
                [self createMoreSharks:2];
            }
            
            [self createScoreLabel];
            [self createWaterGun];
            [node removeFromParent];
            [self.sharks removeObjectAtIndex:i];
        }
     }
}

CGFloat SDistanceBetweenPoints(CGPoint first, CGPoint second) {
    return hypotf(second.x - first.x, second.y - first.y);
}

-(void) sharkMovement {
    
    if(self.score >= 0 && self.score <= 2) {
        
        if(self.shark.position.y > self.fish.position.y)
            [self.waterGun removeFromParent];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.incShark = 3 + arc4random() % (4 - 3 + 1);
        }
        else
            self.incShark = 3 + arc4random() % (4 - 3 + 1);
  
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                pos.x-=3.5;
            } else {
                pos.x-=1.5;
            }
            
            node.position = pos;
        }
    }
    
    if(self.score > 2  && self.score <= 5) {
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                pos.x-=4;
            } else {
                pos.x-=2.5;
            }
            
            node.position = pos;
        }
    }
    
    if(self.score >=14) {
        int rand = (0+arc4random() & 1);
        if(rand == 0)
            self.sharkFile = @"shark2";
        else
            self.sharkFile = @"shark";
    }
    
    if(self.score > 5 && self.score < 12) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.incShark = 4 + arc4random() % (5 - 3 + 1);
        }
       
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                pos.x-=7.5;
            } else {
                pos.x-=4.6;
            }
            
            node.position = pos;
            //[self.sharks replaceObjectAtIndex:i withObject:node];
        }
    }
    
    if(self.score >=12 && self.score < 20) {
      
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.incShark = 5 + arc4random() % (6 - 3 + 1);
        } else {
            self.incShark = 4 + arc4random() % (6 - 3 + 1);
        }
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                pos.x-=9;
            } else {
                pos.x-=6;
            }
        
            node.position = pos;
            //[self.sharks replaceObjectAtIndex:i withObject:node];
        }
    }
    
    if(self.score >=20 && self.score < 36) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
           // self.range = 210;
	        } else {
            //self.range = 125;
        }
    
        for(NSInteger i = 0; i < self.sharks.count; i++) {
        
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if(node.position.x > self.fish.position.x) {
                    pos.x = pos.x - 5.5;
                }
    
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 3.5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 3.5;
                    
                }

            } else {
                
                if(node.position.x > self.fish.position.x) {
                    pos.x = pos.x - 3.5;
                }

                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 1.5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 1.5;
                }
            }

         node.position = pos;
        }
    }
    
    if(self.score >= 36 && self.score <= 45) {
        
        self.changeSharks = YES;
        self.incBack = YES;
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                   pos.x-=9.5;
	        } else {
                   pos.x-=8.0;
            }
            
         
            node.position = pos;
            //[self.sharks replaceObjectAtIndex:i withObject:node];
        }
    }
    
    if(self.score > 45 && self.score <= 60) {

        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.incShark = 5 + arc4random() % (7 - 3 + 1);
        }
        else
            self.incShark = 5 + arc4random() % (6 - 3 + 1);
        
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if(node.position.x > self.fish.position.x) {
                    pos.x = pos.x - 8.5;
                }
        
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 5;
                }
            } else {
                if(node.position.x > self.fish.position.x) {
                    pos.x = pos.x - 5.5;
                }
    
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 3.5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 3.5;
                }
            }
            node.position = pos;
        }
    }
    
    if(self.score > 60 && self.score < 80) {
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                node.size = CGSizeMake(80,100);
                if(node.position.x > self.fish.position.x) {
                    pos.x-=7.5;
                }
                
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 6;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 6.5;
                }

            } else {
                node.size = CGSizeMake(60,70);
                if(node.position.x > self.fish.position.x) {
                    pos.x-=6.5;
                }
                
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 5;
                }

            }
            node.position = pos;
            //[self.sharks replaceObjectAtIndex:i withObject:node];
        }
    }
    
    if(self.score >=80 && self.score <=100) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
             self.range = 210;
        } else {
            self.range = 115;
        }
        
        self.incShark = 6 + arc4random() % (9 - 3 + 1);
        
        self.powerCount = 6; // how fast power ups come
        
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            
            if((0+arc4random() & 1) == 1)  {                //min + arc4random() % (max - min + 1);
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                   node.size = CGSizeMake(110,100);
                }
            }
            
            if((0+arc4random() & 1) == 0)
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    node.size = CGSizeMake(100,80);
                }
            
            if((0+arc4random() & 1) == 1)  {
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    node.size = CGSizeMake(160, 180);
                }
            }
            
            if((0+arc4random() & 1) == 0)
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    node.size = CGSizeMake(140, 120);
                }
            
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if(node.position.x > self.fish.position.x) {
                    pos.x-=11.5;
                }
                
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 5.5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 5.2;
                }
            } else {
                if(node.position.x > self.fish.position.x) {
                    pos.x-=7.5;
                }
                
                if(node.position.y > self.fish.position.y) {
                    pos.y = pos.y - 4.5;
                } else if(node.position.y < self.fish.position.y) {
                    pos.y = pos.y + 4.2;
                }
            }

            node.position = pos;
            //[self.sharks replaceObjectAtIndex:i withObject:node];
        }
    }
    
    if(self.score > 100 && self.score <=120) {
        self.incShark = 5 + arc4random() % (8 - 3 + 1);
        
        self.rand = 8 + arc4random() % (12 - 3 + 1);
      
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.incShark = 3 + arc4random() % (5 - 3 + 1);
        }
        else
            self.incShark = 3 + arc4random() % (4 - 3 + 1);
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                pos.x-=self.rand;
            } else {
                pos.x-=self.rand;
            }
            
            node.position = pos;
        }
    }
    
    if(self.score > 120) {
        self.incShark = 5 + arc4random() % (8 - 3 + 1);
        
        self.rand = 8 + arc4random() % (16 - 3 + 1);
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.incShark = 3 + arc4random() % (5 - 3 + 1);
        }
        else
            self.incShark = 3 + arc4random() % (4 - 3 + 1);
        
        for(NSInteger i = 0; i < self.sharks.count; i++) {
            
            SKSpriteNode *node = [self.sharks objectAtIndex:i];
            CGPoint pos = node.position;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                pos.x-=self.rand;
            } else {
                pos.x-=self.rand;
            }
            
            node.position = pos;
        }
    }
}

-(void) movePowerFishy {
    
    CGPoint pos = self.powerFishy.position; // speed of life power up by x values
    if(self.numOfLives <=10) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            pos.x -=6;
        } else {
            pos.x -=3.5;
        }
    }
    else if(self.numOfLives >10 && self.numOfLives <= 30) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            pos.x -=6.5;
        } else {
            pos.x -=5.5;
        }
    }
    
    else if(self.numOfLives >30 && self.numOfLives <= 60) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            pos.x -=6.5;
        } else {
            pos.x -=7.5;
        }
    }
    else if(self.numOfLives > 60 && self.numOfLives <= 80) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            pos.x -=10;
        } else {
            pos.x -=8.5;
        }
    }
    else if(self.numOfLives > 80) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            pos.x -=12;
        } else {
            pos.x -=10;
        }
    }
        [self enumerateChildNodesWithName:@"fishy" usingBlock:^(SKNode *node, BOOL *stop) {   // goes through waterguns and removes!
            node.position = pos;
            if(node.position.x <= self.position.x)
                [node removeFromParent];
        }];
}

-(void) moveBackground {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if(self.incBack == NO) {
        self.bg1.position = CGPointMake(self.bg1.position.x-4, self.bg1.position.y);
        self.bg2.position = CGPointMake(self.bg2.position.x-4, self.bg2.position.y);
        }
        else if(self.incBack == YES) {
            self.bg1.position = CGPointMake(self.bg1.position.x-6, self.bg1.position.y);
            self.bg2.position = CGPointMake(self.bg2.position.x-6, self.bg2.position.y);
        }
        
        if (self.bg1.position.x < -self.bg1.size.width){
            self.bg1.position = CGPointMake(self.bg2.position.x + self.bg2.size.width, self.bg1.position.y);
        }
        
        if (self.bg2.position.x < -self.bg2.size.width) {
            self.bg2.position = CGPointMake(self.bg1.position.x + self.bg1.size.width, self.bg2.position.y);
        }
        
    } else {
        
        if(self.incBack == NO) {
            self.bg1.position = CGPointMake(self.bg1.position.x-3.8, self.bg1.position.y);
            self.bg2.position = CGPointMake(self.bg2.position.x-3.8, self.bg2.position.y);
        }
        else if(self.incBack == YES){
            self.bg1.position = CGPointMake(self.bg1.position.x-5.5, self.bg1.position.y);
            self.bg2.position = CGPointMake(self.bg2.position.x-5.5, self.bg2.position.y);
        }
        
        if (self.bg1.position.x < -self.bg1.size.width){
            self.bg1.position = CGPointMake(self.bg2.position.x + self.bg2.size.width, self.bg1.position.y);
        }
        
        if (self.bg2.position.x < -self.bg2.size.width) {
            self.bg2.position = CGPointMake(self.bg1.position.x + self.bg1.size.width, self.bg2.position.y);
        }
    }
}

-(void) changeTime {
    [self.timer invalidate];
    self.timer = nil;
    [NSTimer scheduledTimerWithTimeInterval:1.6 target:self selector:@selector(addShark) userInfo:nil repeats:YES];
    self.changeTimer = YES;
}

-(void)update:(CFTimeInterval)currentTime {
    
    [self sharkMovement];
    [self movePowerFishy];
    [self moveBackground];
    
    if(self.score == 36 && self.changeTimer == NO) {
        [self changeTime];
    }
    

}

@end
