# check-mozilla-status
Check for Firefox and Thunderbird updates

Simple bash script that compares local Firefox and Thunderbird versions with current versions on Mozilla download server.
You can use this script in a cron job if you don't want to start Firefox or Thunderbird to check for new versions themselves.

## Requirements
- **curl** (retrieves released versions from Mozilla download server)

## Usage
```
Usage: check-mozilla-updates.sh [-d]
        -d: Output debug messages
```

## Example
```
$ ./check-mozilla-updates
Update Thunderbird (68.2.2 -> 68.3.0)
Update Firefox (70.0.1 -> 71.0)
```
