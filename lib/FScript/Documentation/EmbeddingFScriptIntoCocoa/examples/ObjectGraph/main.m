#import <Cocoa/Cocoa.h>
#import <FScript/FScript.h>

int main(int argc, const char *argv[])
{
    [NSApplication sharedApplication];
    
    // Configure GUI components
    NSButton *button        = [[NSButton alloc] initWithFrame:NSMakeRect(100, 20, 100, 30)];
    NSTextField *textField  = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 100, 200, 20)];
    NSWindow *mainWindow    = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 300, 160) 
                                                          styleMask:NSClosableWindowMask | NSTitledWindowMask 
                                                            backing:NSBackingStoreBuffered 
                                                              defer:NO];
    [[mainWindow contentView] addSubview:button];
    [[mainWindow contentView] addSubview:textField];
    [button setBezelStyle:NSRoundedBezelStyle];
    [mainWindow orderFront:nil];
    
    // Create the mother block
    FSBlock *motherBlock = [@"[:textField| [textField setStringValue:NSDate date description]]" asBlock];
    
    // Use the mother block to create the block that will display the current date and time
    FSBlock *printDate = [motherBlock value:textField];
    
    // Set the printDate block as the target of our button
    [button setTarget:printDate];
    [button setAction:@selector(value:)];
     
    return NSApplicationMain(argc, (const char **) argv);
}
