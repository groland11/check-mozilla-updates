# check-mozilla-updates
Check for Firefox and Thunderbird updates

Simple bash script that compares local Firefox and Thunderbird versions with current versions on Mozilla download server.
You can use this script in a cron job if you don't want to start Firefox or Thunderbird to check for new versions themselves.

## Requirements
- **curl** (retrieves list of all release versions from Mozilla download server)

## Usage
```
Usage: check-mozilla-updates.sh [-d] [-f]
        -d: Output debug messages
        -f: Download latest tarballs from Mozilla server (fetch)
```

## Example
```
$ ./check-mozilla-updates
Update Thunderbird (68.2.2 -> 68.3.0)
Update Firefox (70.0.1 -> 71.0)
```
