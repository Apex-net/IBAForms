//
//  UIColor+IBAColor.m
//  IBAForms
//
//  Created by Alessandro Zoffoli on 11/11/13.
//  Copyright (c) 2013 Itty Bitty Apps Pty Ltd. All rights reserved.
//

#import "UIColor+IBAColor.h"

typedef struct { CGFloat whiteColor ; CGFloat opacity; } setting;

typedef struct {
    CGFloat     keyboardBackColor;
    CGFloat     keyBackColor;
    CGFloat     keyShadowColor;
    //CGFloat   keyFontColor;       // not changing in 7.0
    
    CGFloat     altKeyBackColor;
    CGFloat     altKeyShadowColor;
    //CGFloat   altKeyFontColor;    // not changing in 7.0
} keyboardVariant;

typedef struct {
    setting     keyboardBackSetting;
    setting     keyBackColorSetting;
    setting     keyShadowColorSetting;
    
    setting     altKeyBackColorSetting;
    setting     altKeyShadowColorSetting;
    
} settings;

static settings whiteKeyboardSettings, blackKeyboardSettings;

static BOOL isIdiomPhone;

@implementation UIColor (IBAColor)

+ (void)initialize
{
    isIdiomPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    
    // Using 'Pixie' observe values of the keyboard with an all white or all black background, to compute white and opacity
    // NOTE: black values must be somewhat smaller than the light ones or you get divide by null
    if(isIdiomPhone) {
        // White Keyboard
        {
            keyboardVariant white = { .87f, .99f, .53f,   .77f, .53f };
            keyboardVariant black = { .65f, .98f, .40f,   .66f, .40f }; // Alt Font was .39 no opacity
            whiteKeyboardSettings = [self defineWithWhiteBackground:white blackBackground:black];
        }
        // Black Keyboard
        {
            keyboardVariant white = { .36f, .55f, .21f,   .42f, .21f };
            keyboardVariant black = { .08f, .35f, .05f,   .20f, .05f }; // Alt Font 1.0
            blackKeyboardSettings = [self defineWithWhiteBackground:white blackBackground:black];
        }
    } else {
        // White Keyboard
        {
            keyboardVariant white = { .82f, .99f, .49f,   .75f, .49f };
            keyboardVariant black = { .81f, .98f, .48f,   .74f, .48f }; // Alt Font 1.0
            whiteKeyboardSettings = [self defineWithWhiteBackground:white blackBackground:black];
        }
        // Black Keyboard
        {
            keyboardVariant white = { .05f, .34f, .03f,   .19f, .03f };
            keyboardVariant black = { .04f, .33f, .02f,   .18f, .02f }; // Alt Font 1.0
            blackKeyboardSettings = [self defineWithWhiteBackground:white blackBackground:black];
        }
    }
}

+ (UIColor *)backgroundColorForType:(UIKeyboardAppearance)type
{
    setting s = type == UIKeyboardAppearanceLight ? whiteKeyboardSettings.keyboardBackSetting : blackKeyboardSettings.keyboardBackSetting;
    return  [UIColor colorWithRed:s.whiteColor-.01 green:s.whiteColor blue:s.whiteColor+.01 alpha:s.opacity];
}

+ (settings)defineWithWhiteBackground:(keyboardVariant)white blackBackground:(keyboardVariant)black
{
    settings v;
    
    v.keyboardBackSetting       = [self solveForWhite:white.keyboardBackColor black:black.keyboardBackColor whiteBG:1 blackBG:0];
    v.keyBackColorSetting       = [self solveForWhite:white.keyBackColor black:black.keyBackColor whiteBG:white.keyboardBackColor blackBG:black.keyboardBackColor];
    v.keyShadowColorSetting     = [self solveForWhite:white.keyShadowColor black:black.keyShadowColor whiteBG:white.keyboardBackColor blackBG:black.keyboardBackColor];
    
    v.altKeyBackColorSetting    = [self solveForWhite:white.altKeyBackColor black:black.altKeyBackColor whiteBG:white.keyboardBackColor blackBG:black.keyboardBackColor];
    v.altKeyShadowColorSetting  = [self solveForWhite:white.altKeyShadowColor black:black.altKeyShadowColor whiteBG:white.keyboardBackColor blackBG:black.keyboardBackColor];
    
    return v;
}

+ (setting)solveForWhite:(CGFloat)white black:(CGFloat)black whiteBG:(CGFloat)wBG blackBG:(CGFloat)bBG
{
    // Solve two equations in two variables:
    //   bBG(1-opacity) + whiteColor*opacity = black
    //   wBG(1-opacity) + whiteColor*opacity = white
    
    if(isIdiomPhone) {
        CGFloat a = black - bBG;
        CGFloat b = white - wBG;
        
        CGFloat colorDiff = (a - b);
        CGFloat backgDiff = (wBG - bBG);
        
        CGFloat opacity = colorDiff / backgDiff;
        opacity = MIN(1, opacity);
        opacity = MAX(0, opacity);
        
        CGFloat whiteColor = b/opacity + wBG;
        whiteColor = MIN(1, whiteColor);
        whiteColor = MAX(0, whiteColor);
        assert(whiteColor);
        
        setting setting;
        setting.opacity = opacity;
        setting.whiteColor = whiteColor;
        
        return setting;
    } else {
        setting setting;
        setting.opacity = 1;
        setting.whiteColor = white;
        return setting;
    }
}

@end
