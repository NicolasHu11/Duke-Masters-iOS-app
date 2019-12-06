# Duke Masters Program

- Group Memebers: Yijia Hu, Fan Zhang, Xiaochen Zhou, Yilun Sun 
- ECE 564, Mobile App
- Duke University, 2019 Fall

## How to use
### build from repo
Download the repo and open in Xcode, open `.xcworkspace` instead of `xcodeproj`
Build and install on iPhone 8 (might have some UI issue on newer model)
Login using duke NetId, re-login using faceID
Checkout each function
Logout using button on sidebar

### download from appstore
duke colab appstore is out of survise





## Features Overview

###Student Directory: 
Shown all students’ name and email information, support name search.

###Todolist: 
Two individual todolists, one for fresh year and one for graduate. Click cell can show detail view. Swipe cell left can mark it completed and the text will turn gray. Swipe completed item left can mark it incomplete, text tun back to black.

###Message: 
Shown messages from department student and staff. Press button to display student/staff message. Refresh button can reload the entire page and pop up latest messages. Input textbox support automatic enlarge.

###Weblogin: 
present Duke Shibboleth login via Sakai Server with MFA supported. Relogin and logout are supported as well. 

###Information extraction: 
information are pulled from Duke Sakai, Duke Colab API

###build-in Calendar:
Features:
Used to integrate information from separate platforms and display them in the built-in calendar of our app. These events will be displayed in time ascending.

####Now we have two data sources: the Sakai website and the outlookCalendar. 
 #####When user logged in this app, the assignments for current user will be grabbed and stored. 

#####When user enter the calendar page, events in user’s outlook calendar for current month will be grabbed and stored. Currently we only support personal’s Microsoft account and user may be required to sign in to get access to their calendars’ data (i.e. when user first use the app, the password of their Microsoft account changed, etc.) To use school account, one only needs to substitute two lines of code and ask an administrator’s permission for users.read and Calendars.ReadWrite(As commented in code)

#####When user enter the calendar page, the calendar will display current month and choose current day for default. The events displayed will be current day’s events and dues. Events that has passed will be shown in different color with ongoing and upcoming ones. Dues will be presented with a tag of ‘DUE’ and due’s color will not be changed whether it passed or not.
 #####User can tap specific collectionViewCell to choose a different day for current month, when a day is selected, events for corresponding day will be displayed.
 #####User can tap buttons on the top of the view to change month. No date will be selected by default if not in current month


### Newly added after presentation! 
Log out function 
Log in with FaceID, when you have logged in before
Different animations for todolist directory and messages

## Implementation Details 

###Student Directory:
 save student directory as txt file and display student info by tableview

###Todolist: 
Embed todolist items in code as json. Display todolist as tableview.

###Message: 
Save user info and register an account on the firebase when student use this app for the first time. After that, it will automatically login to the firebase, so we can know the identity of the message sender.
When user send messages, the message content will be saved to the firebase: the messages sent by staff will save to “main_messages” form, while the messages sent by student will save to “messages” form on the database, so that we can easily control whether present staff messages or student messages. Everytime we send message, the controller will fetch data from the firebase(reload data) and show the messages by CollectionView.

###Side bar
Implemented by third party library: SideMenu https://github.com/jonkykong/SideMenu

### Web Login
Present a webview to Duke Sakai Server for Duke Shibboleth login
Keep that session’s cookies to access sakai direct API
Re-login via faceID and userdefaults
Logout using a button in sidebar, clear cookies and userdefaults


### Get information
Duke Sakai direct API: use sakai session cookies to get the user netid, email, assignment dues, etc
Colab Identity API: use netid to get results, mostly for user’s affiliation which is used for messaging group
Information are used in firebase and calendar

### Calendar：

####For acquiring data from outlook calendar:

#####Authentication: the authentication is completed via the Microsoft Azure platform using the Microsoft identity platform /authorize endpoint. To see more about the authentication process, take a look at:
https://docs.microsoft.com/en-us/graph/auth-v2-user?context=graph%2Fapi%2F1.0&view=graph-rest-1.0
To see some notes about authentication related configuration, take a look at:
https://docs.google.com/document/d/1l0OgruDLtX2H1LlFNmY87pr9rsnlHoDuwf_pB0eC050/edit?usp=sharing

#####Getting data: the Microsoft Graph API is used to get data, MSGraphClientModels is imported to help prepare data

#####Posting data: the Microsoft Graph API is used to post data, it seems that the event model in MSGraphClientModels can’t be serialized into JSON, we wrote a simplified model for posting events in CalendarDataModel.swift
To see more about Microsoft Graph’s calendar related APIs, take a look at:
https://docs.microsoft.com/en-us/graph/api/resources/calendar?view=graph-rest-1.0

####For displaying: two UICollectionViews are used

## Known issues 
Message: cannot reload messages automatically after switching group(student/staff), need to use reload button
Calendar: Currently we are still only support the personal account’s login into outlook account. To support Duke account, we need administrator’s permission to user.read and Calendars.ReadWrite. Once the permission is got, users can use Duke account to sign in by only changing two lines of code as commented in outlookCommunication.swift



## Future improvement 
Upload student directory and todolist to database, develop administrator edition for edit student directory and todolist.
 
## Contributions

Yilun Sun: Implement of Student Directory, Todolist and corporated with Fan Zhang with Message function. Participated in UI Design. 
Fan: Implement the sidebar and corporated with Yilun Sun with Message function. Responsible for setting up and maintaining the database on the firebase.
Nicolas: Implement web login and information extraction. Test and fix bugs. Help to integrate functions
Xiaochen Zhou: Implement the safety page, the room reservation page and the calendar page


