//
//	ERSassPlugIn.m
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

#import "ERSassPlugIn.h"
#import "CodaPlugInsController.h"
#include <objc/runtime.h>
#import "ERSassPreferences.h"

@implementation ERSassPlugIn

- (id)initWithPlugInController:(CodaPlugInsController*)inController bundle:(NSBundle*)aBundle
{
	if ( (self = [super init]) != nil )
	{
		controller = inController;
		sassPluginBundle = aBundle;
		
		// Migration of a default to a more correct key name.
		if ([[NSUserDefaults standardUserDefaults] valueForKey:@"CodaSassPlugin_MonitorSave"] != nil && [[NSUserDefaults standardUserDefaults] valueForKey:@"ERSassPlugin_MonitorSave"] == nil)
			[[NSUserDefaults standardUserDefaults] setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"CodaSassPlugin_MonitorSave"] forKey:@"ERSassPlugin_MonitorSave"];
		
		[controller registerActionWithTitle:NSLocalizedString(@"Convert Scss to Css", @"Convert Scss to Css")
					  underSubmenuWithTitle:nil
									 target:self
								   selector:@selector(convertScssToCss:)
						  representedObject:nil
							  keyEquivalent:@"^$S"
								 pluginName:[self name]];
		[controller registerActionWithTitle:NSLocalizedString(@"Sass Preferences…", @"Sass Preferences…")
					  underSubmenuWithTitle:nil
									 target:self
								   selector:@selector(openSassPreferences:)
						  representedObject:nil
							  keyEquivalent:nil
								 pluginName:[self name]];
		
		// CodaDocumentDidSaveNotification was derived by observing notifications being sent in Coda.
		// This could change in future versions of Coda.
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(codaDocumentSavedNotification:) name:@"CodaDocumentDidSaveNotification" object:nil];
		
	}
	
	return self;
}


- (NSString*)name
{
	return @"Sass";
}


- (IBAction)openSassPreferences:(id)sender
{
	ERSassPreferences	*prefs = [[ERSassPreferences alloc] init];
	[prefs runModal];
	[prefs release];
}


- (IBAction)convertScssToCss:(id)sender
{
	NSString	*scssPath = [self currentEditedScssPath];
	if (scssPath)
	{
		[[controller focusedTextView:self] save];
		[self generateCssForPath:scssPath];
	}
}


- (BOOL)validateMenuItem:(NSMenuItem*)menuItem
{
	BOOL result = NO;
	
	if ( [menuItem action] == @selector(convertScssToCss:) )
		result = ([self currentEditedScssPath] != nil);
	else if ( [menuItem action] == @selector(openSassPreferences:) )
		result = YES;
	
	return result;
}


- (void)codaDocumentSavedNotification:(NSNotification*)notification
{
	// The object for CodaDocumentDidSaveNotification is currently a subclass of NSDocument.
	// This could change in future versions of Coda. Sanity check the object before using.
	NSDocument	*document = [notification object];
	if (document == nil || ![document isKindOfClass:[NSDocument class]])
	{
		NSLog (@"The Sass plug-in Save notification received unexpected data.");
		return;
	}
	
	NSURL	*documentURL = [document fileURL];
	if ([documentURL isFileURL])
	{
		NSString	*documentPath = [documentURL path];
		if ([self isPathScss:documentPath])
			[self generateCssForPath:documentPath];
	}
}


- (NSString*)currentEditedScssPath
{
	NSString	*filePath = [[controller focusedTextView:self] path];
	if ([self isPathScss:filePath])
		return filePath;
	return nil;
}


- (BOOL)isPathScss:(NSString*)filePath
{
	return [[[filePath pathExtension] lowercaseString] isEqualToString:@"scss"];
}


- (NSString*)cssPathForScssPath:(NSString*)scssPath
{
	// Default css path is next to the scss path
	NSString	*cssPath = [scssPath stringByDeletingLastPathComponent];
	
	NSString	*cssUserSaveFolderPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"ERSassPlugin_UserSaveFolderPath"];
	if (cssUserSaveFolderPath.length != 0)
	{
        cssPath = [[scssPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:cssUserSaveFolderPath];
    }
	
	return cssPath;
}


- (void)generateCssForPath:(NSString*)scssPath
{
	if (scssPath == nil) return;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/sass"])
	{
		NSAlert	*alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Sass is not installed.",@"Sass is not installed.")
										 defaultButton:NSLocalizedString(@"OK",@"OK")
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedString(@"Visit sass-lang.com for more information.",@"Visit sass-lang.com for more information.")];
		[alert runModal];
		return;
	}
	
	
	NSString	*cssPath = [self cssPathForScssPath:scssPath];
	if (cssPath == nil)
		return;
    
    NSString    *scssPathWithoutFile = [scssPath stringByDeletingLastPathComponent];
	
	NSTask		*sassTask = [[NSTask alloc] init];
    NSPipe      *pipe = [[NSPipe alloc] init];
	[sassTask setLaunchPath:@"/usr/bin/sass"];
	[sassTask setCurrentDirectoryPath:scssPathWithoutFile];
    [sassTask setStandardOutput:pipe];
	[sassTask setArguments:[NSArray arrayWithObjects:@"--update", [NSString stringWithFormat:@"%@:%@", scssPathWithoutFile, cssPath], nil]];
	[sassTask launch];
	[sassTask waitUntilExit];
    
	if ([sassTask terminationStatus] != 0)
	{
        NSData *errData = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *err = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
        
		NSAlert	*alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Sass could not be completed.",@"Sass could not be completed.")
										 defaultButton:NSLocalizedString(@"OK",@"OK")
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"%@", err];
		[alert runModal];

        [err release];
    }
    
    [pipe release];
	
	[sassTask release];
}

@end
