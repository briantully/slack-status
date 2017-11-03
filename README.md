# slack-status
A ruby script to set your slack status, including an optional "away" message.

This is a fork of https://github.com/rydama/slack-status that updates the script to follow Slack's new WebAPI.

In addition to setting one's profile presence (away | auto), this fork now allows you to specify custom status_text and status_emoji.

There are several custom status options to choose from (see below).

## What?
Slack is great, and while you can manually set the status_text and status_emoji in the Slack.app UI, it is a rather tedious process.

Slack limits teams to five (5) custom status presets that can be selected in the UI. So if you like using other "presets" of status_text and status_emoji, you're forced to choose them manually each time, which involves several clicks and searching for the correct emoji icon.

This script is an attempt to streamline the process and allow you to add more "custom presets" that can be triggered from the command line.

Please suggest more custom presets or feel free to fork/contribute and I'll merge new presets into the script :)


## Installation

First, get your slack api token [here](https://api.slack.com/docs/oauth-test-tokens)

Example setup for Mac OSX:

1. Save [slack.rb](https://raw.githubusercontent.com/briantully/slack-status/master/slack.rb) in your home directory
2. Open a terminal
3. `chmod +x slack.rb`
4. Edit `.bashrc` and add the following:
```
export SLACK_URL=https://yourteam.slack.com
export SLACK_TOKEN=your-slack-token
alias slack="$HOME/slack.rb"
```
5. Finally, `source .bashrc`

## Example Usage

```
# Examples:
slack away [message]
slack coffee
slack lunch
slack walkies
slack dog
slack pto
slack zoom
slack meeting
slack back
```
