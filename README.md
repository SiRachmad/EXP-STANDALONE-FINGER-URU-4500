This source code is actually experiment reading standalone fingerprint reader from HID, this code especially design for Fingerprint UrU 4500.
This source code is directly communicating via dll file that Fingerprint SDK or Runtime Driver.
Folder SDK has Include file in c header and convert it in pascal using C Header Translator C Header, it worked flawlessly, Thanks to https://github.com/neslib/Chet
Source code only tested in Delphi 2010, I'd like to assume that it is safe to compile for Delphi 7 or higher and probably need some adjustment for type Data
