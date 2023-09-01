# Images Search App
Pixabay free images search app

The Images Search App is a handy tool that allows users to search for images on various topics of interest using the Pixabay free images search API. Users can view search results in a grid, open images for viewing, zoom in up to 10x, and share image links with ease.

## Requirements

- iOS 12 and above
- An internet connection for image searches
- Adaptive grid layout for different device orientations
- Image caching for improved performance

## Stack

- Swift
- UIKit
- Auto Layout for responsive design
- Model-View-Controller (MVC) architectural pattern
- Third-party API (Pixabay) for image data
- Third-party libraries (CocoaPods) for image caching
- Design tools: Figma for UI/UX design

## Functionality

- The app provides an input field where users can enter search queries for images on topics of interest.

- Search results are displayed in an adaptive grid, ensuring an optimal viewing experience on different devices and orientations. For example, in portrait iPhone orientation, two pictures are displayed in a row, while in landscape orientation, it's three or four.

- Users can easily share image links with others directly from the app.

- Tapping on an image opens it on a separate screen for detailed viewing. Users can zoom in on images up to 10x magnification, and the minimum zoom level is set to display a half-screen image.

- Images are cached to enhance app performance and speed up loading times.

## Installation and Usage

1. Clone this repository to your local machine.

2. Open the Xcode project file.

3. Configure your Xcode environment and build settings.

4. Run the app on the iOS Simulator or a physical iOS device.

5. Ensure you have an internet connection to perform image searches.

## API

The app utilizes the Pixabay free images search API for retrieving image data. You can find the API documentation at [Pixabay API Docs](https://pixabay.com/api/docs/).

## Design

The app's design is based on the Figma template.

## Credits

- Image data is retrieved from the Pixabay API.

- Design inspiration comes from the Figma template mentioned above.

- For guidance on implementing a grid layout with UICollectionView, refer to this [helpful tutorial](https://www.kodeco.com/18895088-uicollectionview-tutorial-getting-started).

## License

This project is distributed under the [MIT License](https://github.com/stavraty/Images-search/blob/dev/LICENCE).

---

For further assistance or inquiries, please refer to the project documentation or contact the project maintainers.
