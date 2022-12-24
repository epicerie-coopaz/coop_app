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

REST: https://developers.google.com/sheets/api/reference/rest

### Google Apps Scripts API
Overview: https://developers.google.com/apps-script/guides/sheets/macros

REST: https://developers.google.com/apps-script/api/reference/rest/

### Setup and Google Auth

To properly function we need to setup some things to allow the app to comunicate to the cash register google sheets:

1) Create a Google project: https://developers.google.com/workspace/guides/get-started
2) Activate "Google Sheets", "Apps Script", "Drive", "GMail" APIs: https://developers.google.com/workspace/guides/enable-apis
3) Create an OAuth2 ID client
4) Pass the ID client and SecretID to coopaz app (file in secret folder)
5) Link the Apps Script to the Google project
6) Deploy the Apps Script as an "API executable"
