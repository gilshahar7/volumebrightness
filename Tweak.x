#define PLIST_PATH @"/var/mobile/Library/Preferences/com.gilshahar7.volumebrightnessprefs.plist"

@interface UIDevice (blabla)
@property float _backlightLevel;
@end

@interface SBBrightnessController
+(SBBrightnessController *)sharedBrightnessController;
-(void)_setBrightnessLevel:(float)arg1 showHUD:(BOOL)arg2 ;
@end

@interface SpringBoard
-(void)brightnessUp;
-(void)brightnessDown;
@end

static bool brightness = false;
static NSTimer *myTimer;
static bool enabled;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
    enabled = [[prefs objectForKey:@"enabled"] boolValue];
}

%hook SpringBoard
-(BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1{
  %log;
  if(enabled == false){
    return %orig;
  }

  if([arg1.allPresses.allObjects count] < 2){
    if(arg1.allPresses.allObjects[0].force == 0){
      if(myTimer){
        [myTimer invalidate];
      }
    }
    if(brightness){
      if(arg1.allPresses.allObjects[0].force == 1){
        float currentBrightness = [UIDevice currentDevice]._backlightLevel;
        if(arg1.allPresses.allObjects[0].type == 102){
          //volume up
          myTimer = [NSTimer scheduledTimerWithTimeInterval:0.15
            target:self
            selector:@selector(brightnessUp)
            userInfo:nil
            repeats:YES];
          [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness + 0.0625 showHUD:YES];
        }
        if(arg1.allPresses.allObjects[0].type == 103){
          //volume down
          myTimer = [NSTimer scheduledTimerWithTimeInterval:0.15
            target:self
            selector:@selector(brightnessDown)
            userInfo:nil
            repeats:YES];
          [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness - 0.0625 showHUD:YES];
        }
        return %orig;

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

%new
-(void)brightnessUp{
  float currentBrightness = [UIDevice currentDevice]._backlightLevel;
  [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness + 0.0625 showHUD:YES];
}

%new
-(void)brightnessDown{
  float currentBrightness = [UIDevice currentDevice]._backlightLevel;
  [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness - 0.0625 showHUD:YES];
}


%end


%hook SBVolumeHardwareButton
-(void)volumeIncreasePress:(id)arg1{
  %log;
  if(brightness){
    NSLog(@"[VolumeBrightness] eat the event");
  }else{
    %orig;
  }
}

-(void)volumeDecreasePress:(id)arg1{
  %log;
  if(brightness){
    NSLog(@"[VolumeBrightness] eat the event");
  }else{
    %orig;
  }
}
%end

%ctor{
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.gilshahar7.volumebrightnessprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
