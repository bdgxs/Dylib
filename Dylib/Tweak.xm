// Tweak.xm

#import <UIKit/UIKit.h>
#import "cpux_lib.h"

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CPUInfo *cpuInfo = getCPUInfo();
        MemoryInfo *memInfo = getMemoryInfo();

        UIWindow *floatingWindow = [[UIWindow alloc] initWithFrame:CGRectMake(20, 40, 250, 200)]; // Adjusted size
        floatingWindow.windowLevel = UIWindowLevelAlert;
        floatingWindow.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8]; // Semi-transparent dark background
        floatingWindow.layer.cornerRadius = 10;
        floatingWindow.clipsToBounds = YES;

        UILabel *cpuLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 80)]; // Adjusted size
        cpuLabel.numberOfLines = 0;
        cpuLabel.textColor = [UIColor whiteColor];
        cpuLabel.font = [UIFont systemFontOfSize:14];
        cpuLabel.text = [NSString stringWithFormat:@"Model: %s\nBrand: %s\nCores: %u\nThreads: %u", cpuInfo->model, cpuInfo->cpuBrand, cpuInfo->coreCount, cpuInfo->threadCount];
        [floatingWindow addSubview:cpuLabel];

        UILabel *memLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 230, 80)]; // Adjusted size
        memLabel.numberOfLines = 0;
        memLabel.textColor = [UIColor whiteColor];
        memLabel.font = [UIFont systemFontOfSize:14];
        memLabel.text = [NSString stringWithFormat:@"Total Memory: %llu bytes\nFree Memory: %llu bytes", memInfo->totalMemory, memInfo->freeMemory];
        [floatingWindow addSubview:memLabel];

        [floatingWindow makeKeyAndVisible];

        freeCPUInfo(cpuInfo);
        freeMemoryInfo(memInfo);
    });
}

%end