#region Initialize default properties
$config = $configuration | ConvertFrom-Json
#endregion Initialize default properties

#region Support Functions
function Get-GoogleAccessToken() {
    ### exchange the refresh token for an access token
    $requestUri = "https://www.googleapis.com/oauth2/v4/token"
        
    $refreshTokenParams = @{
            client_id=$config.clientId;
            client_secret=$config.clientSecret;
            redirect_uri=$config.redirectUri;
            refresh_token=$config.refreshToken;
            grant_type="refresh_token"; # Fixed value
    };
    $response = Invoke-RestMethod -Method Post -Uri $requestUri -Body $refreshTokenParams -Verbose:$false
    $accessToken = $response.access_token
            
    #Add the authorization header to the request
    $authorization = [ordered]@{
        Authorization = "Bearer $($accesstoken)";
        'Content-Type' = "application/json; charset=utf-8";
        Accept = "application/json";
    }
    $authorization
}
#endregion Support Functions
    
#region Execute
    #Add the authorization header to the request
    $authorization = Get-GoogleAccessToken
    
    # https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get
    $uri = "https://sheets.googleapis.com/v4/spreadsheets/{0}/values/{1}?majorDimension=ROWS" -f $config.sheetId, $config.sheetRange
    $results = Invoke-RestMethod -Uri $uri -Method GET -Headers $authorization -Verbose:$false;
    

    $columns = $results.values[0]

    foreach($row in ($results.values | Select -Skip 1) ) {
        $person = @{};
        $person.ExternalId = $row[0];
        $person.DisplayName = "$($row[1]) $($row[2]) ($($row[0]))";
        
        for($i=0; $i -lt $columns.count; $i++) {
            $person[$columns[$i]] = "$($row[$i])";
        }

        Write-Output ($person | ConvertTo-Json)
    }

Write-Information "Person import completed";
#endregion Execute
