# hubot-victorops-scripts
Hubot scripts to extend VictorOps

## Setup
Make sure your invocation of hubot exports the following environment variables (found in the VictorOps interface at **Settings > API**):

    HUBOT_VICTOROPS_API_ID
    HUBOT_VICTOROPS_API_KEY

Additionally, if you want to use the REST API functionality you need to enable the endpoint (found **VictorOps > Integration > Enable REST Endpoint**). You can find the REST Endpoint API key there as well. Export the following enviroment variable:

	HUBOT_VICTOROPS_REST_API_KEY

## Scripts
### current.coffee
List or @-mention currently on-call members for a team.

vopage will send an alert message to the oncall user(s) for a team. Note that this will send a CRITICAL alert as it is written and will therefore follow escalation policies. This can be changed by editing the JSON in the HTTP POST in the script.

The `userFilter` is a list of users that should never be returned by either function. Our organization uses "Ghost" users to help construct our schedules, so this was written to keep those users out of the results. Unless similar users exist at your org, no changes should need to be made here.

#### Usage
```
hubot current <team>
@!<team> message
vopage <team> alert message
```

### swap.coffee
Swap on-call a'la the **Take On-Call** feature. Use either this **or** `swap-auth.coffee`, not both.

**Important:** The **Take On-Call** feature can only be used to take someone else's on-call shift (it cannot be used to "give" on-call). This script allows anyone to move on-call back and forth (both "give" and "take"). Use with trust and caution (or with the `hubot-auth` module, via `swap-auth.coffee`, instead).

#### Usage
```
hubot swap <team> from <fromUser> to <toUser>
```

### swap-auth.coffee
Same as `swap.coffee`, but uses the (`hubot-auth`)[https://github.com/hubot-scripts/hubot-auth] module to authenticate use.

#### Setup
1. Make sure (`hubot-auth`)[https://github.com/hubot-scripts/hubot-auth] is installed. Follow the instructions in the readme to install.
1. Add whatever roles you want to have access to the script to the `authorizedRoles` list in `swap-auth.coffee`. For example, if you want your 'supervisor' role to be able to use swap, do this:

``` coffeescript
authorizedRoles = [
  'admin'
  'supervisor'
]
```
