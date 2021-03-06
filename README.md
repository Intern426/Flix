# Project 2 - Flix

Flix is a movies app using the [The Movie Database API](http://docs.themoviedb.apiary.io/#).

Time spent: **10** hours spent in total

## User Stories

The following **required** functionality is complete:

- [x] User sees an app icon on the home screen and a styled launch screen.
- [x] User can view a list of movies currently playing in theaters from The Movie Database.
- [x] Poster images are loaded using the UIImageView category in the AFNetworking library.
- [x] User sees a loading state while waiting for the movies API.
- [x] User can pull to refresh the movie list.
- [x] User sees an error message when there's a networking error.
- [x] User can tap a tab bar button to view a grid layout of Movie Posters using a CollectionView.

The following **optional** features are implemented:

- [x] User can tap a poster in the collection view to see a detail screen of that movie
- [x] User can search for a movie.
- [ ] All images fade in as they are loading.
- [ ] User can view the large movie poster by tapping on a cell.
- [ ] For the large poster, load the low resolution image first and then switch to the high resolution image when complete.
- [ ] Customize the selection effect of the cell.
- [ ] Customize the navigation bar.
- [ ] Customize the UI.
- [ ] User can view the app on various device sizes and orientations.
- [x] Run your app on a real device.

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. When we were setting up the collection view cells, we programatically set the width and height there. Is size/design management usually done when creating layouts? Would having a layout been easier? 
2. It would be nice to discuss other causes of errors and what messages to relay the user with - since right now it's only set to respond (specifically at least) to network errors, however anything else would only get a "Please try again later" message.


## Video Walkthrough

Here's a walkthrough of implemented user stories:


![](https://i.imgur.com/H7Dnc1U.gif)
![](https://i.imgur.com/8gWQILV.gif)
![](https://i.imgur.com/ZMkZ90H.gif)


GIF created with [Kap](https://getkap.co/).

## Notes

Describe any challenges encountered while building the app.

Deciding how to display the image was tricky and when I was trying to place one image in front of the other with different transparencies, the background image either overlayed the poster or the poster view kept fading. 

Since we had a lot more objects on the storyboard, it was much easier to to accidently create the wrong outlet or  forgot to connect the outlets. This caused bugs that weren't always obvious until you run the app or resulted in vague error message were slightly challenging to parse through.

Trying to get the search bar on the Collection View via the header was also difficult to accomplish, so instead I had to shrink the Collection View and place the search bar atop which results with a search bar that follows the screen.
## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library

## License

    Copyright [2021] [Kalkidan Tamirat]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.