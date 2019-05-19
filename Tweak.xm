#import "Dragspring.h"

BOOL dpkgInvalid = false;
BOOL enabled = true;
BOOL textEnabled = true;
BOOL spinSpinner = true;
BOOL hapticFeedback = true;
BOOL customColorEnabled = false;
UIColor *customColor = nil;

NSString *subtitlePre = @"Respring!";
NSString *subtitleDuring = @"Respringing...";

%group main

static UIRefreshControl *createRefreshControlWithListController(PSListController *listController) {
	[PTRRespringHandler.sharedInstance updateRefreshControlExistence:NO];
	UIRefreshControl *refreshControl = [UIRefreshControl new];
	if(textEnabled && !customColorEnabled) {
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:subtitlePre];
	}

	if(customColorEnabled && customColor) {
		refreshControl.tintColor = customColor;
	}

	if(textEnabled && customColorEnabled && customColor) {
		NSDictionary *attrs = @{ NSForegroundColorAttributeName : customColor };
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:subtitlePre attributes:attrs];
	} else if (textEnabled && customColorEnabled && !customColor) {
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:subtitlePre];
	}

	[refreshControl addTarget:[PTRRespringHandler sharedInstance] action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	PTRRespringHandler.sharedInstance.listController = listController;
	PTRRespringHandler.sharedInstance.refreshControl = refreshControl;

	return refreshControl;
}

%hook PSUIPrefsListController
- (void)viewDidAppear: (BOOL)animated {
	%orig;
	if(enabled) {
		self.table.refreshControl = createRefreshControlWithListController(self);
	}
}
%end

@implementation PTRRespringHandler

+ (instancetype)sharedInstance {
	static PTRRespringHandler *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [PTRRespringHandler new];
	});
	return sharedInstance;
}

- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl {
	if(textEnabled && !customColorEnabled) {
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:subtitleDuring];
	}

	if(customColorEnabled && customColor) {
		refreshControl.tintColor = customColor;
	}

	if(textEnabled && customColorEnabled && customColor) {
		NSDictionary *attrs = @{ NSForegroundColorAttributeName : customColor };
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:subtitleDuring attributes:attrs];
	} else if (textEnabled && customColorEnabled && !customColor) {
		refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:subtitleDuring];
	}

	if(hapticFeedback) {
		AudioServicesPlaySystemSound(1520);
	}

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if(spinSpinner) {
		    [NSThread sleepForTimeInterval:1];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			[refreshControl endRefreshing];
			NSTask *t = [[[NSTask alloc] init] autorelease];
			[t setLaunchPath:@"/usr/bin/sbreload"];
			[t launch];
		});

	});
}

- (void)updateRefreshControlExistence:(BOOL)shouldExist {
	if(shouldExist) {
		[self.listController.table addSubview: createRefreshControlWithListController(self.listController)];
	}else {
		if(self.refreshControl) {
			[self.refreshControl removeFromSuperview];
		}
	}
}

@end

%end

static void loadPrefs() {
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.conorthedev.dragspringprefs.plist"];
	NSMutableDictionary *colors = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.conorthedev.dragspringprefs-colors.plist"];
	
	enabled = [settings objectForKey:@"kEnabled"] ?[[settings objectForKey:@"kEnabled"] boolValue] : YES;
	textEnabled = [settings objectForKey:@"kTextEnabled"] ?[[settings objectForKey:@"kTextEnabled"] boolValue] : YES;
	spinSpinner = [settings objectForKey:@"kSpinSpinner"] ?[[settings objectForKey:@"kSpinSpinner"] boolValue] : YES;
	customColorEnabled = [settings objectForKey:@"kTintColorEnabled"] ?[[settings objectForKey:@"kTintColorEnabled"] boolValue] : NO;
	subtitlePre = [[settings objectForKey:@"kCustomText1"] stringValue] ?[[settings objectForKey:@"kCustomText1"] stringValue] : @"Respring!";
	subtitleDuring = [[settings objectForKey:@"kCustomText2"] stringValue] ?[[settings objectForKey:@"kCustomText2"] stringValue] : @"Respringing...";
	hapticFeedback = [settings objectForKey:@"kHapticFeedback"] ?[[settings objectForKey:@"kHapticFeedback"] boolValue] : YES;
	NSString *color = [[colors objectForKey:@"kTintColor"] stringValue] ?[[colors objectForKey:@"kTintColor"] stringValue] : @"#FFFFFF";
	customColor = LCPParseColorString(color, color);
}

%group IntegrityFail

%hook SpringBoard

-(void)applicationDidFinishLaunching: (id)arg1 {
	%orig;
	if (!dpkgInvalid) return;
	UIAlertController *alertController = [UIAlertController
	                                      alertControllerWithTitle:@"Dragspring was pirated!"
	                                      message:@"The build of Dragspring you're using comes from an untrusted source. Pirate repositories can distribute malware and you will get subpar user experience using any tweaks from them.\nRemember: Dragspring is free. Uninstall this build and install the proper version of Dragspring from:\nhttps://repo.conorthedev.com/\n"
	                                      preferredStyle:UIAlertControllerStyleAlert
	                                     ];

	[alertController addAction:[UIAlertAction actionWithTitle:@"OK!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	                                    [((UIApplication*)self).keyWindow.rootViewController dismissViewControllerAnimated:YES completion:NULL];
				    }]];

	[((UIApplication*)self).keyWindow.rootViewController presentViewController:alertController animated:YES completion:NULL];
}

%end

%end

%ctor {
	dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.conorthedev.dragspring.list"];

	if (dpkgInvalid) {
		%init(IntegrityFail);
		return;
	} else {
		%init(main);
	}
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.conorthedev.dragspringprefs/saved"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
