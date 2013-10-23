#import <Cocoa/Cocoa.h>
#import <FScript/FScript.h>

int main(int argc, const char *argv[])
{    
  // Create a string containing the F-Script code
  NSString *fscriptCode = @"[sys log:'hello world']";

  // Create a Block object from the string
  FSBlock *block = [fscriptCode asBlock];

  // Execute the block
  [block value];
  
  // One line version
  [[@"[sys log:'hello world']" asBlock] value];
    
  return 0;
}
