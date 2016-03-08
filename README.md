# slack-status
A ruby script to set your slack status, including an optional "away" message.

# What?
Slack is great, but it's missing a crucial feature for remote team collaboration: you can't set an away message.

This is a short message to let your teammates know your status. For example, "lunch", or "bb 3:30". For a 100% remote team, this subtle communication is crucial, and improves the efficiency of the team.

There is a kludgy, RSI inducing way to achieve this in slack: edit your profile and set your first name to something like "Ryan (lunch)". This works, but it's a lot of mousing around.

This script does it for you, by using an undocumented api to set the first name in your slack profile.

Note: This hack is useful only if your co-worker's slack preferences are set to "display real names". See the Slack Preferences / Messages & Media / Display Options:

![Settings](https://raw.githubusercontent.com/rydama/slack-status/master/slack-settings.png)


# Installation

First, get your slack api token [here](https://api.slack.com/docs/oauth-test-tokens)

Example setup for Mac OSX:

1. Save [slack.rb](https://raw.githubusercontent.com/rydama/slack-status/master/slack.rb) in your home directory
2. Open a terminal
3. `chmod +x slack.rb`
4. `export SLACK_URL=https://yourteam.slack.com`
4. `export SLACK_TOKEN=your-slack-token`


It's helpful to setup aliases, for example:

```
alias away='~/slack.rb away'
alias lunch='~/slack.rb away lunch'
alias back='~/slack.rb back'
```

# Example Usage

```
./slack.rb {away | back } [message]
./slack.rb away lunch
./slack.rb back
./slack.rb back in meeting
```
