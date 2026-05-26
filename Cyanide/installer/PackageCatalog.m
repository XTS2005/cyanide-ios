//
//  PackageCatalog.m
//  Cyanide
//

#import "PackageCatalog.h"
#import "../SettingsViewController.h"

@implementation PackageCatalog

// Mirrors of the private SettingsSection enum values in SettingsViewController.m
// (kept in sync — must match the underlying section indices used for the
// detail-mode SettingsViewController push).
static const NSInteger kSecSBC          = 4;
static const NSInteger kSecStatBar      = 5;
static const NSInteger kSecRSSI         = 6;
static const NSInteger kSecPowercuff    = 9;
static const NSInteger kSecLayoutExtras = 11;
static const NSInteger kSecNanoRegistry = 12;
static const NSInteger kSecThemer       = 13;

+ (NSArray<Package *> *)allPackages
{
    NSArray<Package *> *full = [self allPackagesIncludingExperimental];
    BOOL experimentalOn = [[NSUserDefaults standardUserDefaults]
                            boolForKey:kSettingsExperimentalTweaksEnabled];
    if (experimentalOn) return full;

    NSMutableArray<Package *> *out = [NSMutableArray arrayWithCapacity:full.count];
    for (Package *p in full) {
        if (p.experimental) continue;
        [out addObject:p];
    }
    return out;
}

