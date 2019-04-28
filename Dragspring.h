#import <Preferences/PSListController.h>
#import <notify.h>
#import <libcolorpicker.h>
#import "NSTask.h"
#import <AudioToolbox/AudioServices.h>

#define UIColorFromRGB(rgbValue) \
	[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
	 green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
	 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
	 alpha:1.0]

@interface PSListController (PullToRespring)
- (id)table;
@end

@interface PSUIPrefsListController : PSListController
@end

@interface PTRRespringHandler : NSObject
@property (nonatomic, assign) PSListController *listController;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
+ (instancetype)sharedInstance;
- (void)refreshControlValueChanged:(UIRefreshControl *)refreshControl;
- (void)updateRefreshControlExistence:(BOOL)shouldExist;
@end