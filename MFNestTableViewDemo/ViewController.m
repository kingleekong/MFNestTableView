//
//  ViewController.m
//  MFNestTableViewDemo
//
//  Created by Lyman Li on 2018/4/6.
//  Copyright © 2018年 Lyman Li. All rights reserved.
//

#import "MFNestTableView.h"
#import "MFPageView.h"
#import "MFSegmentView.h"
#import "MFTransparentNavigationBar.h"

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "Test1ViewController.h"
#import "Test2ViewController.h"

@interface ViewController () <MFNestTableViewDelegate, MFNestTableViewDataSource, MFPageViewDataSource, MFPageViewDelegate, MFSegmentViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MFNestTableView *nestTableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) MFSegmentView *segmentView;
@property (nonatomic, strong) MFPageView *contentView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic) UIScrollView *blogScrollView;

@property (nonatomic, strong) NSMutableArray <NSArray *> *dataSource;
@property (nonatomic, strong) NSMutableArray <UIView *> *viewList;

@property (nonatomic, assign) BOOL canContentScroll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self initDataSource];
    [self initLayout];
}

#pragma mark - private methods

- (void)initDataSource {
    
    NSArray *pageDataCount = @[@2, @10, @30];
    
    _dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i < pageDataCount.count; ++i) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int j = 0; j < [pageDataCount[i] integerValue]; ++j) {
            [array addObject:[NSString stringWithFormat:@"page - %d - row - %d", i, j]];
        }
        [_dataSource addObject:array];
    }
    
    _viewList = [[NSMutableArray alloc] init];
    
    // 添加3个tableview
    for (int i = 0; i < pageDataCount.count; ++i) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.tag = i;
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        [_viewList addObject:tableView];
    }
    
    Test1ViewController *vc1 = [Test1ViewController new];
    Test2ViewController *vc2 = [Test2ViewController new];
    [self addChildViewController:vc1];
    [self addChildViewController:vc2];
    vc1.view.frame = self.view.bounds;
    vc2.view.frame = self.view.bounds;
    [_viewList addObject:vc1.view];
    [_viewList addObject:vc2.view];
    [vc1 didMoveToParentViewController:self];
    [vc2 didMoveToParentViewController:self];
    
    return;

    
    // 添加ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    UIImage *image = [UIImage imageNamed:@"img1.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * image.size.height / image.size.width);
    scrollView.contentSize = imageView.frame.size;
    scrollView.alwaysBounceVertical = YES; // 设置为YES，当contentSize小于frame.size也可以滚动
    [scrollView addSubview:imageView];
    scrollView.delegate = self;  // 主要是为了在 scrollViewDidScroll: 中处理是否可以滚动
    [_viewList addObject:scrollView];
    
    // 添加webview
    UIWebView *webview = [[UIWebView alloc] init];
    webview.backgroundColor = [UIColor whiteColor];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://abcmoney.work/"]]];
    webview.scrollView.delegate = self;  // 主要是为了在 scrollViewDidScroll: 中处理是否可以滚动
    _blogScrollView = webview.scrollView;
    [_viewList addObject:webview];
}

- (void)initLayout {

    [self initNavigationBar];
    
    [self initHeaderView];
    [self initSegmentView];
    [self initContentView];
    [self initFooterView];
    
    _nestTableView = [[MFNestTableView alloc] initWithFrame:self.view.bounds];
    _nestTableView.headerView = _headerView;
    _nestTableView.segmentView = _segmentView;
    _nestTableView.contentView = _contentView;
    _nestTableView.footerView = _footerView;
    _nestTableView.allowGestureEventPassViews = _viewList;
    _nestTableView.delegate = self;
    _nestTableView.dataSource = self;
    
    [self.view addSubview:_nestTableView];
    [_nestTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initHeaderView {
    
    // 因为将navigationBar设置了透明，所以这里设置将header的高度减少navigationBar的高度，
    // 并将header的subview向上偏移，遮挡navigationBar透明后的空白
    CGFloat offsetTop = [self nestTableViewContentInsetTop:_nestTableView];
    
//    UIImage *image = [UIImage imageNamed:@"img2.jpg"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    imageView.frame = CGRectMake(0, -offsetTop, CGRectGetWidth(self.view.frame), self.view.frame.size.width * image.size.height / image.size.width);
//
//    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame) - offsetTop)];
//    [header addSubview:imageView];
    
    // webview
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 300 - offsetTop)];
    webview.backgroundColor = [UIColor whiteColor];
    webview.scrollView.scrollEnabled = NO;
    webview.scrollView.scrollsToTop = NO;
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.zhihu.com/question/324736734"]]];
    
    _headerView = webview;
}

