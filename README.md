#  Computer Simulator

## I. Overview
An application that simulates a basic computer.
It requests for and displays information to the user via a terminal view.
It allows users to provide commands either from a file or by typing them line-by-line.

##### Deployment Target
- iOS 13.0

##### Supported Orientations
- Portrait
- Landscape

##### Devices Tested (simulator)
- iPhone Xs Max (6.5")
- iPhone Xr (6.1")
- iPhone X (5.8")
- iPhone 8 (4.7")
- iPhone 5s (4.0")
- iPad Pro (12.9")

#### Development environment:
- Xcode version 11.0 beta 6

----
## II. Design
The application uses the MVVM pattern to maintain balance of responsibility among elements.
This allows us to keep classes and structs slim and tidy.

The application doesn't strictly adhere to only a single best practice list.
It is written in a way that tries to adapt to whichever is deemed fit and maintainable for our use case.

For some design decisions made during development, please see Design Considerations.

#### II.A. Project Structure
The application's project structure is briefly described below:

- Models
- Computer - models the computer simulator's main functionalities
- Stack - models the Computer's internal data structure for command execution
- Parser - models a parser that serves as the mediator between the user and the computer simulator
- ViewControllers
-  View controller for the only screen. Presentation logic here is limited; most are delegated to the view model.
- ViewModels
-  View model for the TerminalViewController. This drives the terminal view's content and facilitates communication with the parser.
- Views
- The Main storyboard and the Launch Screen
- Resources
- Image assets
- A Constants file which holds all arbitrary constant values used throughout the application
- Localizable.strings which contains the app's static string values in the base language (English). This serves as provision for localization in the future.
- Input.txt which the parser can use to read a batch of commands

#### II.B. Design Considerations

- Storyboard vs Building the UI programmatically / via XIBs
- Storyboard-based UIs can get tangled quickly when building a complex application. However, for this use case, the fundamental functionalities are fairly small which makes building through the Storyboard quicker and simpler.

- Structs vs Class
- For simpler data types, structs were preferred over classes in accordance to Apple's documentation

- Using A Result(Success/Failure) type to check the result of an execution instead of throwing an error when failures happen
- When an erroroneous input is encountered, the application mostly handles them internally and returns a Failure case instead of throwing

---
## III. Future Improvements and Known Issues
A list of improvements and known issues, some of which are also included as TODO or FIXME comments in the code, are as follows:

- Improve the Parser model.
- It is a very rough implementation of a parser, and is primarily designed to work for the given input.
- It only supports a single function definition. It may be improved by allowing multiple and/or nested function definitions. This requires consideration for a multitude of different scenarios.
- Improve UX by using attributed strings with varied font colors based on the output type (e.g. error message, instructions, execution output) to aid in readability
- Display error messages to keep the user updated on execution status. Currently, error messages are not sent to the terminal view.
- Adjust scrollview when device changes orientation.
- Improve precision of regular expressions. They currently have not been thoroughly tested against a lot of different scenarios and may yield unintended matches for edge cases.
- Allow the user to specify a different input file. The application currently only uses Input.txt.
- Wrap long user input during typing.
- Use a bigger icon, one with a 1024x1024 version to be eligible for submission to the App Store

----
## IV. Attributions
- [Computer icon](https://www.flaticon.com/free-icon/computer_517753) used as the app icon made by [Freepik](https://www.freepik.com/) from [FlatIcon](https://www.flaticon.com/) under the [Flaticon Basic license](https://file000.flaticon.com/downloads/license/license.pdf)
