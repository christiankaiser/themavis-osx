#import <Cocoa/Cocoa.h>
#import <FScript/FScript.h>

int main(int argc, const char *argv[])
{
    // Initialize the Cocoa application environment
    [NSApplication sharedApplication];
    
    // Create a window
    NSWindow *mainWindow  = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 500, 400) 
                                                        styleMask:NSClosableWindowMask | NSTitledWindowMask 
                                                          backing:NSBackingStoreBuffered 
                                                            defer:NO];

    // Create an FSInterpreterView
    FSInterpreterView *fscriptView = [[FSInterpreterView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
  
    // Put the FSInterpreterView inside the window
    [mainWindow setContentView:fscriptView];
  
    // We want big fonts !
    [fscriptView setFontSize:16]; 
  
    // Put the window onscreen
    [mainWindow orderFront:nil];
    
    // Run the application
    return NSApplicationMain(argc, (const char **) argv);
}
