# HelloID-Conn-Prov-Source-Google-Sheets

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |
<br />
<p align="center"> 
  <img src="https://www.tools4ever.nl/connector-logos/googlesheets-logo.png">
</p>
<br />
In this example we are going to connect to the Google Sheets API using OAuth2.0 and the Powershell.

<!-- TABLE OF CONTENTS -->
## Table of Contents
* [Getting Started](#getting-started)
* [Setting up the Google API access](#setting-up-the-google-api-access)
* [Authorization](#authorization)
* [Setup the PowerShell connector](#setup-the-powerShell-connector)

<!-- GETTING STARTED -->
## Getting Started
By using this connector you will have the ability to create one of the following items in Google GSuite:

* Read data from Google Sheet (see https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get)


## Setting up the Google API access
 1. Go to Google Developers Console and create a new project by clicking on the top bar and choose new project. Give your project a name and click create. When you are done, click the top bar again and select your newly created project.
 2. You will see the empty dashboard where we need to select which API we want to interact with, In this example we are retrieving Drive data so we select the Google Drive API. Click Enable after which you will be redirected back to the dashboard.
 3. As stated on the dashboard, go to the credentials menu item and click on + Create Credentials and choose OAuth client ID.
 4. Application type choose Web application.
 5. Fill in a name you like for the OAuth 2.0 client ID.
 6. For Authorized redirect URIs you can specify http://localhost/oauth2callback
 7. Click create the OAuth 2.0 consent screen and we will get the credentials from the credentials page.
 8. The Client ID and Client secret of the new OAuth client we use in the example scripts below.

## Authorization

### Automated Method
1. Run the following PowerShell script as Administrator
2. The script will prompt your for Client ID and Secret
3. The browser will then open and request authorization
4. After confirming authorization, the refresh token will be shown in the browser and console
```
#Input from User
    $ClientID = Read-Host "Please enter your Client ID"
    $ClientSecret = Read-Host "Please enter your Client Secret"

#Obtain Authorization Code
    $redirectUri = "http://localhost/oauth2callback"
    $authUri = "https://accounts.google.com/o/oauth2/auth?client_id=$($ClientID)&scope=https://www.googleapis.com/auth/spreadsheets.readonly&response_type=code&redirect_uri=http://localhost/oauth2callback&access_type=offline&approval_prompt=force"

#Listen for Authorization Code Request
$HttpListener = New-Object System.Net.HttpListener
$HttpListener.Prefixes.Add("http://+/oauth2callback/")
$HttpListener.Start()

#Launch Browser to authorize
Start-Process $authUri

While ($HttpListener.IsListening) {
    $HttpContext = $HttpListener.GetContext()
    $HttpRequest = $HttpContext.Request
    $RequestUrl = $HttpRequest.Url.OriginalString
     
    #Authorization Code
    $code = $HttpRequest.QueryString['code'];
    Write-Host "Auth Code: $($code)";

    #Request Refresh Token
    $requestUri = "https://www.googleapis.com/oauth2/v4/token"
    $body = @{
        code=$code;
        client_id=$clientId;
        client_secret=$clientSecret;
        redirect_uri=$redirectUri;
        grant_type="authorization_code"; # Fixed value
    };
    $tokens = Invoke-RestMethod -Uri $requestUri -Method POST -Body $body;
    Write-Host "Refresh Token: $($tokens.refresh_token)"

    #Respond with Refresh Token
    $HttpResponse = $HttpContext.Response
    $HttpResponse.Headers.Add("Content-Type","text/plain")
    $HttpResponse.StatusCode = 200
    $ResponseBuffer = [System.Text.Encoding]::UTF8.GetBytes("Refresh Token: $($tokens.refresh_token)")
    $HttpResponse.ContentLength64 = $ResponseBuffer.Length
    $HttpResponse.OutputStream.Write($ResponseBuffer,0,$ResponseBuffer.Length)
    $HttpResponse.Close()

    #Stop Listener
    $HttpListener.Stop()
 }
```

### Manual Method
#### Getting the authorization code 
With the authorization code, we can get the refresh token. We only need the refresh token. 
1. To get the authorization code please use the URL below and replace the {replaceclientid} with the values from the OAuth client we created before.
```
https://accounts.google.com/o/oauth2/auth?client_id={replaceclientid}&scope=https://www.googleapis.com/auth/spreadsheets.readonly&response_type=code&redirect_uri=http://localhost/oauth2callback&access_type=offline&approval_prompt=force
```
2. Open the URL in a webbrowser of your choosing.
3. The browser will be redirected to the redirect URI. We will need to copy the code value out of the URL in the address bar, so we can obtain a refresh token in the next section.
```
Example
http://localhost/oauth2callback?code=4/QhUXhB********************z9jGKkhvac2&
The code would be 4/QhUXhB********************z9jGKkhvac2&
```

#### Getting the refreshtoken
1. To exchange the Authorization code for the refresh token, we will use Powershell to make a call to https://www.googleapis.com/oauth2/v4/token. 
2. Fill in Authorization code, Client Id, Client Secret and Redirect Uri from the Google Developer Console and run the [Authorization.GetRefreshToken.ps1](https://github.com/Tools4everBV/HelloID-Conn-Prov-Target-Google-Workspace/blob/master/Scripts/Authorization.GetRefreshToken.ps1) in the repo. It will store the refresh token in a text file so you can use it later on.

Note: The claimed authorization code can be exchanged for a refreshtoken only once, otherwise you have to request a new authorization code as described above.

## Setup the PowerShell connector
1. Add a new 'Target System' to HelloID and make sure to import all the necessary files.

    - [ ] configuration.json
    - [ ] persons.ps1

2. Fill in the required fields on the 'Configuration' tab. See also, [Setting up the Google API access](#setting-up-the-google-api-access)

![image](Assets/config.png)
* Client ID
* Client Secret
* Redirect URI
* Refresh Token
* Sheet ID
  * The ID of the spreadsheet to retrieve data from.
* Sheet Range
  * The A1 notation of the values to retrieve.

_For more information about our HelloID PowerShell connectors, please refer to our general [Documentation](https://docs.helloid.com/hc/en-us/articles/360012557600-Configure-a-custom-PowerShell-source-system) page_
 
# HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
