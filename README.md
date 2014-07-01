## iOS-SDK-Sample for SDK v1.2

=================

This is the basic iOS Sample Application for the ooVoo SDK. It will let you create a conference and join other devices into your conference and test out all the features of the ooVoo SDK, including multi-party audio and video chat, in-call messaging and video filters.

This is released under an Apache 2.0 License.

This requires use of the [ooVoo iOS SDK](http://developer.oovoo.com) which is separately licensed and not included here due to github's file size limitation. Please download it from the link above.

## Getting the SDK
Please visit [ooVoo SDK site](http://developer.oovoo.com) to register and obtain a development token and AppID.

## Support
If you need help with the SDK or this app you can find us on [#ooVoo on freenode](http://webchat.freenode.net/?channels=%23oovoo&uio=OT10cnVlde), [@oovoodev on twitter](http://twitter.com/oovoodev) and email <sdk.support@oovoo.com>.

## Instructions
After you have downloaded the SDK bundle, copy the oovoo.framework file into your root directory. To authenticate, you can either pre-populate your credentials in **Classes -> Supporting Files -> LoginParameters.h** with your AppID, Token, Back-end URL and ConferenceID or when **ooVooSample** is running, go to **Settings**, scroll down your list of apps until you see **ooVooSample**, tap it  and put in your credentials.

Most problems with authentication can be easily solved by killing the app (i.e. double tap home screen and flick the app up) and then checking your credentials in the file or copy/paste them into settings again and restart the app. 
