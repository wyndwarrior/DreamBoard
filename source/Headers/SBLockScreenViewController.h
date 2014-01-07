@interface SBLockScreenViewController {
    
}
- (id)lockScreenView;
- (void)deactivate;
- (void)activate;
- (void)attemptToUnlockUIFromNotification;
- (void)_bioAuthenticated:(id)arg1;
@end
