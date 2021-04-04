# Network Communication
This package is the Taluxi network communication handler (VoIP, Push notification and maybe another communication type in the future), it uses the agora sdk for the VoIP service and the One signal sdk for the push notification.

## Call process sommary
> Note : Each user has an unique identifier and each audio channel has an unique identifier.

To make a call, the caller app send a specific silent notification (data only notification) which contain the caller user unique ID to the the recipient app and initializes an audio channel with the caller user ID (by using the agora sdk), when the recipient app receive the notification it check the notification data, if it is a incomming call notification, the recipient app show a call notification or a full-screen activity depending on the phone state. If the recipient user answer the call the recipient app join the  channel that was initialized by the caller app with the id it received in the notification and the the audio stream start (the call is started), but if the recipient user reject the call or during the call one of the user hang up a specific silent notification will be send to the other app to let it know that the call is rejected or hanged up.
