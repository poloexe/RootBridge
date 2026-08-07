#ifndef rootbridge_h
#define rootbridge_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootBridge : NSObject

/*!
 * @brief Detect whether this framework is installed on a rootless jailbreak.
 *
 * Detection is based on the path of the image containing the calling code
 * (i.e. where RootBridge itself is installed): /Library or /usr prefixes mean
 * rooted, anything else means rootless. The result is cached per-process, so
 * the first caller determines the answer for every caller in the process.
 *
 * @return YES on a rootless jailbreak. Defaults to YES when the image path
 *         cannot be determined (conservative: prefers /var/jb paths).
 */
+ (BOOL)isJBRootless;

/*!
 * @brief Rewrite a jailbreak path for a rootless platform.
 *
 * Maps /Library/... to /var/jb/Library/... and /usr/... to /var/jb/usr/...
 * when running rootless. Returns the path unchanged on rooted platforms,
 * for already-rootless paths (/var/jb prefix), or for non-absolute paths.
 *
 * @param path The jailbreak path to rewrite.
 * @return The rootless variant of the path when needed, otherwise the
 *         original path.
 */
+ (nullable NSString *)getJBPath:(nullable NSString *)path;

@end

NS_ASSUME_NONNULL_END

#endif
