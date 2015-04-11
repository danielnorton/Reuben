#Testing#

I got started with Objective-C in 2008. Back then, Google was kind enough to make the [Google Toolbox for Mac](https://code.google.com/p/google-toolbox-for-mac/wiki/iPhoneUnitTesting) which included some rudimentary unit testing tools. They didn't really work (for me, anyway) all that well. So we barreled forward with what we had. The story is different now, and has been since Xcode 5 with [XCTest](https://developer.apple.com/library/prerelease/ios/documentation/DeveloperTools/Conceptual/testing_with_xcode/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014132). Mea culpa, I haven't done a great job embracing and really stretching my unit testing skills in Xcode. Here's a greenfield in which to change that. In fact, that's really where this project is starting. At the hash of this writing, I don't have any 'actual' functionality in the app, but I do have a few classes of tests. The first one is just to test hitting the [github API](https://developer.github.com/v3/).

###Asynchronous Test###
Here's about the most simple one from [apiSimpleTests.swift](https://github.com/danielnorton/Reuben/blob/1161c1ea0d802394e0ad3d8e03849a0343fb9d25/source/ReubenTests/apiSimpleTests.swift). The salient bits here are the waitHandler and waitForExpectationsWithTimeout that coordinate to 'pass' the async web request.

	func testGetUserGeneric() {
    
	    let waitHandler = self.expectationWithDescription(__FUNCTION__)
    
	    let config = NSURLSessionConfiguration.defaultSessionConfiguration()
	    let session = NSURLSession(configuration: config)
    
	    let url = NSURL(string: "https://api.github.com/users/octocat")!
	    let task = session.dataTaskWithURL(url) { (data, _, error) -> Void in
        
	        if (error == nil) {
            
	            XCTAssertNotNil(data)
	            if let rawJson = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Dictionary<String, AnyObject> {
                
	                waitHandler.fulfill()
	            }
	        }
	    }
    
	    task.resume()
	    self.waitForExpectationsWithTimeout(5.0, handler: nil)
	}

###UI Test###
Xcode creates two targets by default, your app target and the test target. In years past, I would add any class that I wanted to test to both targets. With this project, I am instead going to experiment with a feature that appears to have been around since Xcode 6, "Allow testing host application APIs" in the general settings of the test target. In addition to this, Swift includes [access levels](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html) on classes, properties, methods, etc.

Here's an oversimplified view controller. You may notice that it was necessary to decorate the view controller and the label with a 'public' access level.

	import UIKit

	public class ViewController: UIViewController {

	    @IBOutlet weak private(set) public var statusLabel: UILabel!
	}

... and the corresponding test. You may notice that I import 'MyApp' just like any other library. Also, kind of a pain, before testing that the label exists (e.g. that it is properly wired up in the storyboard or xib), you must first inspect the view, this triggers the base class to load all the UI elements from the storyboard.

	import UIKit
	import XCTest
	import MyApp

	class ViewControllerTests: XCTestCase {
    
	    func testHasControlls() {
        
	        let storyboard = UIStoryboard(name: "Main", bundle: nil)
	        if let vc = storyboard.instantiateInitialViewController() as? ViewController {
            
	            XCTAssertNotNil(vc.view, "no view")
	            XCTAssertNotNil(vc.statusLabel, "no status label")
            
	        } else {
            
	            XCTAssertNotNil(nil, "no view controller")
	        }
	    }
	}

##Resources##

*	[WWDC 2014 - 414: Testing in Xcode 6](https://developer.apple.com/videos/wwdc/2014)
*	[Testing with Xcode](https://developer.apple.com/library/prerelease/ios/documentation/DeveloperTools/Conceptual/testing_with_xcode/Introduction/Introduction.html#//apple_ref/doc/uid/TP40014132)