#import "Headers/RootBridge.h"
#import <dlfcn.h>

// ponytail: every current rootless jailbreak (Dopamine, palera1n) roots at
// /var/jb. If one ever picks a different root, derive this from dli_fname.
static NSString* const kRootlessPrefix = @"/var/jb";

// A prefix only matches on a path-component boundary: "/Library" must not
// match "/Libraryfoo", nor "/var/jb" match "/var/jbroot".
static BOOL path_has_prefix(NSString* path, NSString* prefix) {
    return [path isEqualToString:prefix] || [path hasPrefix:[prefix stringByAppendingString:@"/"]];
}

// The only two roots that move under a rootless prefix.
static BOOL is_root_path(NSString* path) {
    return path_has_prefix(path, @"/Library") || path_has_prefix(path, @"/usr");
}

@implementation RootBridge
+ (BOOL)isJBRootless {
    static BOOL rootless = NO;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        // dli_fname for an address in this image = where RootBridge is installed.
        // dladdr failure -> assume rootless: conservative, prefers /var/jb paths
        Dl_info info;
        rootless = !(dladdr((const void*)&path_has_prefix, &info) && is_root_path(@(info.dli_fname)));
    });

    return rootless;
}

+ (NSString *)getJBPath:(NSString *)path {
    if(![self isJBRootless] || !path) {
        return path;
    }

    // Only jailbreak roots move under /var/jb. Everything else (/var/mobile,
    // /Applications, app bundle paths) exists at the same place either way.
    return is_root_path(path) ? [kRootlessPrefix stringByAppendingPathComponent:path] : path;
}
@end
