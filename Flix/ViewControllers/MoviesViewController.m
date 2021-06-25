//
//  MoviesViewController.m
//  Flix
//
//  Created by Kalkidan Tamirat on 6/23/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (assign, nonatomic) BOOL filter;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBar.delegate = self;
    self.filter = NO;
    
    
    [self fetchMovies];
    self.filteredMovies = self.movies;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged]; //Deprecated and only used for older objects
    // So do it on self, call the method, and then update interface as needed
    [self.tableView insertSubview:self.refreshControl atIndex:0]; // controls where you put it in the view hierarchy

}


-(void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    [self.loadingActivityView startAnimating];
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

               NSLog(@"%@", dataDictionary);
              // [NSThread sleepForTimeInterval:5]; // One way to mock slower Internet connections
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies) {
                   NSLog(@"%@", movie[@"title"]);
               }
               
               [self.tableView reloadData];
           }
        [self.loadingActivityView stopAnimating];
        [self.refreshControl endRefreshing];
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.filter)
        return self.filteredMovies.count;
    return self.movies.count;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie;
    if (self.filter) {
     movie = self.filteredMovies[indexPath.row];
    } else {
        movie = self.movies[indexPath.row];
    }
    
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *backdropUrlString = movie[@"backdrop_path"];
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropUrlString];
    NSURL *backdropURL = [NSURL URLWithString:fullBackdropURLString]; // checks to make sure it's a valid URL
    
    
    NSString *posterUrlString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterUrlString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString]; // checks to make sure it's a valid URL
    
    cell.posterView.image = nil;
    cell.backdropView.image = nil;
    
    [cell.posterView setImageWithURL:posterURL];
    [cell.backdropView setImageWithURL:backdropURL];
        
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length != 0) {
        self.searchBar.showsCancelButton = true;
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        self.filter = YES;
    } else {
        self.searchBar.showsCancelButton = false;
        self.filter = NO;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender { // Method Function: About to leave, any info you wanna send?
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    
    detailsViewController.movie = movie;
}


@end
