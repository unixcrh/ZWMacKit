#import "NSRect+ZWMacExtensions.h"

#pragma mark - NSPoint, NSSize, NSRect

NSRect NSRectFromSize(NSSize size) {
	return NSMakeRect(0.0, 0.0, size.width, size.height);
}
NSRect NSRectFromPoints(NSPoint point1, NSPoint point2) {
	NSRect rect = NSZeroRect;
	// origin.x & size.width
	if(point1.x <= point2.x) {
		rect.origin.x = point1.x;
		rect.size.width = point2.x - point1.x;
	} else {
		rect.origin.x = point2.x;
		rect.size.width = point1.x - point2.x;
	}
	// origin.y & size.height
	if(point1.y <= point2.y) {
		rect.origin.y = point1.y;
		rect.size.height = point2.y - point1.y;
	} else {
		rect.origin.y = point2.y;
		rect.size.height = point1.y - point2.y;
	}
	return rect;
}
NSRect NSExpandedRect(NSRect rect, CGFloat amount) {
	rect.origin.x -= amount;
	rect.origin.y -= amount;
	rect.size.width += amount;
	rect.size.height += amount;
	return rect;
}
NSRect NSContractedRect(NSRect rect, CGFloat amount) {
	rect.origin.x += amount;
	rect.origin.y += amount;
	rect.size.width -= amount;
	rect.size.height -= amount;
	return rect;
}
NSRect NSRoundedRect(NSRect rect) {
	rect.origin.x = floor(rect.origin.x);
	rect.origin.y = floor(rect.origin.y);
	rect.size.width = ceil(rect.size.width);
	rect.size.height = ceil(rect.size.height);
	return rect;
}
void NSExpandRect(NSRect *rect, CGFloat amount) {
	rect->origin.x -= amount;
	rect->origin.y -= amount;
	rect->size.width += amount;
	rect->size.height += amount;
}
void NSContractRect(NSRect *rect, CGFloat amount) {
	rect->origin.x += amount;
	rect->origin.y += amount;
	rect->size.width -= amount;
	rect->size.height -= amount;
}
void NSRoundRect(NSRect *rect) {
	rect->origin.x = floor(rect->origin.y);
	rect->origin.y = floor(rect->origin.y);
	rect->size.width = ceil(rect->size.width);
	rect->size.height = ceil(rect->size.height);
}
void NSRectFillEdge(NSRect rect, NSRectEdge edge, CGFloat size) {
	NSRectFillEdgeUsingOperation(rect, edge, size, NSCompositeSourceOver);
}
void NSRectFillEdgeUsingOperation(NSRect rect, NSRectEdge edge, CGFloat size, NSCompositingOperation operation) {
	switch(edge) {
		case NSMinXEdge :
			rect.size.width = size;
			break;
		case NSMaxXEdge :
			rect.origin.x = rect.origin.x + rect.size.width - size;
			rect.size.width = size;
			break;
		case NSMinYEdge :
			rect.size.height = size;
			break;
		case NSMaxYEdge :
			rect.origin.y = rect.origin.y + rect.size.height - size;
			rect.size.height = size;
			break;
	}
	NSRectFillUsingOperation(rect, operation);
}