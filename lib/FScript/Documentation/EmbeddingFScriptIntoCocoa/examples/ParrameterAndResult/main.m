#import <Cocoa/Cocoa.h>
#import <FScript/FScript.h>

int main(int argc, const char *argv[])
{  
  NSString *result = [[@"[:s1 :s2| s1 ++ s2]" asBlock] value:@"first part" value:@"second part"]; 
  
  NSLog(result);  
  
  return 0;
}
