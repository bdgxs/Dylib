%include "SystemInfo.swift" // Import the Swift file

%group SystemInfo //You might need this

%hook UIWindow

- (void)makeKeyAndVisible {
    %orig;
}

%end

%end