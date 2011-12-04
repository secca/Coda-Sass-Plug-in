//
//  ERSassPreferences.m
//  Copyright ©2011 Eric Roccasecca. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//	modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ERSassPreferences.h"

@implementation ERSassPreferences


- (id)init
{
	self = [super init];
	
	if ([NSBundle loadNibNamed:@"ERSassPreferences" owner:self])
	{
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.ERSassPlugin_UserSaveFolderPath" options:0 context:NULL];
	}
	else
	{
		[self dealloc];
		self = nil;
	}
	
	return self;
}


- (void)dealloc
{
	[prefWindow close];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:@"values.ERSassPlugin_UserSaveFolderPath"];
	
	[super dealloc];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"values.ERSassPlugin_UserSaveFolderPath"])
	{
		if ([[NSUserDefaults standardUserDefaults] stringForKey:@"ERSassPlugin_UserSaveFolderPath"].length == 0)
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ERSassPlugin_UserSaveFolderPathRelativeMode"];
	}
}


- (void)runModal
{
	[NSApp runModalForWindow:prefWindow];
	[prefWindow orderOut:self];
}


- (IBAction)ok:(id)sender
{
	[NSApp stopModalWithCode:NSOKButton];
}


- (void)support:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:codasassplugin@gmail.com"]];
}


@end
