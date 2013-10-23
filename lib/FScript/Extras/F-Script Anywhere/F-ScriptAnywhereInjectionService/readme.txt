
The F-Script Anywhere injection service, accessible from the Services menu, lets you inject F-Script into an application. After injection, an F-Script menu will appear in the application menu bar. Using it, you can interactively explore and manipulate the application from the inside, as it gives you access to the internal Objective-C objects the app is made of.

To install the F-Script Anywhere injection service, put the file named "Inject F-Script into application.workflow" into ~/Library/Services (where ~ stands for your home directory).

You must also have the F-Script framework installed. The F-Script framework is part of the F-Script distribution (available at http://www.fscript.org/download/download.htm) and is named "FScript.framework". To install it, put it in /Library/Frameworks/ on your system.

Finally, you must also have gdb installed on your system. One way to get it is to install the Mac OS X developer package (which includes XCode, etc.) provided by Apple.

The F-Script Anywhere injection service has been developed by Silvio H. Ferreira and also includes improvements contributed by Daniel Jalkut and Michael Bianco. 

------
Philippe Mougin. Updated April 29, 2010.
