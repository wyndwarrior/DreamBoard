@interface SBLockScreenManager : NSObject{
    
}
@property(readonly) _Bool isUILocked;
+ (id)sharedInstance;
- (void)startUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
- (_Bool)attemptUnlockWithPasscode:(id)arg1;
- (void)applicationRequestedDeviceUnlock;
@end