# Description:
#   Return or @-mention users currently on call for a team
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_VICTOROPS_API_ID = API ID
#   HUBOT_VICTOROPS_API_KEY = API Key
#
# Commands:
#   hubot current <team> - List users currently on-call for <team>
#   @!<team> <message> - @-mention <message> to all users currently on-call for <team>

apiauth =
  'X-VO-Api-Id': process.env.HUBOT_VICTOROPS_API_ID
  'X-VO-Api-Key': process.env.HUBOT_VICTOROPS_API_KEY
restapikey = process.env.HUBOT_VICTOROPS_REST_API_KEY
# List users here who should be excluded from all user lists
userFilter = [
  ''
  'ghost1'
  'ghost2'
  'ghost3'
]

module.exports = (robot) ->
  robot.hear /on ?call( for)? +(.*)$/i, (msg) ->
    team = msg.match[2]

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/schedule")
      .headers(apiauth)
      .get() (err, res, body) ->
        res = JSON.parse "#{body}"
        if res["schedule"]?
          users = []
          for sched in res["schedule"]
            users.push sched["onCall"] unless sched["overrideOnCall"]? or sched["onCall"] in userFilter
            users.push sched["overrideOnCall"] if sched["overrideOnCall"]? and sched["overrideOnCall"]? not in userFilter
          msg.reply "Users on-call for #{team}: #{users.join(', ')}"
        else
          msg.reply "No team '#{team}' found."
    
  robot.respond /q?page ?(\S*) (.*)/, (msg) ->
    team = msg.match[1]
    message = msg.match[2]

    robot
      .http("https://api.victorops.com/api-public/v1/team/#{team}/oncall/schedule")
      .headers(apiauth)
      .get() (err, res, body) ->
        res = JSON.parse "#{body}"
        if res["schedule"]?
          users = []
          for sched in res["schedule"]
            users.push sched["onCall"] unless sched["overrideOnCall"]? or sched["onCall"] in userFilter
            users.push sched["overrideOnCall"] if sched["overrideOnCall"]? and sched["overrideOnCall"]? not in userFilter
          alert=JSON.stringify({
            "message_type":"CRITICAL",
            "entity_display_name":"#{msg.message.user.name}",
            "state_message":"#{msg.message.user.name}: #{message}"
          })
          robot.http("https://alert.victorops.com/integrations/generic/20131114/alert/#{restapikey}/#{team}")
            .header('Content-Type', 'application/json')
            .post(alert) (err, res, body) ->
              if err
                msg.send "Could not send alert"
                msg.send "An error occurred: #{err}"
                msg.send "Users on-call for #{team}: #{users.join(', ')}"
                return
              if res.statusCode!=200
                msg.send "Could not send alert"
                msg.send "Status Code: #{res.statusCode}"
                msg.send "Users on-call for #{team}: #{users.join(', ')}"
                return
              msg.send "An alert has been sent"
              msg.send "Users on-call for #{team}: #{users.join(', ')}"
        else
          msg.reply "No team '#{team}' found."
