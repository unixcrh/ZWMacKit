#pragma mark - NSPoint, NSSize, NSRect

NSRect NSRectFromSize(NSSize size);
NSRect NSRectFromPoints(NSPoint point1, NSPoint point2);
NSRect NSExpandedRect(NSRect rect, CGFloat amount);
NSRect NSContractedRect(NSRect rect, CGFloat amount);
NSRect NSRoundedRect(NSRect rect);
void NSExpandRect(NSRect *rect, CGFloat amount);
void NSContractRect(NSRect *rect, CGFloat amount);
void NSRoundRect(NSRect *rect);
void NSRectFillEdge(NSRect rect, NSRectEdge edge, CGFloat size);
void NSRectFillEdgeUsingOperation(NSRect rect, NSRectEdge edge, CGFloat size, NSCompositingOperation operation);
