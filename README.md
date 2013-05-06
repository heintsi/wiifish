Wii Fish
=======

Wii Fish is a Wiimote-controlled fishing game. 
The idea is that there is no need for display: the Wiimote is the interface for both playing and getting feedback. However, there is a small (400x400px) graphical interface, which is somewhat useful for modeling some aspects of the application state.

The fishing game emulates ice fishing as it is. You start by lowering the bait into water, and then wait for fish to grab your bait. You can make light pulls to increase the fishes' interest in the bait, and when you feel a fish nibbling at the bait you need to make a stronger pull to catch it. The number of caught fish is indicated with the Wiimote's indicator leds. The maximum number of fish, therefore, is four.

Instructions on playing the game:
 1. Start a new game by pressing the ENTER key.
 2. Lower your bait into water by pressing the trigger button (B) in the wiimote.
 3. Wait for a fish to grab your bait.
 4. You can try to lure fish to your bait by making light pull gestures with the wiimote, much like you would do when ice-fishing.
 5. When a fish arrives, the wiimote rumbles as the fish is grabbing your bait.
 6. Make a strong pull gesture with the wiimote in order to pull the fish up.
 7. If you caught the fish, a led indicator in the wiimote turns on.
 8. Continue from instruction number 2, until you reach a total amount of four fish (all wiimote lights on).

HINT: Light pull gestures increase the probability of fish appearing at your bait. Though overtime, if no luring gestures are made, the probability of fish appearing decreases.

## Design principles

### Interaction design

Interaction with the game is planned around the Wiimote controller. The target is to have as little interaction with the device running the game (host) as possible. That is, the player should not need to have access to the host device during a game, while still being able have a fully featured experience. 

There are fundamentally two types of interaction for controlling the game using the Wiimote: by using the accelerometer or by pressing a button. These two types extend into five actions that are recognized as different interactions by the game application:
 * pressing a button to start or end the game (currently implemented using host device keyboard for easier demonstration)
 * pressing a button to lower a bait into water
 * performing a light pull gesture
 * performing a strong pull gesture
 * performing a reeling gesture

Feedback given for the user is, similarly to controlling the game, implemented using the Wiimote. There are three types of feedback given by the system to the player:
 * turning the Wiimote lights on
 * rumbling the Wiimote
 * playing sounds (implemented using the host device)

### Architecture