+ (NSArray<Package *> *)allPackagesIncludingExperimental
{
    static NSArray<Package *> *list;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *version = @"1.0";

        Package *statBar = [[Package alloc] initWithIdentifier:@"com.darksword.statbar"
                                           name:@"StatBar"
                               shortDescription:@"电池温度 + 可用内存覆盖层"
                                longDescription:@"在主屏幕中安装一个覆盖层窗口，在系统状态栏旁边显示实时电池温度和可用内存。当 RemoteCall 会话存活时，大约每秒刷新一次。\n\n在“设置”标签页中配置摄氏度/华氏度和网络速度显示。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"状态栏"
                                     symbolName:@"thermometer.medium"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsStatBarEnabled
                                          isNew:NO];
        statBar.settingsSection = kSecStatBar;

        Package *signal = [[Package alloc] initWithIdentifier:@"com.darksword.rssidisplay"
                                           name:@"信号强度显示"
                               shortDescription:@"蜂窝网络显示 RSRP dBm，Wi-Fi 显示信号格数"
                                longDescription:@"将状态栏中的信号强度图标替换为实时数值：蜂窝网络显示 RSRP dBm，Wi-Fi 显示当前信号格数。大约每秒更新一次。\n\n在“设置”标签页中切换仅 Wi-Fi 或仅蜂窝网络。\n\n存在问题：此插件目前与其他插件干扰太多。仍在开发中，暂时禁用。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"实验性"
                                     symbolName:@"antenna.radiowaves.left.and.right"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsRSSIDisplayEnabled
                                          isNew:NO];
        signal.settingsSection = kSecRSSI;
        signal.experimental = YES;
        signal.unstableWarning = @"⚠️ 实验性功能：开发中，可能完全无法正常工作。实时状态栏刷新会干扰其他主屏幕插件，并可能导致读数完全丢失。开启此项只会增加风险，不保证有任何可用功能。";

        Package *sbc = [[Package alloc] initWithIdentifier:@"com.darksword.sbcustomizer"
                                           name:@"SBCustomizer"
                               shortDescription:@"自定义程序坞图标数和主屏幕网格"
                                longDescription:@"自定义程序坞图标数量以及主屏幕图标的网格（列数和行数）。可选择隐藏图标标签。\n\n在“设置”标签页中调整各轴数量和标签隐藏开关。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"主屏幕布局"
                                     symbolName:@"square.grid.3x3.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsSBCEnabled
                                          isNew:NO];
        sbc.settingsSection = kSecSBC;

        Package *powercuff = [[Package alloc] initWithIdentifier:@"com.darksword.powercuff"
                                           name:@"Powercuff"
                               shortDescription:@"通过模拟热压力降低 CPU/GPU 频率"
                                longDescription:@"通过模拟热压力驱动 thermalmonitord 来降低 CPU 和 GPU 频率。适用于对散热敏感的工作负载或在负载下延长运行时间。效果持续到重启。\n\nNominal 是日常使用的默认值。Light、Moderate 和 Heavy 档会主动降低 CPU 频率，因此卡顿和应用启动变慢恰恰说明它正在正常工作。这些档位对于日常舒适使用来说可能太慢，尤其是在较旧的设备上。\n\n在“设置”标签页中选择级别。"
                                        version:version
                                         author:@"rpetrich"
                                       category:@"性能"
                                     symbolName:@"bolt.slash.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsPowercuffEnabled
                                          isNew:NO];
        powercuff.settingsSection = kSecPowercuff;

        Package *axon = [[Package alloc] initWithIdentifier:@"com.darksword.axonlite"
                                           name:@"Axon Lite"
                               shortDescription:@"按应用分组通知中心请求"
                                longDescription:@"在 SpringBoard 覆盖层中按应用分组显示可见的通知中心请求，并在 Cyanide 保持 RemoteCall 会话存活期间过滤重复通知。\n\n无需额外配置。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"测试版"
                                     symbolName:@"bell.badge.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsAxonLiteEnabled
                                          isNew:YES];
        axon.unstableWarning = @"严重缺陷的开发中版本。可能会出现 SpringBoard 崩溃、通知丢失、布局错乱以及 Cyanide 构建之间的兼容性问题。请不要依赖它处理重要事务。";

        Package *typeBanner = [[Package alloc] initWithIdentifier:@"com.darksword.typebanner"
                                            name:@"TypeBanner"
                               shortDescription:@"灵动岛下方的 iMessage 输入提示横幅"
                                longDescription:@"TypeMillennium 的移植版。当活跃的消息对话列表显示输入提示时，在灵动岛正下方显示一个药丸横幅。\n\nv1 限制：检测通过 RemoteCall 针对消息应用自身的视图层级运行，因此仅在消息应用运行时触发。原插件的系统级 imagent 钩子需要代码注入，在此沙盒环境中无法实现。\n\n无需额外配置。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"实验性"
                                     symbolName:@"ellipsis.bubble.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsTypeBannerEnabled
                                          isNew:YES];
        typeBanner.experimental = YES;
        typeBanner.unstableWarning = @"⚠️ 实验性功能：极不稳定且风险较高。通过 RemoteCall 每约 1.5 秒轮询一次 MobileSMS，状态变化时会打开 SpringBoard 会话，已知会导致 SpringBoard 崩溃。检测仅在消息应用运行时触发。耗电不可忽略。";

        Package *themer = [[Package alloc] initWithIdentifier:@"com.darksword.themer"
                                           name:@"Cyanide 主题"
                               shortDescription:@"按应用包名换图标的主题"
                                longDescription:@"通过遍历 SpringBoard 的 SBIconView 层级，将每个应用的图标替换为匹配其包名的 PNG 图片，从而实现自定义应用图标。\n\n在“设置”→“Cyanide 主题”中选择一个主题。Cyanide 内置了 iOS 6 主题，使用了 zagnut531/iOS-6-Icons 的图标：https://github.com/zagnut531/iOS-6-Icons。您也可以导入包含 <bundleID>.png 文件的文件夹，或一个将 bundle ID 映射到 PNG 数据的二进制 plist 文件。\n\n在“运行”时应用；重启 SpringBoard 后不会保留。当前版本还会预置 SpringBoard 的图标缓存，并在上传前对导入的 PNG 进行圆角处理，使图标在常见的主屏幕重新布局后更稳定。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"测试版"
                                     symbolName:@"paintpalette.fill"
                                          kind:PackageInstallKindToggle
                                     enabledKey:kSettingsThemerEnabled
                                          isNew:YES];
        themer.experimental = NO;
        themer.settingsSection = kSecThemer;
        themer.unstableWarning = @"⚠️ 测试版: 图标主题功能正常，但基于 RemoteCall 的更改在重启或注销后可能需要重新应用。在运行前请在“设置” > “Cyanide 主题”中选择一个主题。";

        Package *layoutExtras = [[Package alloc] initWithIdentifier:@"com.darksword.layoutextras"
                                           name:@"主屏幕布局扩展"
                               shortDescription:@"主屏幕/dock栏额外边距和图标缩放"
                                longDescription:@"在主屏幕网格和程序坞周围添加额外边距，并缩放图标大小。叠加在 SBCustomizer 之上。\n\n在“设置”标签页中调整主屏幕左/右/上/下边距、程序坞水平边距以及主屏幕/程序坞图标缩放。默认值与原生相同（零边距，100% 缩放）。\n\n在“运行”时应用；重启 SpringBoard 后不会保留。\n\niOS 18：直接修改 SBIconController 布局配置。\niOS 26：遍历当前的 SBIconListView/SBIconView 层级并直接调整每个图标的 frame + iconImageInfo（iOS 26 的布局类是只读的）。在 iOS 26 上仅在“运行”时一次性应用 — 旋转屏幕或翻页可能会触发 iOS 26 的自动布局重新调整，届时请重新运行。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"主屏幕布局"
                                     symbolName:@"square.dashed.inset.filled"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsLayoutExtrasEnabled
                                          isNew:YES];
        layoutExtras.settingsSection = kSecLayoutExtras;

        Package *nanoRegistry = [[Package alloc] initWithIdentifier:@"com.darksword.nanoregistry"
                                           name:@"手表配对覆盖设置"
                               shortDescription:@"配对更新的手表或恢复旧款手表"
                                longDescription:@"修改保存在这台 iPhone 上的 watchOS 配对范围。\n\n大多数人应该在“设置”中使用 watchOS 范围 99/23/10/6，然后应用覆盖设置。这些是配对协议的代数，而不是 Apple Watch 型号。99 会提高 watchOS 配对上限。23 保持第 23 代设置协议被接受。10 和 6 将旧款芯片和多手表切换的下限保持在正常值。\n\nApple Watch Ultra 3 目前无法在低于 26 的 iOS 版本上配对。\n\n安装或移除覆盖设置后，请重启 SpringBoard 或设备，然后再尝试配对。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"测试版"
                                     symbolName:@"applewatch.radiowaves.left.and.right"
                                           kind:PackageInstallKindNanoRegistry
                                     enabledKey:nil
                                          isNew:YES];
        nanoRegistry.settingsSection = kSecNanoRegistry;

        list = @[
            statBar,
            sbc,
            layoutExtras,
            powercuff,

            [[Package alloc] initWithIdentifier:@"com.darksword.disable-app-library"
                                           name:@"禁用 App 资源库"
                               shortDescription:@"移除 App 资源库页面"
                                longDescription:@"移除位于最后一个主屏幕页面右侧的 App 资源库页面。滑过最后一页将无操作。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"主屏幕插件"
                                     symbolName:@"square.grid.2x2.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSDisableAppLibrary
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.disable-icon-flyin"
                                           name:@"禁用图标弹入动画"
                               shortDescription:@"跳过图标弹簧动画"
                                longDescription:@"跳过解锁或切换应用后主屏幕图标出现时的弹簧动画。图标直接出现在最终位置。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"主屏幕插件"
                                     symbolName:@"sparkles"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSDisableIconFlyIn
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.zero-wake-animation"
                                           name:@"取消亮屏动画"
                               shortDescription:@"唤醒时瞬间点亮"
                                longDescription:@"移除唤醒显示屏时的淡入动画。屏幕立即以全亮度亮起。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"主屏幕插件"
                                     symbolName:@"moon.zzz.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSZeroWakeAnimation
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.zero-backlight-fade"
                                           name:@"取消熄屏动画"
                               shortDescription:@"锁定/解锁时背光瞬间切换"
                                longDescription:@"将背光淡入淡出持续时间减少到零，锁定和解锁时显示屏立即开关。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"主屏幕插件"
                                     symbolName:@"sun.max.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSZeroBacklightFade
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.double-tap-to-lock"
                                           name:@"双击锁定"
                               shortDescription:@"双击壁纸空白区域锁定设备"
                                longDescription:@"双击壁纸空白区域锁定设备。无需再伸手去按侧边按钮。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"主屏幕插件"
                                     symbolName:@"hand.tap.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSDoubleTapToLock
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.ota-block"
                                           name:@"OTA 更新"
                               shortDescription:@"启用或禁用系统 OTA 更新"
                                longDescription:@"通过编辑 disabled.plist 来禁用或启用负责系统 OTA 更新的 launchd 任务。状态在重启后仍保留。\n\n此包无需“运行”操作。使用“禁用”来阻止 OTA 更新，或使用“启用”来恢复更新。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"系统更新"
                                     symbolName:@"icloud.slash.fill"
                                           kind:PackageInstallKindOTA
                                     enabledKey:nil
                                          isNew:NO],

            // Beta last so the warning sits at the bottom of the Installer.
            signal,
            axon,
            nanoRegistry,
            typeBanner,
            themer,
        ];
    });
    return list;
}

