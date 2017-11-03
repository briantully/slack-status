#!/usr/bin/env ruby

# A script to update your slack presence and set your slack status with status_text and status_emoji.
#
# 1. Get your api token here: https://api.slack.com/docs/oauth-test-tokens
# 2. Set the token in the environment: export SLACK_TOKEN=...
# 3. Set the slack url in the environment: export SLACK_URL=yourteam.slack.com
# 4. Save this file somewhere and make it executable (chmod +x slack.rb)
# 5. It's helpful to setup an alias for this script, such as
# => alias slack='~/slack.rb'
# => so that you can run commands via 'slack away brb'
#
# Examples: [message] is optional
# slack away [message]
# slack coffee
# slack lunch
# slack walkies
# slack dog
# slack pto [message]
# slack zoom [message]
# slack meeting
# slack office
# slack home [message]
# slack back [message]
#

require "net/http"
require "json"

command = ARGV[0]
if command.nil?
  puts "Usage: slack { away [message] | coffee | lunch | walkies | dog | pto [message] | zoom [message] | meeting | loadtesting | office | home [message] | back [message] }"
  Kernel.exit(-1)
end

slack_url = ENV["SLACK_URL"]
if slack_url.nil?
  puts "SLACK_URL must be defined in the environment"
  Kernel.exit(-1)
end

token = ENV["SLACK_TOKEN"]
if token.nil?
  puts "SLACK_TOKEN must be defined in the environment"
  Kernel.exit(-1)
end

SLACK_API_ROOT="#{slack_url}/api"
GET_PROFILE_URL = "#{SLACK_API_ROOT}/users.profile.get?token=#{token}"
SET_PROFILE_URL = "#{SLACK_API_ROOT}/users.profile.set?token=#{token}"

COFFEE_STATUS = { "status_text": "Getting coffee", "status_emoji": ":coffee:" }.to_json
LUNCH_STATUS = { "status_text": "Lunch", "status_emoji": ":fork_and_knife:" }.to_json
WALKIES_STATUS = { "status_text": "Walkies", "status_emoji": ":walking:" }.to_json
DOG_STATUS = { "status_text": "Walking the pooch", "status_emoji": ":dog:" }.to_json
MEETING_STATUS = { "status_text": "In a meeting", "status_emoji": ":calendar:" }.to_json
LOADTESTING_STATUS = { "status_text": "Load Testing", "status_emoji": ":chart_with_upwards_trend:" }.to_json
OFFICE_STATUS = { "status_text": "In the office", "status_emoji": ":office:" }.to_json

AWAY_URL = "#{SLACK_API_ROOT}/users.setPresence?presence=away&token=#{token}"
BACK_URL = "#{SLACK_API_ROOT}/users.setPresence?presence=auto&token=#{token}"

# Get the profile from the slack API.
def get_profile
  response_json = Net::HTTP.get(URI.parse(GET_PROFILE_URL))
  response = JSON.parse(response_json)
  unless response["ok"]
    puts "get_profile failed:"
    puts response
    Kernel.exit(-2)
  end
  response["profile"]
end

# Set the slack status with the given message.
def set_status(message)
  profile = get_profile
  profile = { profile: message }
  Net::HTTP.post_form(URI.parse(SET_PROFILE_URL), profile)
end

# Set the slack status to away with the given message.
def set_status_away(message)
  Net::HTTP.post_form(URI.parse(AWAY_URL), {})
  set_status(message)
end

# Set the slack status to present with the given message.
def set_status_back(message)
  Net::HTTP.post_form(URI.parse(BACK_URL), {})
  set_status(message)
end

# Get the message from command line args, assuming anything after the first
# argument is the message.
def message_from_args
  if ARGV.length > 1
    message = ARGV[1..ARGV.length].join(" ")
  end
  message
end

case command
when "away"
  if message_from_args
    message = message_from_args
  else
    message = "Away from keyboard"
  end
  AWAY_STATUS = { "status_text": "#{message}", "status_emoji": ":speech_balloon:" }.to_json
  set_status_away(AWAY_STATUS)

when "coffee"
  set_status_away(COFFEE_STATUS)

when "lunch"
  set_status_away(LUNCH_STATUS)

when "walkies"
  set_status_away(WALKIES_STATUS)

when "dog"
  set_status_away(DOG_STATUS)

when "pto"
  if message_from_args
    message = message_from_args
  else
    message = "PTO"
  end
  PTO_STATUS = { "status_text": "#{message}", "status_emoji": ":palm_tree:" }.to_json
  set_status_away(PTO_STATUS)

when "zoom"
  if message_from_args
    message = message_from_args
  else
    message = "Zoom meeting"
  end
  ZOOM_STATUS = { "status_text": "#{message}", "status_emoji": ":zoom:" }.to_json
  set_status_back(ZOOM_STATUS)

when "meeting"
  set_status_back(MEETING_STATUS)

when "loadtesting"
  set_status_back(LOADTESTING_STATUS)

when "office"
  set_status_back(OFFICE_STATUS)

when "home"
  if message_from_args
  message = message_from_args
  else
    message = "Working remotely"
  end
  HOME_STATUS = { "status_text": "#{message}", "status_emoji": ":house_with_garden:" }.to_json
  set_status_back(HOME_STATUS)

when "back"
  if message_from_args
  message = message_from_args
  else
    message = "Working remotely"
  end
  BACK_STATUS = { "status_text": "#{message}", "status_emoji": ":house_with_garden:" }.to_json
  set_status_back(BACK_STATUS)

else
  puts "Usage: slack { away [message] | coffee | lunch | walkies | dog | pto [message] | zoom [message] | meeting | loadtesting | office | home [message] | back [message] }"
end
