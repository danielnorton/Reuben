#Internal Decoupling#

Not yet sure how this is going to go. I want to push towards an architecture where each significant element of the system (i.e. view controllers and local services) can behave _completely_ independently of one another. A few conceptual ideas and goals:

*	**View controllers behave independently of any type of navigation hierarchy**

	I fell into on a trap on a large app and didn't realize it until things were way, way far along. The navigation stack gained too much power. A view controller at the top of the stack would manipulate state and then segue to the next view controller, passing that state. The next one would do the same, and so on. Several layers deep in this, the view controller wasn't a view controller. It was controlled by an implied (and completely undocumented and untested) trail of activity that has to be in place for it to exist. Well that sucks. I want to aim for a situation where I can set state and launch any view controller as a root. I also want to aim to be able to test any view controller in isolation.
	
*	**Complete decoupling to local services**

	All local services run in the background. Many of them exchange messages with view controllers instead of a fixed relationship. On that previously mentioned large app, I built a (probably pretty common architecture) where a view controller would instantiate a local service and set itself as a delegate and wait for a response. Something like this:
	
		@interface MyViewController() <LocalServiceDelegate>
		@end

		@implementation MyViewController

		#pragma mark -
		#pragma mark LocalServiceDelegate
		- (LocalService *)localServiceDidCompleteWithAnswer:(NSDictionary *)answer {
			[self endWait];
			[self presentAnswer:answer];
		}

		#pragma mark -
		#pragma mark MyViewControllere
		- (void)doSomething {
			NSDictionary *params = [self paramsForIndexPath:indexPath];
			[self beginWait];
			LocalService *service = [[LocalService alloc] init];
			[service setDelegate:self];
			[service beginActionWithParams:params];
		}
		@end

	It worked. It worked better before [ARC](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html). But I would like to explore some alternatives.
	
##Resources##
*	[Building Microservices](http://www.amazon.com/Building-Microservices-Sam-Newman/dp/1491950358/ref=sr_1_sc_1?ie=UTF8&qid=1428806819&sr=8-1-spell&keywords=building+microsorvices)