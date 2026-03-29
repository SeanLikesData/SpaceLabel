#ifndef PrivateCGSBridge_h
#define PrivateCGSBridge_h

#include <CoreGraphics/CoreGraphics.h>

typedef int CGSConnectionID;
typedef uint64_t CGSSpaceID;

extern CGSConnectionID CGSMainConnectionID(void);
extern CGSSpaceID CGSGetActiveSpace(CGSConnectionID connection);
extern CFArrayRef CGSCopyManagedDisplaySpaces(CGSConnectionID connection);

#endif /* PrivateCGSBridge_h */
