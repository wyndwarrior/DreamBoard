@interface UIWebDocumentView : UIView
{
}

- (id)initWithFrame:(struct CGRect)fp8;
- (void)dealloc;
- (id)retain;
- (void)release;
- (void)loadRequest:(id)fp8;
- (id)webView;
- (void)setDrawsBackground:(BOOL)fp8;
- (void)setBackgroundColor:(id)fp8;
- (id)delegate;
- (void)setDelegate:(id)delegate;

@end

