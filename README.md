# SnippetsParser
Swift source code parser for 1000 Snippets project. 

SnippetsParser is a MacOS Command Line tool. You should run it to install the code snippets in your Xcode installation.

The installation will perform the following steps:
1. Search for your MacOS user's Documents and Library folders.
2. In your Library, search for the Developer/Xcode/UserData subfolder. If not found, it will result in an error.
3. In case it doesn't exist yet: in your UserData folder, create a CodeSnippets subfolder.
4. Search for a previous 1000Snippets subfolder in your Documents folder. If found, delete previous version if exist (with confirmation).
5. Clone the 1000Snippets GitHub repo into your Documents folder.
6. If Xcode is running, it will warn you. You must restart Xcode to have the code snippets available in the snippet's area.

The project is on the very beggining. Any suggestion, problem report or help is much appreciated! 

Please send your feedback. Thank you!

Luciano Sclovsky
luciano.sky@gmail.com
