//
//  DetailsViewController.m
//  Flix
//
//  Created by Kalkidan Tamirat on 6/23/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupImages];
    
    self.navigationBar.title = self.movie[@"title"];
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];

    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    self.scrollView.contentSize = CGSizeMake(screenWidth, screenHeight);
}

-(void) setupImages{
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *backdropUrlString = self.movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropUrlString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString]; // checks to make sure it's a valid URL
    
    NSString *posterUrlString = self.movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterUrlString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; // checks to make sure it's a valid URL
    
    [self.backdropView setImageWithURL:backdropURL];
    [self.posterView setImageWithURL:posterURL];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
