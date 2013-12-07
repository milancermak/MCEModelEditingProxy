MCEModelEditingProxy
====================

MCEModelEditingProxy is an NSProxy subclass that keeps your models clean. It acts as a transparent layer between your model and your controller, intercepting writes to the model. New values are not set on the original model, but are instead set on the proxy. This is useful when you need to display values, let the user edit them, but not store them right away, only after they e.g. press an OK button.

MCEModelEditingProxy works both with objects as well as primitive C values (such as char, int or double) and also custom _named_ getters and setters on properties. However, if you have custom _implementations_ of getters or setters (e.g. for side-effects), these will not be executed while using the proxy.

## Usage
Let's say we have the following model:
```objc
///
/// header
///
#import "MCEModelEditingProxy.h"

@interface User : NSObject <MCEModelEditing>

@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, copy) NSString *name;

@end

///
/// implementation
///
@implementation User

- (id)modelProxy {
    return [[MCEModelEditingProxy alloc] initWithModel:self];
}

@end

```
Notice it implements the `-modelProxy` method from the `MCEModelEditing` protocol. That is the only method you need to implement on you model classes.

In our controller we can use the instance of the MCEModelEditingProxy returned by `-modelProxy` instead of directly using the model:
```objc
@implementation UserProfileViewController ()

@property (nonatomic, strong) User *userProxy;

@end

@implementation UserProfileViewController

- (instancetype)initWithModel:(User *)userModel {
    self = [super init];
    if (self) {
        self.userProxy = [userModel modelProxy];
    }
    return self;
}

@end
```
Even though that `userProxy` property is declared as a `User` type, we're assigning an instance of MCEModelEditingProxy to it. This is to "fool" the compiler so we can transparently use all the methods and properties declared in the `User` class without warnings.

We can now use the proxy instance to read and write properties declared on the original model object:
```objc
/// reading
self.usernameLabel.text = self.userProxy.name;
self.ageLabel.text = [NSString stringWithFormat:@"Age: %d", self.userProxy.age];

// writing new values
self.userProxy.age = 42;
```
Reading the `age` value from the proxy will return 42, but the proxied (original) model is kept untouched - the value of its `age` property stays the same.

## License

MCEModelEditingProxy is distributed under the [MIT License](LICENSE).