- (void)initSegmentView {
    
    _segmentView = [[MFSegmentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];
    _segmentView.delegate = self;
    _segmentView.itemWidth = 80;
    _segmentView.itemFont = [UIFont systemFontOfSize:15];
    _segmentView.itemNormalColor = [UIColor colorWithRed:155.0 / 255 green:155.0 / 255 blue:155.0 / 255 alpha:1];
    _segmentView.itemSelectColor = [UIColor colorWithRed:244.0 / 255 green:67.0 / 255 blue:54.0 / 255 alpha:1];
    _segmentView.bottomLineWidth = 60;
    _segmentView.bottomLineHeight = 2;
    _segmentView.itemList = @[@"列表1", @"列表2", @"列表3", @"列表4", @"列表5"];
}

- (void)initContentView {
    CGRect frame = self.view.bounds;
    frame.size.height = CGRectGetHeight(frame) - 34;
    _contentView = [[MFPageView alloc] initWithFrame:frame];
    _contentView.delegate = self;
    _contentView.dataSource = self;
}

- (void)initFooterView {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
    [button setBackgroundColor:[UIColor colorWithRed:244.0 / 255 green:67.0 / 255 blue:54.0 / 255 alpha:1]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"隐藏底栏" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onBtnBottomClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _footerView = button;
}

- (void)initNavigationBar {

    MFTransparentBarButtonItem *item = [[MFTransparentBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 65, 44)];
    self.navigationItem.rightBarButtonItem = item;
    
    UIButton *btnNormal = [[UIButton alloc] init];
    [btnNormal setTitle:@"" forState:UIControlStateNormal];
    [btnNormal.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnNormal.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [btnNormal setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnNormal setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    item.viewNormal = btnNormal;
    [btnNormal addTarget:self action:@selector(onNavigationRightItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnSelected = [[UIButton alloc] init];
    [btnSelected setTitle:@"" forState:UIControlStateNormal];
    [btnSelected.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnSelected setTitleColor:[UIColor colorWithRed:0.0 / 255 green:122.0 / 255 blue:255.0 / 255 alpha:1] forState:UIControlStateNormal];
    item.viewSelected = btnSelected;
    [btnSelected addTarget:self action:@selector(onNavigationRightItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleView = [[UILabel alloc] init];
    titleView.text = @"问题列表页";
    titleView.font = [UIFont boldSystemFontOfSize:14];
    [titleView sizeToFit];
    titleView.hidden = YES;
    self.navigationItem.titleView = titleView;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [_nestTableView setFooterViewHidden:YES];
}

- (void)onBtnBottomClick:(UIButton *)button {
    
    [_nestTableView setFooterViewHidden:YES];
}

- (void)onNavigationRightItemClick:(UIButton *)button {

    [_nestTableView setFooterViewHidden:NO];
//    [_nestTableView scrollToContentOffset:CGPointZero];
}

#pragma mark - MFSegmentViewDelegate

- (void)segmentView:(MFSegmentView *)segmentView didScrollToIndex:(NSUInteger)index {
    
    [_contentView scrollToIndex:index];
}

#pragma mark - MFPageViewDataSource & MFPageViewDelegate

- (NSUInteger)numberOfPagesInPageView:(MFPageView *)pageView {
    
    return [_viewList count];
}

- (UIView *)pageView:(MFPageView *)pageView pageAtIndex:(NSUInteger)index {
    
    return _viewList[index];
}

- (void)pageView:(MFPageView *)pageView didScrollToIndex:(NSUInteger)index {
    
    [_segmentView scrollToIndex:index];
    if (index == 4) {
//        [UIView animateWithDuration:0.3 animations:^{
//        }];
        [_nestTableView setHeaderViewHeight:500];
    } else {
        [_nestTableView setHeaderViewHeight:300];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [UIView new];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
    l.text = [NSString stringWithFormat:@"第 %ld Section", section];
    l.textColor = [UIColor blackColor];
    [v addSubview:l];
    v.backgroundColor = [UIColor redColor];
    return v;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *v = [UIView new];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
    l.text = @"折叠回答 100";
    l.textColor = [UIColor blackColor];
    [v addSubview:l];
    v.backgroundColor = [UIColor greenColor];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0;
            
        case 1:
            return 30;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSUInteger pageIndex = tableView.tag;
    return [_dataSource[pageIndex] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSUInteger pageIndex = tableView.tag;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataSource[pageIndex][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

// 3个tableView，scrollView，webView滑动时都会响应这个方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!_canContentScroll) {
        // 这里通过固定contentOffset，来实现不滚动
        scrollView.contentOffset = CGPointZero;
    } else if (scrollView.contentOffset.y <= 0) {
        _canContentScroll = NO;
        // 通知容器可以开始滚动
        _nestTableView.canScroll = YES;
    }
    if (_blogScrollView.scrollsToTop != _canContentScroll) {
        _blogScrollView.scrollsToTop = _canContentScroll;
        [_nestTableView turnScrollToTop:!_canContentScroll];
    }
    NSLog(@"_blogScrollView scrollToTop is %d", _blogScrollView.scrollsToTop);
    NSLog(@"scrollContent offSet VC %.1f", scrollView.contentOffset.y);
    scrollView.showsVerticalScrollIndicator = _canContentScroll;
}

#pragma mark - MFNestTableViewDelegate & MFNestTableViewDataSource

- (void)nestTableViewContentCanScroll:(MFNestTableView *)nestTableView {
    
    self.canContentScroll = YES;
}

- (void)nestTableViewContainerCanScroll:(MFNestTableView *)nestTableView {
 
    // 当容器开始可以滚动时，将所有内容设置回到顶部
//    for (id view in self.viewList) {
//        UIScrollView *scrollView;
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            scrollView = view;
//        } else if ([view isKindOfClass:[UIWebView class]]) {
//            scrollView = ((UIWebView *)view).scrollView;
//        }
//        if (scrollView) {
//            scrollView.contentOffset = CGPointZero;
//        }
//    }
}

- (void)nestTableViewDidScroll:(UIScrollView *)scrollView {
    
    // 监听容器的滚动，来设置NavigationBar的透明度
    if (_headerView) {
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat canScrollHeight = [_nestTableView heightForContainerCanScroll];
        MFTransparentNavigationBar *bar = (MFTransparentNavigationBar *)self.navigationController.navigationBar;
        if ([bar isKindOfClass:[MFTransparentNavigationBar class]]) {
            [bar setBackgroundAlpha:offset / canScrollHeight];
        }
    }
}

- (CGFloat)nestTableViewContentInsetTop:(MFNestTableView *)nestTableView {
    
    // 因为这里navigationBar.translucent == YES，所以实现这个方法，返回下面的值
#warning 这里判断 iPhoneX 有 BUG
    if (IS_IPHONE_X) {
        return 88;
    } else {
        return 64;
    }
}

@end
