#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject<NSApplicationDelegate>
@end

@interface MyView : NSView 
{
    @private NSRect _spot_rect;
}   
@end

@implementation AppDelegate
- (id) init {
    [super init];
    return self;
}
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification{
    // アクティブ化
    [NSApp activateIgnoringOtherApps:YES];
}
@end

@implementation MyView

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.7f] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];

     [[NSColor clearColor] set];
    NSRectFill(_spot_rect);
} 

- (id)initWithFrame:(NSRect)frame {
   self = [super initWithFrame:frame];
   if (self) {
        //int _mouse_status = 0;

        NSTrackingArea* _tracking_area = [[NSTrackingArea alloc] 
            initWithRect:[self bounds]
            options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingEnabledDuringMouseDrag )
            owner:self
            userInfo:nil];
        [self addTrackingArea:_tracking_area];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint current_point, start_point;
    start_point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSEvent *event;

    while (1) {
        event = [[self window] nextEventMatchingMask:(NSEventMaskLeftMouseDragged|NSEventMaskLeftMouseUp)];
        current_point = [self convertPoint:[event locationInWindow] fromView:nil];

        _spot_rect.size.width = fabs(start_point.x - current_point.x);
        _spot_rect.size.height = fabs(start_point.y - current_point.y);
        _spot_rect.origin.x = fmin(start_point.x, current_point.x);
        _spot_rect.origin.y = fmin(start_point.y, current_point.y);
        [self setNeedsDisplay:YES];

        if ([event type] == NSEventTypeLeftMouseUp) {
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filename = [path stringByAppendingPathComponent:@"sample_shot.png"];

            CGRect rect = CGRectMake(_spot_rect.origin.x, _spot_rect.origin.y, _spot_rect.size.width, _spot_rect.size.height);
            CGWindowID window_id = (CGWindowID)[[self window] windowNumber];
            CGImageRef cgimage = CGWindowListCreateImage(rect, kCGWindowListOptionOnScreenBelowWindow, window_id, kCGWindowImageDefault);
            NSBitmapImageRep *bitmap_rep = [[NSBitmapImageRep alloc] initWithCGImage:cgimage];
            NSData *data = [bitmap_rep representationUsingType:NSBitmapImageFileTypePNG
                                            properties:[NSDictionary dictionary]];

            [data writeToFile:filename atomically:YES];
            [bitmap_rep release];
            break;
        }
    }
}

- (BOOL)isFlipped
{
 return YES;
}
@end

void CaptureScreenshot() {
    NSScreen* main_screen = [NSScreen mainScreen];
    NSRect fullscreen_frame = [main_screen frame];
    NSWindow* _fullscreen_window = [[NSWindow alloc] 
                initWithContentRect:fullscreen_frame
                styleMask:NSWindowStyleMaskBorderless
                    backing:NSBackingStoreBuffered
                defer:NO
                screen:main_screen];
    [_fullscreen_window setReleasedWhenClosed:YES];
    [_fullscreen_window setDisplaysWhenScreenProfileChanges:YES];
    [_fullscreen_window setDelegate:NSApp];
    [_fullscreen_window setBackgroundColor:[NSColor clearColor]];
    [_fullscreen_window setOpaque:NO];
    [_fullscreen_window setHasShadow:NO];
    [_fullscreen_window setLevel:NSScreenSaverWindowLevel + 1];
    [_fullscreen_window makeKeyAndOrderFront:NSApp];

    NSView* _fullscreen_view = [[[MyView alloc] initWithFrame:fullscreen_frame] autorelease];
    [_fullscreen_window setContentView:_fullscreen_view];
    [_fullscreen_view setNeedsDisplay:YES];
}

int main(int argc, char *argv[]) {
        [NSAutoreleasePool new];
    // // NSApp を作る
    [NSApplication sharedApplication];

    CaptureScreenshot();

    id delegate = [[AppDelegate new] autorelease];
    [NSApp setDelegate:delegate];
    // メインループを回す
    [NSApp run];
    //
    return 0;
}