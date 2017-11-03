#!/usr/bin/env ruby

# A script to set your slack status with an optional message.
#
# 1. Get your api token here: https://api.slack.com/docs/oauth-test-tokens
# 2. Set the token in the environment: export SLACK_TOKEN=...
# 3. Set the slack url in the environment: export SLACK_URL=yourteam.slack.com
# 4. Save this file somewhere and make it executable (chmod +x slack.rb)
# 5. It's helpful to setup aliases for the example commands below, such
#    as alias lunch='~/slack.rb away lunch'
#
# Examples:
# ./slack.rb {away | back } [message]
# ./slack.rb away lunch
# ./slack.rb back
# ./slack.rb back in meeting
#
# The command adds the message, if any, at the end of the first name.
# For example: Ryan (lunch)

require "net/http"
require "json"

command = ARGV[0]
if command.nil?
  puts "Usage: slack { away | coffee | lunch | walkies | pto | zoom | meeting | loadtesting | back } [message]"
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

BACK_STATUS = { "status_text": "Working remotely", "status_emoji": ":house_with_garden:" }.to_json
COFFEE_STATUS = { "status_text": "Getting coffee", "status_emoji": ":coffee:" }.to_json
LUNCH_STATUS = { "status_text": "Lunch", "status_emoji": ":fork_and_knife:" }.to_json
WALKIES_STATUS = { "status_text": "Walkies", "status_emoji": ":walking:" }.to_json
ZOOM_STATUS = { "status_text": "Zoom meeting", "status_emoji": ":zoom:" }.to_json
MEETING_STATUS = { "status_text": "In a meeting", "status_emoji": ":calendar:" }.to_json
LOADTESTING_STATUS = { "status_text": "Load Testing", "status_emoji": ":chart_with_upwards_trend:" }.to_json

AWAY_URL = "#{SLACK_API_ROOT}/users.setPresence?presence=away&token=#{token}"
BACK_URL = "#{SLACK_API_ROOT}/users.setPresence?presence=auto&token=#{token}"

# Appends the message to the name. The message is surrounded by parens.
# If the name already contains parens, the old message is trimmed off
# the name before the new message is appended.
# Returns something like: Ryan (at lunch)
def add_message_to_name(message, name)
  # Remove any existing message
  index = name.index(" (")
  if index && index > 0
    name = name[0..index - 1]
  end

  if message.nil? || message.strip.empty?
    name
  else
    "#{name} (#{message.strip})"
  end
end

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
  #first_name = add_message_to_name(message, profile["first_name"])
  #first_name_json = { first_name: first_name }.to_json
  # profile = { profile: first_name_json }
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
  AWAY_STATUS = { "status_text": "#{message_from_args}", "status_emoji": ":anarchy:" }.to_json
  set_status_away(AWAY_STATUS)
when "coffee"
  set_status_away(COFFEE_STATUS)
when "lunch"
  set_status_away(LUNCH_STATUS)
when "walkies"
  set_status_away(WALKIES_STATUS)
when "pto"
  set_status_away(PTO_STATUS)
when "zoom"
  set_status_back(ZOOM_STATUS)
when "meeting"
  set_status_back(MEETING_STATUS)
when "loadtesting"
  set_status_back(LOADTESTING_STATUS)
when "back"
  set_status_back(BACK_STATUS)

else
  puts "Usage: slack { away | coffee | lunch | walkies | pto | zoom | meeting | loadtesting | back } [message]"
end
