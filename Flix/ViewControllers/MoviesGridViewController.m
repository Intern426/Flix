//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Kalkidan Tamirat on 6/24/21.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"


@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    
    // Set up the search bar
    self.searchBar.delegate = self;
    [self.searchBar becomeFirstResponder];
    
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged]; //Deprecated and only used for older objects
    // So do it on self, call the method, and then update interface as needed
    [self.collectionView insertSubview:self.refreshControl atIndex:0]; // controls where you put it in the view hierarchy
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 0;
    
    CGFloat postersPerLine = 2;
    CGFloat itemWidth = (self.collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 2;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length != 0) {
        self.searchBar.showsCancelButton = true;
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredMovies = self.movies;
        self.searchBar.showsCancelButton = false;
    }
    [self.collectionView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredMovies = self.movies;
    [self.collectionView reloadData];
}


-(void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/635302/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus == NotReachable) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot get movies"
                                                                               message:@"There seems to be no internet connection"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                    [self fetchMovies];
                }];
                [alert addAction:tryAgainAction];
                
                [self presentViewController:alert animated:YES completion:^{
                    // optional code for what happens after the alert controller has finished presenting
                }];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot get movies"
                                                                               message:@"Please check back later."
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                    [self fetchMovies];
                }];
                [alert addAction:tryAgainAction];
                
                [self presentViewController:alert animated:YES completion:^{
                    // optional code for what happens after the alert controller has finished presenting
                }];
            }
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            // [NSThread sleepForTimeInterval:5]; // One way to mock slower Internet connections
            self.movies = dataDictionary[@"results"];
            self.filteredMovies = self.movies;
            [self.collectionView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    NSDictionary *movie = self.filteredMovies[indexPath.item];
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterUrlString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterUrlString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; // checks to make sure it's a valid URL
    
    cell.posterView.image = nil;
    
    [cell.posterView setImageWithURL:posterURL];
    
    [cell.loadingActivity stopAnimating];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UICollectionViewCell *tappedCell = sender;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}

@end
