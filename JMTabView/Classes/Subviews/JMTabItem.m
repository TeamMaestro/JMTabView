//  Created by Jason Morrissey

#import "JMTabView.h"
#import "JMTabItem.h"
#import "JMTabContainer.h"

@implementation JMTabItem

@synthesize title = title_;
@synthesize icon = icon_;
@synthesize fixedWidth = fixedWidth_;
@synthesize executeBlock = executeBlock_;
@synthesize padding = padding_;
- (void)setPadding:(CGSize)padding {
    padding_ = padding;
    
    [self setNeedsDisplay];
}

- (void)dealloc;
{
    self.title = nil;
    self.icon = nil;
    self.executeBlock = nil;
    [super dealloc];
}

- (id)initWithTitle:(NSString *)title icon:(UIImage *)icon;
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.icon = icon;
        self.backgroundColor = [UIColor clearColor];
        
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityLabel:title];
        
        [self addTarget:self action:@selector(itemTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (CGSize) sizeThatFits:(CGSize)size;
{
    CGSize titleSize = [self.title sizeWithFont:kTabItemFont];
    
    CGFloat width = titleSize.width;
    
    if (self.icon)
    {
        width += [self.icon size].width;
    }
    
    if (self.icon && self.title)
    {
        width += kTabItemIconMargin;
    }
    
    width += (self.padding.width * 2);
    
    CGFloat height = (titleSize.height > [self.icon size].height) ? titleSize.height : [self.icon size].height;
    
    height += (self.padding.height * 2);
    
    if (self.fixedWidth > 0)
    {
        width = self.fixedWidth;
        height = 1.;
    }
    
    return CGSizeMake(width, height);
}

- (void)drawRect:(CGRect)rect;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * shadowColor = [UIColor blackColor];
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.0f, [shadowColor CGColor]);
    CGContextSaveGState(context);   
    
    if (self.highlighted)
    {
        CGRect bounds = CGRectInset(rect, 2., 2.);
        CGFloat radius = 0.5f * CGRectGetHeight(bounds);
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
        [[UIColor colorWithWhite:1. alpha:0.3] set];
        path.lineWidth = 2.;
        [path stroke];
    }
    
    CGFloat xOffset = self.padding.width;

    if (self.icon)
    {
        [self.icon drawAtPoint:CGPointMake(xOffset, self.padding.height)];
        xOffset += [self.icon size].width + kTabItemIconMargin;
    }
    
    [kTabItemTextColor set];

    CGFloat heightTitle = [self.title sizeWithFont:kTabItemFont].height;
    CGFloat titleYOffset = (self.bounds.size.height - heightTitle) / 2;
    [self.title drawAtPoint:CGPointMake(xOffset, titleYOffset) withFont:kTabItemFont];
    
    CGContextRestoreGState(context);
}

- (void)setHighlighted:(BOOL)highlighted;
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

-(BOOL)isSelectedTabItem;
{
    JMTabContainer *tabContainer = (JMTabContainer *)[self superview];
    return [tabContainer isItemSelected:self];
}

- (void)itemTapped;
{
    JMTabContainer *tabContainer = (JMTabContainer *)[self superview];
    [tabContainer itemSelected:self];

    #ifdef NS_BLOCKS_AVAILABLE
    if (executeBlock_)
    {
        executeBlock_();
    }
    #endif
}

+ (id)tabItemWithTitle:(NSString *)title icon:(UIImage *)icon;
{
    id tabItem = [[[[self class] alloc] initWithTitle:title icon:icon] autorelease];
    
    return tabItem;
}

+ (id)tabItemWithFixedWidth:(CGFloat)fixedWidth;
{
    id tabItem = [self tabItemWithTitle:nil icon:nil];
    ((JMTabItem *)tabItem).fixedWidth = fixedWidth;
    return tabItem;
}

#ifdef NS_BLOCKS_AVAILABLE
+ (id)tabItemWithTitle:(NSString *)title icon:(UIImage *)icon executeBlock:(JMTabExecutionBlock)executeBlock;
{
    id tabItem = [self tabItemWithTitle:title icon:icon];
    ((JMTabItem *)tabItem).executeBlock = executeBlock;
    return tabItem;
}
#endif

@end
