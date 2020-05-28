#define PLIST_PATH @"/var/mobile/Library/Preferences/com.gilshahar7.volumebrightnessprefs.plist"

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

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
-(void)resetCoolDownTimer;
@end

static bool brightness = false;
static NSTimer *holdingButtonTimer;
static NSTimer *coolDownTimer;
static bool enabled;
static bool showHud;
static bool shouldPlayHaptic;
static float cooldownTime;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];

	enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
	showHud = [prefs objectForKey:@"showHud"] ? [[prefs objectForKey:@"showHud"] boolValue] : YES;
	shouldPlayHaptic = [prefs objectForKey:@"shouldPlayHaptic"] ? [[prefs objectForKey:@"shouldPlayHaptic"] boolValue] : YES;
	cooldownTime = [prefs objectForKey:@"cooldownTime"] ? [[prefs objectForKey:@"cooldownTime"] floatValue] : 5;
}

%hook SpringBoard
-(BOOL)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1{
  //%log;
  if(enabled == false){
    return %orig;
  }

  if([arg1.allPresses.allObjects count] < 2){ //Single press
    if(arg1.allPresses.allObjects[0].force == 0){
      if(holdingButtonTimer){
        [holdingButtonTimer invalidate];
      }
    }
    if(brightness){
      if(arg1.allPresses.allObjects[0].force == 1){
        float currentBrightness = [UIDevice currentDevice]._backlightLevel;
        if(arg1.allPresses.allObjects[0].type == 102){
          //volume up
					[self resetCoolDownTimer];
          holdingButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.15
            target:self
            selector:@selector(brightnessUp)
            userInfo:nil
            repeats:YES];
          [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness + 0.0625 showHUD:showHud];
        }
        if(arg1.allPresses.allObjects[0].type == 103){
          //volume down
					[self resetCoolDownTimer];
          holdingButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.15
            target:self
            selector:@selector(brightnessDown)
            userInfo:nil
            repeats:YES];
          [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness - 0.0625 showHUD:showHud];
        }
        return %orig;

      }
    }

    return %orig;
  }//Single press over

  int type0 = arg1.allPresses.allObjects[0].type;
  int force0 = arg1.allPresses.allObjects[0].force;

  int type1 = arg1.allPresses.allObjects[1].type;
  int force1 = arg1.allPresses.allObjects[1].force;

  if(((type0 == 102 && type1 == 103) || (type0 == 103 && type1 == 102)) && force0 && force1){
    //NSLog(@"[VolumeBrightness] both volume buttons pressed");
		if(shouldPlayHaptic){
			AudioServicesPlaySystemSound(1520);
		}
    brightness = !brightness;
		coolDownTimer = [NSTimer scheduledTimerWithTimeInterval:cooldownTime
			target:self
			selector:@selector(switchToVolumeControl)
			userInfo:nil
			repeats:NO];
  }
  return %orig;

  // type = 102 -> vol up
  // type = 103 -> vol down

  // force = 0 -> button released
  // force = 1 -> button pressed
}

%new
-(void)brightnessUp{
	[self resetCoolDownTimer];
  float currentBrightness = [UIDevice currentDevice]._backlightLevel;
  [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness + 0.0625 showHUD:showHud];
}

%new
-(void)brightnessDown{
	[self resetCoolDownTimer];
  float currentBrightness = [UIDevice currentDevice]._backlightLevel;
  [[%c(SBBrightnessController) sharedBrightnessController] _setBrightnessLevel: currentBrightness - 0.0625 showHUD:showHud];
}

%new
-(void)resetCoolDownTimer{
	//Reset the timer.
	//NSLog(@"[VolumeBrightness] timer = %f", [[NSDate date] timeUntilDate:[coolDownTimer fireDate]]);
	[coolDownTimer invalidate];
	coolDownTimer = [NSTimer scheduledTimerWithTimeInterval:cooldownTime
		target:self
		selector:@selector(switchToVolumeControl)
		userInfo:nil
		repeats:NO];
}

%new
-(void)switchToVolumeControl{
	//Switch the bool to false after the cooldown timer is over.
	brightness = false;
}


%end


%hook SBVolumeHardwareButton
-(void)volumeIncreasePress:(id)arg1{
  %log;
  if(brightness){
    //NSLog(@"[VolumeBrightness] eat the event");
  }else{
    %orig;
  }
}

-(void)volumeDecreasePress:(id)arg1{
  %log;
  if(brightness){
    //NSLog(@"[VolumeBrightness] eat the event");
  }else{
    %orig;
  }
}
%end

%ctor{
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.gilshahar7.volumebrightnessprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
