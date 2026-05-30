//
//  PackageCatalog.m
//  Cyanide
//

#import "PackageCatalog.h"
#import "../SettingsViewController.h"
#import "../PatreonAuth.h"

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
                            boolForKey:kSettingsExperimentalTweaksEnabled]
                            && cyanide_is_patron();
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
                                           name:@"主屏幕定制器"
                               shortDescription:@"自定义Dock栏图标数和主屏幕网格"
                                longDescription:@"自定义Dock栏图标数量以及主屏幕图标的网格（列数和行数）。可选择隐藏图标标签。\n\n在“设置”标签页中调整各轴数量和标签隐藏开关。"
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
                                longDescription:@"通过模拟热压力驱动温控守护进程来降低 CPU 和 GPU 频率。适用于对散热敏感的工作负载或在负载下延长运行时间。效果持续到重启。\n\n标准为日常使用默认档。轻度、中度、重度会刻意加大 CPU 降频幅度，因此卡顿和 App 启动变慢均属正常。这些档位日常使用可能过慢，老机型尤为明显。\n\n在“设置”标签页中选择所需档位。"
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
                               shortDescription:@"按 App 分组通知中心请求"
                                longDescription:@"在主屏幕叠加层中按 App 分组显示通知中心请求，并过滤重复项，同时 Cyanide 保持 RemoteCall 通道活跃。\n\n无需额外配置。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"测试版"
                                     symbolName:@"bell.badge.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsAxonLiteEnabled
                                          isNew:YES];
        axon.unstableWarning = @"⚠️ 实验性：开发中。可能会出现主屏幕崩溃、通知丢失、布局错乱，以及不同 Cyanide 版本间的不兼容。重要用途请勿依赖此功能。";

        Package *typeBanner = [[Package alloc] initWithIdentifier:@"com.darksword.typebanner"
                                            name:@"TypeBanner"
                               shortDescription:@"灵动岛下方的 iMessage 输入提示横幅"
                                longDescription:@"TypeMillennium 移植版。当活跃的“信息”对话列表显示正在输入指示器时，在灵动岛正下方弹出一个药丸形横幅。\n\nv1 限制：检测通过 RemoteCall 针对“信息”App 自身的视图层级进行，因此仅在“信息”App 运行时触发。原版调整的系统级 imagent Hook 需要代码注入，而在此沙盒环境中，没有代码签名绕过便无法实现。\n\n无需额外配置。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"实验性"
                                     symbolName:@"ellipsis.bubble.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsTypeBannerEnabled
                                          isNew:YES];
        typeBanner.experimental = YES;
        typeBanner.unstableWarning = @"⚠️ 实验性：极不稳定且高风险。约每 1.5 秒通过 RemoteCall 轮询 MobileSMS，状态变化时打开主屏幕通道，已知会导致主屏幕崩溃。检测仅在“信息”App 运行时触发。耗电不可忽略。";

        Package *stageStrip = [[Package alloc] initWithIdentifier:@"com.darksword.stagestrip"
                                           name:@"Dynamic Stage Lite"
                               shortDescription:@"两个 iPad 风格的浮动应用窗口"
                                longDescription:
            @"在主屏幕之上，以可调整大小的悬浮窗口运行两个 App。\n\n"
            @"基于 tomt000 的 Dynamic Stage——原版 iPhone 台前调度插件。Dynamic Stage Lite 是对分屏视图与场景托管设计的独立、纯 RemoteCall 重新实现；未复用原版插件的任何代码或资源。请前往 Havoc 查看 tomt000 的完整版本。\n\n"
            @"使用方法:\n"
            @"• 轻点屏幕右下角的圆点，即可打开选择器。\n"
            @"• 轻点两个 App，即可将它们并排启动。\n"
            @"• 拖移顶部栏可移动窗口；拖移任意角落可调整大小。\n"
            @"• 轻点窗口左上角的 X 可关闭该窗口。\n"
            @"• 选择器托盘中的齿轮图标可跳转回 Cyanide 设置。\n\n"
            @"首次运行较慢。选择器需要通过 RemoteCall 枚举每个已安装的 App，并为每个 App 生成一个磁贴——全新安装预计需要 1-2 分钟。后续运行会复用缓存，速度很快。\n\n"
            @"尚待完善之处:\n"
            @"• 触控事件尚未传递到托管 App——窗口仅供查看和切换，无法滚动或输入。\n"
            @"• 全屏启动时自动关闭尚未接入；请手动点 X 关闭。\n"
            @"• App 资源库仍在加载时，手势操作可能会出现卡顿。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"实验性"
                                     symbolName:@"sidebar.left"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsStageStripEnabled
                                          isNew:YES];
        stageStrip.experimental = YES;
        stageStrip.unstableWarning = @"⚠️ Early development. First Run takes 1-2 minutes because the picker enumerates every installed app and builds a tile per app. Re-Runs are fast. Touch routing into hosted windows isn't wired yet, so scrolling/typing inside a floating window may not work.";

        Package *themer = [[Package alloc] initWithIdentifier:@"com.darksword.themer"
                                           name:@"Cyanide 主题"
                               shortDescription:@"按应用包名换图标的主题"
                                longDescription:@"遍历主屏幕的 SBIconView 视图层级，将每个图标替换为与 App 包名 ID 匹配的 PNG，以此替换原生图标。\n\n在“设置”>“Cyanide Themer”中选择主题。Cyanide 内置 iOS 6 主题，图标源自 zagnut531/iOS-6-Icons：https://github.com/zagnut531/iOS-6-Icons。你也可导入自定义的 <包名ID>.png 文件夹，或将包名 ID 映射到 PNG 数据的二进制 plist。\n\n点“运行”生效，注销后不保留。当前版本还会预填主屏幕图标缓存，并在上传前对导入的 PNG 做圆角处理，让图标在主屏幕重新布局时更稳定地保留。"
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
                               shortDescription:@"主屏幕与Dock栏额外边距和图标缩放"
                                longDescription:@"在主屏幕网格或 Dock 栏周围添加额外间距，并可缩放图标大小。叠加在主屏幕定制器之上。\n\n在“设置”标签页中调整主屏幕左/右/上/下边距、Dock 栏水平边距以及主屏幕/Dock 栏图标缩放。默认值与原生相同（零边距，100% 缩放）。\n\n点“运行”生效；注销后不会保留。\n\niOS 18：直接修改 SBIconController 布局配置（上游 kolbicz 路径）。\niOS 26：遍历当前 SBIconListView/SBIconView 视图层级，逐图标调整 frame 与 iconImageInfo（iOS 26 布局类为只读）。iOS 26 上点“运行”仅生效一次——旋转屏幕或翻页可能触发 iOS 26 自动布局重新适配，如遇此情况请重新点“运行”。"
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
                               shortDescription:@"锁定或解锁时背光瞬间切换"
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
            stageStrip,
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
