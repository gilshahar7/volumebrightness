@interface UIDevice (blabla)
@property float _backlightLevel;
@end

@interface SBBrightnessController
+(SBBrightnessController *)sharedBrightnessController;
-(void)_setBrightnessLevel:(float)arg1 showHUD:(BOOL)arg2 ;
@end

static bool brightness = false;

%hook SpringBoard
-(BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1{
  %log;

  if([arg1.allPresses.allObjects count] < 2){
    if(brightness){
      if(arg1.allPresses.allObjects[0].force == 1){
        float currentBrightness = [UIDevice currentDevice]._backlightLevel;
        if(arg1.allPresses.allObjects[0].type == 102){
          //volume up
          //NSLog(@"[VolumeBrightness] brightness up");
          [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness + 0.0625 showHUD:YES];
        }
        if(arg1.allPresses.allObjects[0].type == 103){
          //volume down
          //NSLog(@"[VolumeBrightness] brightness down");
          [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness - 0.0625 showHUD:YES];
        }
        return NO;
      }
    }
    return %orig;
  }

  int type0 = arg1.allPresses.allObjects[0].type;
  int force0 = arg1.allPresses.allObjects[0].force;

  int type1 = arg1.allPresses.allObjects[1].type;
  int force1 = arg1.allPresses.allObjects[1].force;

  if(((type0 == 102 && type1 == 103) || (type0 == 103 && type1 == 102)) && force0 && force1){
    //NSLog(@"[VolumeBrightness] both volume buttons pressed");
    brightness = !brightness;
  }



  return %orig;

  // type = 102 -> vol up
  // type = 103 -> vol down

  // force = 0 -> button released
  // force = 1 -> button pressed
}
%end
