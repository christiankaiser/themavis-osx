#import <stdio.h>
#import <Foundation/Foundation.h>
#import <FScript/FScript.h>

int main (int argc, char **argv, char **env)
{ 
    // Create the interpreter
    FSInterpreter *interpreter = [[FSInterpreter alloc] init]; 
  
    while(1)
    {    
        char c_command[10000];
        NSString *command = [NSString  stringWithUTF8String:fgets(c_command, 10000, stdin)];

        // Execute the F-Script command    
        FSInterpreterResult *execResult = [interpreter execute:command]; 

        if ([execResult isOK]) // test status of the result
        {
            id result = [execResult result]; 

            // Print the result
            if (result == nil) 
                puts("nil");
            else               
                puts([[result printString] UTF8String]);
      
            if (![result isKindOfClass:[FSVoid class]]) 
                putchar('\n'); 
        }
        else
        { 
            // Print an error message
            puts([[NSString stringWithFormat:@"%@ , character %d\n", [execResult errorMessage], [execResult errorRange].location] UTF8String]);
        }
    } 

    return 0;      
}