# Code challenge

URL to receive post data: ​https://webhook.site/fe41e3f9-6d54-46f4-a095-701953ad616 UI Design

### Storyboards vs code

I generally have used storyboards though there are limitations. In this project I am using storyboards and xibs although text and actions are largely set up through code.

## Architecture

MVVM seems like a pretty natural fit for this app. The first screen is more or less a simple static list of data, with a couple of buttons at the bottom being the main inputs, a separate dialog (with its own view model) is used for the data entry there.
There are effectively found layers, the view/view controller, view model, coordinator and repository.
The view/view controller layer is intended to be pretty dumb and simple.
The viewmodel is where all the logic happens. The view model generally receives all required dependencies as part of it’s initialisation. One such dependency is the repository. This drives fetching of data, the view model does not know about the implementation of this fetch. This way we can potentially change from REST to GraphQL, or even mix and match networking and database via CoreData or Realm for example.
Coordinators are not heavily used here but generally all navigation is performed via coordinators. The view model retains a reference to the coordinator and can invoke navigation without directly knowing anything about the VC. This improves architecture as navigation is in a simple place for the view.
My core requirements for MVVM are as follows:

* The viewmodel does not know about the view
* The repository does not know about the view model
* The view model does not import any UIKit
* The view model massages data into the appropriate format for direct consumption in the
view. I endeavour to keep the view and view controller as simple as possible.
* Core idea behind MVVM is that the ViewModel doesn’t know about the view. The model
isn’t exposed to the view and the view remains as simple as possible.

I am using a service locator pattern for the provision of services. It has drawbacks but generally works pretty well. Viewmodels generally receive the service provider into the constructor and it allows easy service access. This provider is also passed through to child viewmodels, repositories etc.

You will see that the app is heavily using RxSwift. As I’ve moved more and more towards MVVM the issue about communicating between the view model and the View/VC becomes an issue. It’s possible to use callbacks/closures, roll my own observing pattern, KVO but I’ve found that RxSwift is ideally suited. The viewModels have inputs and outputs. Inputs generally arise from user interaction with the view. Outputs arise mostly from transforming of inputs but also from asynchronous processes such as fetching of list data or the price changing. I am a relative newcomer to RxSwift so still learning my way, but I like how different streams can be mapped in powerful ways to other streams, I do this in a few places in the app. With Combine on the way I’ve been gradually upping my usage of RxSwift, it’s not the same of course but has a pretty straight forward migration path and allows me to use FRP concepts right now instead of waiting ~2 years for iOS 13 to become the min deployment target.

I’ve found that this example works well, it’s pretty reactive to changes (even when I change the price update down to 5 seconds) it updates throughout. However I realise it is a fair amount of code for something potentially pretty simple. Most of it is infrastructure changes that needs to be only created once such as the services. I am pretty used to a more imperative style of development so this is a little bit of a break from the norm for me. Most of the time it’s been legacy code and retrofitting but in this case I was able to more or less add it from the start. That all said I am happy to work in an imperative way although with Combine being around the corner, the FRP world is closing in :)
I’ve tried to minimise state. State means more code which means more bugs. A lot of the Rx components have inbuilt storage anyway so I’ve relied on that where possible.

My http service layer is a generic REST API, using codable for JSON encoding or decoding. It is pretty flexible and can handle multiple different formats for uploading and downloading. I’ve used something similar in production for some time without any major issues.

I tend to inject my dependencies into any classes. There are several dependency injection frameworks out there but any I’ve seen tend to have too much impact on architecture for my liking so I repeat some of the same boilerplate for passing around objects. Generally I try to only pass interfaces/protocols around, this allows me to later provide fakes/mocks for testing purposes. There is more overhead in this approach but I feel that it is better to develop against interfaces in general where possible.

## Testing

I haven’t added that many tests, but I hope what I’ve added shows that both the architecture is flexible enough to be reasonably tested and that I have the knowledge to do so.
I don’t have a lot of experience in performing UI tests, probably due to the fact that the app I’ve worked on have had their UI is so much flux (I’ve mostly focussed on unit and integration tests). I’ve added just a single test as requested. I’d be very interested in learning more about this in more detail.

### Localization

I’ve set up the project so text comes from Localizable.strings. There are a few places that I didn’t get around to updating but in general it’s pretty ready for different languages.
Third Party Libraries

* *RxSwift/RxCocoa​* - as I described above, this is pretty battlehardened and in widespread use.
* *SwiftLint​* - I like having linting in the project, the rules are ones I’ve used myself for a while now and feel they’re reasonable enough
* *R.Swift*​ - This library takes some concepts from Android, notably the notion that assets should be compile-time resources. It’s generally pretty well supported with regular releases. Using this library it becomes impossible for developers to accidentally delete assets such as strings, images, nibs or colors. The exception being resources used in Interface builder but again this is more reason to move more towards code.
* *MBProgressHUD​* - An oldie but a goodie. A loading animation library with lots of customisation options, solid.
* *SkyFloatingLabelTextField​* - I’ve been using this on a recent project and quite liked the styling it brought. Well supported and fairly active.
* *Reveal*​ - Great debugging aid to help troubleshoot UIKit layout issues

I prefer to keep pods in SCM as it simplifies things for CI and leaves the repo in a state where a user can just clone it and build without having to deal with complex dependency issues. Of course it brings issues with PRs and larger commits but those can be mitigated.

## Improvements

* Allow the user to cancel the sale as it is underway
* The sell dialog view model depends on the fact that the price is being updated by the
parent sell list view model every ~30 seconds. If this was a core feature across the app then we could move elsewhere. Similarly to make the cell view model independent of the parent the timer could duplicated and reside within the dialog.
* Use the company symbol - I’m not entirely sure what it’s purpose is
* Use os_log instead of print in various places in the app
* Custom layouts for iPad
* Disable UI elements and add animation when saving
* Loading can be improved in terms of UX
* Error handling could be much improved
* Code is a little messy in places
* Add more tests for different scenarios such as for the dialog view model for starters. Also
some of the more complex logic in ShareSellListVIewModel relating to updating of totals and handling shares is currently untested.
