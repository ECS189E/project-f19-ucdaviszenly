# Project Milestone 1

### VC sketch
[Click here for a Balsamiq link](https://balsamiq.cloud/skyb4o8/pj74nbl)
https://balsamiq.cloud/skyb4o8/pj74nbl

### Third party libraries and APIs
* Google Map API
* Facebook SDK
* Firebase

### View Controllers
* Homeview
  1. a map view using google map show locations of user and user's friend
  2. one button for login, one button to showing friends if user has already log in, one button
     showing the current location.
* ChooseLoginView
   1. user should be able to choose log in with Facebook account or log in with phone number
   2. user should be able to log out
   3. once login should go back to the homeview
* EnterPhoneNumberView & VerifyCodeView
   * implement as homework
* FriendListView
   1. tableview show friends
   2. a imageview and a lable showing user's name and profile picture
   3. once click the friends cell should bring their location on the map
* User&FriendProfileView
   1. a view to show user's profile and allowing user to change their username and photo
   2. a view after user click on one of their friends, showing firend's basic information
* MapMarkerPopupView
   1. User can mark event on the map
   2. Other Users can see this event. Once they click, a popup view should appear which shows
      other information about this event.
   3. Other users can also click thumbs up or down to this event.
* AddFriendView
   1. a view for user input phone number to search for their friends
   2. a view that shows the result of searching and a button for user to add friend
   
### Timeline
11.18: Finish adding friends(Jiaxin Zhao)

11.20: Finish Friend's list(Zirong Yu)

11.22: Finish friend's profile + user profile(Jiaxin Zhao, Zirong Yu)

11.26: Finish showing friend's location on the map (Lanqing Cheng, Niu Shang)

11.30: Finish MapMarkerPopupView(Lanqing Cheng, Niu Shang)

### Trello board
[Project markdown file link](https://github.com/ECS189E/project-f19-ucdaviszenly/blob/master/SprintPlanning2.md)
https://github.com/ECS189E/project-f19-ucdaviszenly/blob/master/SprintPlanning2.md

### Test planning
Test with friends and classmates\
Testing aspect:
* UI interface design
* Additional functions user expect to have
* Funtionality
  * does map work well
  * how long it takes for facebook to login
  * time to loading data? e.g. firend's profile picture
