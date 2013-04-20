tweetInitialize = (name) ->
  # Setup OAuthServiceConfig
  consumerKey = ScriptProperties.getProperty "twitterConsumerKey_#{name}"
  consumerSecret = ScriptProperties.getProperty "twitterConsumerSecret_#{name}"
  oAuthConfig = UrlFetchApp.addOAuthService "twitter"
  oAuthConfig.setAccessTokenUrl "http://api.twitter.com/oauth/access_token"
  oAuthConfig.setRequestTokenUrl "http://api.twitter.com/oauth/request_token"
  oAuthConfig.setAuthorizationUrl "http://api.twitter.com/oauth/authorize"
  oAuthConfig.setConsumerKey consumerKey
  oAuthConfig.setConsumerSecret consumerSecret
  return

statusesUpdate = (info) ->
  # Setup optional parameters to point request at OAuthConfigService.  The "twitter"
  # value matches the argument to "addOAuthService" above.
  options =
    oAuthServiceName: "twitter"
    oAuthUseToken: "always"
    method: "POST"
  queryStrings = toQueryString info
  result = UrlFetchApp.fetch "http://api.twitter.com/1.1/statuses/update.json?#{queryStrings}", options
  Logger.log queryStrings
  Logger.log result.getResponseCode()
  Logger.log Utilities.jsonParse result.getContentText()
  return

toQueryString = (info) ->
  queryStrings = for key, value of info
    "#{key}=#{value}"
  queryStrings.join "&"

NumberOfCharacters = (text) ->
  text.length

getData = (sheetName, rowNames...) ->
  ss = SpreadsheetApp.getActiveSpreadsheet()
  spreadsheetService = new SpreadsheetService ss.getId()
  spreadsheetService.init()
  itemLength = ss.getSheetByName(sheetName).getLastRow() - 1
  random = Math.floor(Math.random() * itemLength) + 1
  rows = spreadsheetService.query sheetName, "no=#{random}"
  if rowNames.length > 0
    result = {}
    for key in rowNames
      result[key] = rows[key]
  else
    result = rows
  result

forceStatusesUpdate = (args...) ->
  tweetInitialize args[0]
  for i in [0, 1, 2]
    try
      data = getData(args...)
      statusesUpdate data
      return
    catch error
      Logger.log args
      Logger.log data
      Logger.log error
      if i is 2
        throw error
