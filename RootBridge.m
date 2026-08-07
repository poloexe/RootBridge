#import "Headers/RootBridge.h"
#import "vendor/apple/dyld_priv.h"

// ponytail: every current rootless jailbreak (Dopamine, palera1n) roots at
// /var/jb. If one ever picks a different root, derive this from selfImagePath
// instead of hardcoding it.
static NSString* const kRootlessPrefix = @"/var/jb";

// A prefix only matches on a path-component boundary: "/Library" must not
// match "/Libraryfoo", nor "/var/jb" match "/var/jbroot".
static BOOL path_has_prefix(NSString* path, NSString* prefix) {
    return [path isEqualToString:prefix] || [path hasPrefix:[prefix stringByAppendingString:@"/"]];
}

@implementation RootBridge
+ (NSString *)selfImagePath {
    const void* ret_addr = __builtin_extract_return_addr(__builtin_return_address(0));

    if(ret_addr) {
        const char* ret_image_name = dyld_image_path_containing_address(ret_addr);

        if(ret_image_name) {
            return @(ret_image_name);
        }
    }

    return nil;
}

+ (BOOL)isJBRootless {
    static BOOL rootless = NO;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        NSString* image_path = [self selfImagePath];
        // nil image path -> assume rootless: conservative, prefers /var/jb paths
        rootless = !(path_has_prefix(image_path, @"/Library") || path_has_prefix(image_path, @"/usr"));
    });

    return rootless;
}

+ (NSString *)getJBPath:(NSString *)path {
    if(![self isJBRootless] || !path) {
        return path;
    }

    // Only jailbreak roots move under /var/jb. Everything else (/var/mobile,
    // /Applications, app bundle paths) exists at the same place either way.
    if(path_has_prefix(path, @"/Library") || path_has_prefix(path, @"/usr")) {
        return [kRootlessPrefix stringByAppendingPathComponent:path];
    }

    return path;
}
@end
