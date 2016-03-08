#!/usr/bin/env ruby

# A script to set your slack status with an optional message.
#
# 1. Get your api token here: https://api.slack.com/docs/oauth-test-tokens
# 2. Set the token in the environment: export SLACK_TOKEN=...
# 3. Save this file somewhere and make it executable (chmod +x slack.rb)
# 4. It's helpful to setup aliases for the example commands below, such
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
  puts "Usage: slack {away | back } [message]"
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
AWAY_URL = "#{SLACK_API_ROOT}/users.setPresence?presence=away&token=#{token}"
BACK_URL = "#{SLACK_API_ROOT}/users.setPresence?presence=auto&token=#{token}"

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

def set_status(message)
  profile = get_profile
  first_name = add_message_to_name(message, profile["first_name"])

  first_name_json = { first_name: first_name }.to_json
  profile = { profile: first_name_json }
  Net::HTTP.post_form(URI.parse(SET_PROFILE_URL), profile)
end

def set_status_away(message)
  Net::HTTP.post_form(URI.parse(AWAY_URL), {})
  set_status(message)
end

def set_status_back(message)
  Net::HTTP.post_form(URI.parse(BACK_URL), {})
  set_status(message)
end

def message_from_args
  if ARGV.length > 1
    message = ARGV[1..ARGV.length].join(" ")
  end

  message
end

case command
when "away"
  set_status_away(message_from_args)
when "back"
  set_status_back(message_from_args)
else
  puts "Usage: slack {away | back } [message]"
end
