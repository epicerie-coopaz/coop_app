# Coopaz app

## Release

Can't cross compile, you need to be on the platform you want to build it on...

Go to the github actions to have a downloadable release by platforms

### Linux
> flutter build linux --release

### Windows
> flutter build windows --release

## Google shits
### Google sheets API
Overview: https://developers.google.com/sheets/api/guides/concepts

Rest API: https://developers.google.com/sheets/api/reference/rest


### Google Auth

To properly function we need to setup some things to allow the app to comunicate to the cash register google sheets:

1) Create a Google project: https://developers.google.com/workspace/guides/get-started
2) Activate Google Sheets API: https://developers.google.com/workspace/guides/enable-apis
3) Create an API key
4) Pass this API key to the copaz app
