// Self-check for the path rewriting. Run from a directory that is neither
// /Library nor /usr, so RootBridge detects itself as rootless:
//
//   clang -fobjc-arc -framework Foundation -IHeaders test.m RootBridge.m -o /tmp/rbtest && /tmp/rbtest
//
#import "Headers/RootBridge.h"
#import <assert.h>

#define EQ(a, b) assert([(a) isEqualToString:(b)])

int main() {
    // built outside /Library and /usr, so detection must say rootless
    assert([RootBridge isJBRootless]);

    // jailbreak roots move
    EQ([RootBridge getJBPath:@"/Library/Frameworks/X.framework"], @"/var/jb/Library/Frameworks/X.framework");
    EQ([RootBridge getJBPath:@"/usr/lib/x.dylib"], @"/var/jb/usr/lib/x.dylib");
    EQ([RootBridge getJBPath:@"/Library"], @"/var/jb/Library");

    // everything else stays put
    EQ([RootBridge getJBPath:@"/var/mobile/Library/Preferences/x.plist"], @"/var/mobile/Library/Preferences/x.plist");
    EQ([RootBridge getJBPath:@"/var/jb/usr/lib/x.dylib"], @"/var/jb/usr/lib/x.dylib");
    EQ([RootBridge getJBPath:@"relative/path"], @"relative/path");

    // prefixes match on component boundaries only
    EQ([RootBridge getJBPath:@"/Libraryfoo"], @"/Libraryfoo");
    EQ([RootBridge getJBPath:@"/usrfoo/x"], @"/usrfoo/x");

    assert([RootBridge getJBPath:nil] == nil);

    printf("ok\n");
    return 0;
}
