#include "DragSpringPrefsRootListController.h"
#define UIColorFromRGB(rgbValue) \
	[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
	 green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
	 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
	 alpha:1.0]

@implementation DragspringPrefsController

@synthesize respringButton;

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = UIColorFromRGB(0xffae8e);
		appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
		self.hb_appearanceSettings = appearanceSettings;
		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
		                       style:UIBarButtonItemStylePlain
		                       target:self
		                       action:@selector(respring)];
		self.respringButton.tintColor = UIColorFromRGB(0xffae8e);
		self.navigationItem.rightBarButtonItem = self.respringButton;
	}

	return self;
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

- (void)respring {
	NSTask *t = [[[NSTask alloc] init] autorelease];
	[t setLaunchPath:@"/usr/bin/sbreload"];
	[t launch];
}

@end
