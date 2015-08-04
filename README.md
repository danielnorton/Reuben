#Reuben#

A simple github client for learning and practicing modern iOS development concepts. This app may or may not ever wind up being useful. That's not the goal. The real goal is simply to have a clean slate to learn and level up with new concepts.

## Getting Started ##

The project is currently being written using Xcode 6.3 and runs on iOS 8.3+. Other than that, no third-party dependancies. Haven't yet injected cocoapods or whatnot. May never. Just pull down source, build, and run on a device or simulator.

## Inspiration ##

This project is a playground; free from constraints applied to "real" work and projects. There are a number of newer (iOS 7+) features that I would like to experiment with in a safe environment. Also, I figure while I am at it I could try to put something together that could possibly be useful to the community. I want to document my discoveries and failures along this process.

So, here are a few of my goals and technologies in which I am currently interested (in no particular order):

*	**[Background data refresh](docs/background.md)**
	
	I am very interested in utilizing the OS correctly to make a seamless experience for the user to pull their phone out of their pocket and always expect the data to be up to date. Things like transitioning to NSURLSession from NSURLConnection, background fetch, "headless" notifications
	
*	**Background process**

	Move as much as possible off the main UI thread, including Core Data updates
	
*	**[Internal Decoupling](docs/internal decoupling.md)**

	
	
*	**Security**

	Keychain access, fingerprint scanner, access to the keychain while the app is backgrounded or device is locked

*	**Swift 2+**

	No time or calories to transition existing Obj-C code to Swift during the day. So sad. Also, want to play in this sandbox before risking performance issues in real apps

*	**[Testing](docs/testing.md)**

	 I just want to up my testing game. Things are certainly better than they were back at the beginning, and there are a few things about testing Swift that are different than testing Objective-C.