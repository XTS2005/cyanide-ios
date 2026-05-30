//
//  SceneDelegate.m
//  Cyanide
//
//  Created by seo on 3/24/26.
//

#import "SceneDelegate.h"
#import "SettingsViewController.h"
#import "UpdateChecker.h"

@interface SceneDelegate ()
@property (nonatomic, assign) BOOL didSelectInitialTab;

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    if ([tab isKindOfClass:UITabBarController.class] && tab.viewControllers.count > 1) {
        // iOS 26+: collapse the floating tab bar into a pill while the user
        // scrolls down, expand it back on scroll up. Falls through silently
        // on older OSes since the selector won't be present.
        SEL minSel = NSSelectorFromString(@"setTabBarMinimizeBehavior:");
        if ([tab respondsToSelector:minSel]) {
            NSMethodSignature *sig = [tab methodSignatureForSelector:minSel];
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            inv.target = tab;
            inv.selector = minSel;
            NSInteger onScrollDown = 1; // UITabBarMinimizeBehavior.onScrollDown
            [inv setArgument:&onScrollDown atIndex:2];
            [inv invoke];
        }
    }
}

- (void)selectInitialTabIfNeeded {
    if (self.didSelectInitialTab) return;
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    if (![tab isKindOfClass:UITabBarController.class] || tab.viewControllers.count == 0) return;
    self.didSelectInitialTab = YES;
    tab.selectedIndex = 0; // Installer tab
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)runUpdateCheck {
    UITabBarController *tab = (UITabBarController *)self.window.rootViewController;
    if (![tab isKindOfClass:UITabBarController.class]) return;
    // UpdateChecker walks `presentedViewController` to find the topmost VC and
    // presents from there, so if the privacy alert is up, the update prompt
    // stacks on top — independent of consent state.
    [[UpdateChecker shared] checkForUpdatesIfNeededFrom:tab];
}

- (void)showLogCollectionOptInNoticeIfNeeded {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *noticeKey = @"cyanide.privacy.logOptInDefaultNoticeShown";
    if ([ud boolForKey:noticeKey]) return;

    [ud setBool:NO forKey:kSettingsLogUploadEnabled];
    [ud synchronize];

    UIViewController *root = self.window.rootViewController;
    if (!root) return;
    NSString *msg = @"自动日志收集现已默认关闭。诊断上传仅为自愿加入。\n\n您可以随时在“设置”>“关于”>“自动上传日志”中开启。开启后，Cyanide 会在每次运行后上传链阶段耗时、错误信息、设备型号和 iOS 版本。日志会发送到 @zeroxjf 持有的私有 Cloudflare R2 存储桶，并在 30 天后过期。";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"日志收集为自愿加入"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [ud setBool:YES forKey:noticeKey];
        [ud setBool:YES forKey:@"cyanide.privacy.logConsentShown"];
        [ud synchronize];
    }]];
    [root presentViewController:alert animated:YES completion:nil];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    [self selectInitialTabIfNeeded];
    settings_application_did_become_active();
    // Independent paths: log collection opt-in notice (one-time) and update
    // check (every foreground; UpdateChecker enforces a per-process + 24-hour
    // persisted throttle so the API isn't hammered).
    // The two can stack on first launch — that's intentional, an available
    // update shouldn't be hidden behind a privacy preference.
    [self showLogCollectionOptInNoticeIfNeeded];
    [self runUpdateCheck];
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    settings_application_will_enter_foreground();
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    settings_application_did_enter_background();
}


@end
