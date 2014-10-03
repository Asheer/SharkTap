//
//  MainMenu.m
//  Fish App
//
//  Created by Asheer Tanveer on 6/7/14.
//  Copyright (c) 2014 Asheer Tanveer. All rights reserved.
//

#import "MainMenu.h"
#import "MyScene.h"
#import <AVFoundation/AVFoundation.h>

@interface MainMenu()

@property (nonatomic) SKSpriteNode *fish;
@property (nonatomic) SKSpriteNode *play;
@property (nonatomic) SKSpriteNode *sound;
@property (nonatomic) SKSpriteNode *mute;
@property (nonatomic) AVAudioPlayer *player;
@property (nonatomic) SKSpriteNode *background;

@property (nonatomic) BOOL muted;

@end

@implementation MainMenu


-(id) initWithSize:(CGSize)size {
    
    if(self == [super initWithSize:size]) {
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sea" ofType:@"mp3"]];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [self.player play];
        
        self.background = [SKSpriteNode spriteNodeWithImageNamed:@"image.jpg"];
        
        self.background.size = CGSizeMake(self.size.width, self.size.height);
        self.background.position = CGPointMake(self.size.width/2,self.size.height/2);
    
        SKSpriteNode *name = [SKSpriteNode spriteNodeWithImageNamed:@"title.png"];
        name.size = CGSizeMake(303, name.size.height);
        
        
        self.play = [SKSpriteNode spriteNodeWithImageNamed:@"play.png"];
        
        self.sound = [SKSpriteNode spriteNodeWithImageNamed:@"sound"];
        self.mute = [SKSpriteNode spriteNodeWithImageNamed:@"mute"];

        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            name.size = CGSizeMake(520, name.size.height + 100);
            name.position = CGPointMake(self.size.width/2, self.size.height - 100);
            self.play.size = CGSizeMake(400, 360);
            self.sound.size = CGSizeMake(80, 80);
            self.mute.size = CGSizeMake(80, 80);
            self.sound.position = CGPointMake(self.size.width - 50, self.size.height - 32);
            self.mute.position = CGPointMake(50, self.size.height - 32);
            
        }else
        {
            name.size = CGSizeMake(303, name.size.height);
            name.position = CGPointMake(self.size.width/2, self.size.height - 90);
            self.play.size = CGSizeMake(180, 150);
            self.sound.size = CGSizeMake(40, 40);
            self.mute.size = CGSizeMake(40, 40);
            self.sound.position = CGPointMake(self.size.width - 26, self.size.height - 25);
            self.mute.position = CGPointMake(26, self.size.height - 25);
            
        }
        
        self.play.position = CGPointMake(name.position.x, self.size.height/3.6);

        [self addChild:self.background];
        [self addFish:self.size];
        [self addChild:self.sound];
        [self addChild:name];
        [self addChild:self.play];
       
    }
    return self;
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
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"fish.atlas"];
    NSArray *orbiImageNames = [atlas textureNames];                             // name of files, not objects
    NSArray *sortedNames = [orbiImageNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *orbTextures = [NSMutableArray array];
    for(NSString *filename in sortedNames) {
        SKTexture *texture = [atlas textureNamed:filename];
        [orbTextures addObject:texture];
    }
    SKAction *swim = [SKAction animateWithTextures:orbTextures timePerFrame:1.5];
    SKAction *keepSwimming = [SKAction repeatActionForever:swim];
    [self.fish runAction:keepSwimming];
    
    [self addChild:self.fish];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([self.sound containsPoint:location] && !self.muted) {
        [self.sound removeFromParent];
        [self addChild:self.mute];
        [self.player pause];
        self.muted = YES;
    }
    
    if ([self.mute containsPoint:location] && self.muted) {
        [self.mute removeFromParent];
        [self addChild:self.sound];
        [self.player play];
        self.muted = NO;
    }
    
    if ([self.play containsPoint:location]) {
        [self.player stop];
        MyScene *firstScene = [MyScene sceneWithSize:self.size];
        [self.view presentScene:firstScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.8]];
    }
}

@end

