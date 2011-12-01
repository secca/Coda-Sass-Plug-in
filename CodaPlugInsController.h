#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
// This object is passed during initialization. You must register your        //
// available functionality with one of the methods implemented by the         //
// plug-in controller                                                         //
////////////////////////////////////////////////////////////////////////////////

@class CodaTextView;

@interface CodaPlugInsController : NSObject 
{
	NSMutableArray*			plugins;
	NSMutableDictionary*	loadedMenuItemsDict;
}

////////////////////////////////////////////////////////////////////////////////
// The following methods are available in plug-in API version 2 and higher    //
////////////////////////////////////////////////////////////////////////////////

// Returns the version of Coda that is hosting the plugin, such as "1.6.3"

- (NSString*)codaVersion:(id)sender;

// Returns to the plugin an abstract object representing the text view in Coda 
// that currently has focus

- (CodaTextView*)focusedTextView:(id)sender;

// Exposes to the user a plug-in action (a menu item) with the given title, that 
// will perform the given selector on the target

- (void)registerActionWithTitle:(NSString*)title target:(id)target selector:(SEL)selector;

// Returns 5 as of Coda 1.6.8.

- (int)apiVersion;

// Displays the provided HTML in a new tab. 

- (void)displayHTMLString:(NSString*)html;

// Creates a new unsaved document in the frontmost Coda window and returns the Text View associated with it.
// The text view provided is auto-released, so the caller does not need to explicitly release it.

- (CodaTextView*)makeUntitledDocument;

// Similar to registerActionWithTitle:target:selector: but allows further customization of the registered
// menu items, including submenu title, represented object, keyEquivalent and custom plug-in name.

- (void)registerActionWithTitle:(NSString*)title
		  underSubmenuWithTitle:(NSString*)submenuTitle
						 target:(id)target
					   selector:(SEL)selector
			  representedObject:(id)repOb
				  keyEquivalent:(NSString*)keyEquivalent
					 pluginName:(NSString*)aName;


// Causes the frontmost Coda window to save all documents that have unsaved changes.

- (void)saveAll;

@end


// 
// This is your hook to a text view in Coda. You can use this to provide 
// manipulation of files.
//

@class StudioPlainTextEditor;

@interface CodaTextView : NSObject
{
	StudioPlainTextEditor* editor;
}

////////////////////////////////////////////////////////////////////////////////
// The following methods are available in plug-in API version 2 and higher    //
////////////////////////////////////////////////////////////////////////////////

// Inserts the given string at the insertion point

- (void)insertText:(NSString*)inText;


// Replaces characters in the given range with the given string

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString;


// Returns the range of currently selected characters

- (NSRange)selectedRange;


// Returns the currently selected text, or nil if none

- (NSString*)selectedText;


// Selects the given character range

- (void)setSelectedRange:(NSRange)range;

// Returns a string containing the entire content of the line that the insertion 
// point is on

- (NSString*)currentLine;


// Returns the line number corresponding to the location of the insertion point

- (unsigned int)currentLineNumber;


// Deletes the selected text range

- (void)deleteSelection;


// Returns the current line ending of the file

- (NSString*)lineEnding;


// Returns the character range of the entire line the insertion point
// is on

- (NSRange)rangeOfCurrentLine;


// StartOfLine returns the character index (relative to the beginning of the 
// document) of the start of the line the insertion point is on

- (unsigned int)startOfLine;


// String returns the entire document as a plain string

- (NSString*)string;


// Returns the specified ranged substring of the entire document

- (NSString*)stringWithRange:(NSRange)range;


// Returns the width of tabs as spaces

- (int)tabWidth;


// Returns the range of the word previous to the insertion point

- (NSRange)previousWordRange;


// UsesTabs returns if the editor is currently uses tabs instead of spaces for 
// indentation

- (BOOL)usesTabs;

// saves the document you are working on

- (void)save;

// Saves the document you are working on to a local path, returns YES if 
// successful

- (BOOL)saveToPath:(NSString*)aPath;

// Allows for multiple text manipulations to be considered one "undo/redo"
// operation

- (void)beginUndoGrouping;
- (void)endUndoGrouping;


// Returns the window the editor is located in (useful for showing sheets)

- (NSWindow*)window;


// Returns the path to the text view's file (may be nil for unsaved documents)

- (NSString*)path;


// Returns the root local path of the site if specified (nil if unspecified in 
// the site or site is not loaded)

- (NSString*)siteLocalPath;

////////////////////////////////////////////////////////////////////////////////
// The following methods are available in plug-in API version 3 and higher    //
////////////////////////////////////////////////////////////////////////////////

// Returns the range of the word containing the insertion point

- (NSRange)currentWordRange;

////////////////////////////////////////////////////////////////////////////////
// The following methods are available in plug-in API version 4 and higher    //
////////////////////////////////////////////////////////////////////////////////

// Returns the URL of the site if specified (nil if unspecified in 
// the site or site is not loaded) 

- (NSString*)siteURL;


// Returns the local URL of the site if specified (nil if unspecified in 
// the site or site is not loaded)

- (NSString*)siteLocalURL;


// Returns the root remote path of the site if specified (nil if unspecified in 
// the site or site is not loaded)

- (NSString*)siteRemotePath;


// Returns the nickname of the site if specified (nil if site is not loaded)

- (NSString*)siteNickname;

////////////////////////////////////////////////////////////////////////////////
// The following methods are available in plug-in API version 5 and higher    //
////////////////////////////////////////////////////////////////////////////////

- (NSStringEncoding)encoding;

@end


////////////////////////////////////////////////////////////////////////////////
// Your plug-in's principal class must conform to this protocol               //
////////////////////////////////////////////////////////////////////////////////

@protocol CodaPlugIn

// Default init'r for your plug-in's principal class. Passes a reference to your
// bundle and the singelton instance of the CodaPlugInsController

- (id)initWithPlugInController:(CodaPlugInsController*)aController bundle:(NSBundle*)yourBundle;


// Return a name to display in the plug-ins menu

- (NSString*)name;

@end