+ (NSArray<NSString *> *)categoriesInOrder
{
    NSArray<NSString *> *preferred = @[
        @"实验性",
        @"测试版",
        @"状态栏",
        @"主屏幕布局",
        @"性能",
        @"系统更新",
        @"系统",
        @"主屏幕插件",
    ];
    NSMutableArray<NSString *> *all = [NSMutableArray array];
    for (Package *p in [self allPackages]) {
        if (![all containsObject:p.category]) [all addObject:p.category];
    }
    NSMutableArray<NSString *> *order = [NSMutableArray array];
    for (NSString *cat in preferred) {
        if ([all containsObject:cat]) [order addObject:cat];
    }
    for (NSString *cat in all) {
        if (![order containsObject:cat]) [order addObject:cat];
    }
    return order;
}

+ (NSDictionary<NSString *, NSArray<Package *> *> *)packagesByCategory
{
    NSMutableDictionary<NSString *, NSMutableArray<Package *> *> *buckets = [NSMutableDictionary dictionary];
    for (Package *p in [self allPackages]) {
        NSMutableArray<Package *> *bucket = buckets[p.category];
        if (!bucket) {
            bucket = [NSMutableArray array];
            buckets[p.category] = bucket;
        }
        [bucket addObject:p];
    }
    return buckets;
}

@end
