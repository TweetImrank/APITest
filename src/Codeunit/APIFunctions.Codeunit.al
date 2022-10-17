codeunit 73100 "Test API"
{
    trigger OnRun()
    begin

    end;

    procedure BottomLineAuthentication()
    var
        Client: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Content: HttpContent;
        URL: Text;
        ResponseHeaders: HttpHeaders;
        HeaderValue: array[10] of text;
        Response: Text;
        XCSRF: Text;
        TempText: Text;
        JSESSIONIOD: Text;
        TSHEADER: Text;
    begin
        //>> ************************ Perform Handshake
        RequestMessage.Method := 'GET';

        URL := 'https://payments.cat.uk.pt-x.com/payments-service/api/security/handshake';
        RequestMessage.SetRequestUri(URL);

        Content.GetHeaders(Headers);
        Headers.Clear();

        Client.Send(RequestMessage, ResponseMessage);

        If not ResponseMessage.IsSuccessStatusCode then
            Error('Error: %1 %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);

        //Content := ResponseMessage.Content;
        ResponseHeaders := ResponseMessage.Headers();

        // Get X-CSRF
        ResponseHeaders.GetValues('X-CSRF', HeaderValue);
        XCSRF := HeaderValue[1];

        Message(XCSRF);

        // Get JSESSIONID
        ResponseHeaders.GetValues('Set-Cookie', HeaderValue);
        TempText := HeaderValue[1];
        Message(TempText);
        JSESSIONIOD := CopyStr(TempText, 1, StrPos(TempText, '; path=') - 1);

        Message(JSESSIONIOD);

        // Get TS Cookie Header
        TempText := HeaderValue[2];
        TSHEADER := CopyStr(TempText, 1, StrPos(TempText, '; Path=') - 1);

        Message(TSHEADER);

        // Authenticate to get Token
        CallAuth(XCSRF, JSESSIONIOD, TSHEADER);

        //<< ************************ Perform Handshake
    end;

    procedure CallAuth(pXCSRF: Text; pJESSIONID: Text; pTSHEADER: Text)
    var
        RequestMessage: HttpRequestMessage;
        URL: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        JsonObjectHeader: JsonObject;
        JsonObjectLineEmail: JsonObject;
        JsonObjectLinePassword: JsonObject;
        JsonObjectApiVersion: JsonObject;
        JsonArrayVar: JsonArray;
        JsonBody: Text;
        Email: Text;
        Pass: Text;
        ResponseText: Text;
        HeaderValues: array[2] of text;
        i: Integer;
        HeaderKeys: List of [text];
        SelectedHeaderKey: Text;
        ResponseHeaders: HttpHeaders;
        JsonText: TextBuilder;
        TempBlob: Codeunit "Temp Blob";
        FileInstream: InStream;
        FileOutsream: OutStream;
        ClientFileName: text;
        URLEncoder: Codeunit TES_URLEncoder;
    begin
        RequestMessage.Method := 'POST';

        URL := 'https://payments.cat.uk.pt-x.com/payments-service/api/security/login';
        RequestMessage.SetRequestUri(URL);

        Client.Clear();

        RequestHeaders.Clear();
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Host', 'payments.cat.uk.pt-x.com');
        RequestHeaders.Add('User-Agent', 'api-v2.5');
        //RequestHeaders.Add('Cookie', pJESSIONID + '; ' + pTSHEADER);
        RequestHeaders.Remove('Cookie');
        //RequestHeaders.Add('Cookie', URLEncoder.FctEncodeURI(pJESSIONID + '; ' + pTSHEADER));
        //Message('Endoding ' + URLEncoder.FctEncodeURI(pJESSIONID));
        RequestHeaders.Add('Cookie', pJESSIONID);
        //RequestHeaders.TryAddWithoutValidation('Cookie', pJESSIONID);
        RequestHeaders.Add('X-CSRF', pXCSRF);
        //RequestHeaders.Add('Accept-Encoding', 'gzip, deflate, br');
        //RequestHeaders.Add('Cache-Control', 'no-cache');
        //RequestHeaders.Add('Connection', 'keep-alive');

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        //ContentHeaders.Add('Content-Length', '450');

        // Fill Body
        Email := 'TES_PTXAPI@bartscharity.org.uk';   //TBC
        Pass := 'TESuser01';                         //TBC

        /*
        JsonObjectLineEmail.Add('key', 'com.bottomline.security.provider.login.email');
        JsonObjectLineEmail.Add('value', Email);
        JsonArrayVar.Add(JsonObjectLineEmail);
        JsonObjectLinePassword.Add('key', 'com.bottomline.security.provider.login.password');
        JsonObjectLinePassword.Add('value', Pass);
        JsonArrayVar.Add(JsonObjectLinePassword);

        JsonObjectHeader.Add('loginTokens', JsonArrayVar);

        JsonObjectApiVersion.Add('major', '1');
        JsonObjectApiVersion.Add('minor', '0');
        JsonObjectApiVersion.Add('patch', '0');
        JsonObjectApiVersion.Add('build', '0');

        //JsonObjectHeader.Add('apiVersion', JsonObjectApiVersion);
        JsonObjectHeader.Add('apiVersion', '{"major": "1","minor": "0","patch": "0","build":"0"}');
        JsonObjectHeader.Add('purpose', 'cpay-auth');
        JsonObjectHeader.Add('tokenLocation', 'HEADER');
        //JsonObjectHeader.WriteTo(JsonBody);
        */

        //JsonText.Append('{"loginTokens":[{"key":"com.bottomline.security.provider.login.email","value":"TES_PTXAPI@bartscharity.org.uk"},{"key":"com.bottomline.security.provider.login.password","value":"TESuser01"}],"apiVersion":"{\"major\":\"1\",\"minor\":\"0\",\"patch\":\"0\",\"build\":\"0\"}","purpose":"cpay-auth","tokenLocation":"HEADER"}');
        JsonText.Append('{"loginTokens":[{"key":"com.bottomline.security.provider.login.email","value":"' + Email + '"},{"key":"com.bottomline.security.provider.login.password","value":"' + Pass + '"}],"apiVersion":"{\"major\":\"1\",\"minor\":\"0\",\"patch\":\"0\",\"build\":\"0\"}","purpose":"cpay-auth","tokenLocation":"HEADER"}');
        //JsonText.Append('{"loginTokens":[{"key":"com.bottomline.security.provider.login.email","value":"TES_PTXAPI@bartscharity.org.uk"},{"key":"com.bottomline.security.provider.login.password","value":"TESuser01"}],"apiVersion":"{"major":"1","minor":"0","patch":"0","build":"0"}","purpose":"cpay-auth","tokenLocation":"HEADER"}');
        JsonBody := JsonText.ToText();

        ClientFilename := 'test.txt';
        TempBlob.CreateOutStream(FileOutsream, TextEncoding::UTF8);
        /*
        FileOutsream.WriteText('Host: payments.cat.uk.pt-x.com');
        FileOutsream.WriteText('User-Agent: api-v2.5');
        FileOutsream.WriteText('Cookie: ' + pJESSIONID);
        FileOutsream.WriteText('X-CSRF: ' + pXCSRF);
        FileOutsream.WriteText('Content-Type : application/json');
        FileOutsream.WriteText();
        */
        FileOutsream.WriteText(JsonBody);
        TempBlob.CreateInStream(FileInstream, TextEncoding::UTF8);
        //DownloadFromStream(FileInstream, '', '', '', ClientFilename);

        //JsonBody := '{"loginTokens":[{"key":"com.bottomline.security.provider.login.email","value":"TES_PTXAPI@bartscharity.org.uk"},{"key":"com.bottomline.security.provider.login.password","value":"TESuser01"}],"apiVersion":{\"major\":\"1\",\"minor\":\"0\",\"patch\":\"0\",\"build\":\"0\"},"purpose":"cpay-auth","tokenLocation":"HEADER"}';
        //JsonBody := '{"loginTokens":[{"key":"com.bottomline.security.provider.login.email","value":"TES_PTXAPI@bartscharity.org.uk"},{"key":"com.bottomline.security.provider.login.password","value":"TESuser01"}],"apiVersion":{"major":"1","minor":"0","patch":"0","build":"0"},"purpose":"cpay-auth","tokenLocation":"HEADER"}';

        //Message(JsonBody);

        //Content.WriteFrom(JsonBody);
        Content.WriteFrom(FileInstream);
        RequestMessage.Content := Content;

        Client.Send(RequestMessage, ResponseMessage);

        // Parse the response and save the token and X-CSRF
        ResponseMessage.Content().ReadAs(ResponseText);
        //RequestHeaders.GetValues('Cookie', HeaderValues);
        //Message('Header Cookie - ' + HeaderValues[1]);

        ResponseHeaders := ResponseMessage.Headers();
        HeaderKeys := ResponseHeaders.Keys();
        //ResponseHeaders.GetValues('Set-Cookie', HeaderValues);
        //Message('H - ' + HeaderValues[1]);
        //Message('H - ' + HeaderValues[2]);

        /*
        ClientFilename := 'test-response.txt';
        TempBlob.CreateOutStream(FileOutsream, TextEncoding::UTF8);
        FileOutsream.WriteText('Host: payments.cat.uk.pt-x.com');
        FileOutsream.WriteText('User-Agent: api-v2.5');
        FileOutsream.WriteText('Cookie: ' + pJESSIONID);
        FileOutsream.WriteText('X-CSRF: ' + pXCSRF);
        FileOutsream.WriteText('Content-Type : application/json');
        FileOutsream.WriteText();
        FileOutsream.WriteText(JsonBody);
        */

        For i := 1 to HeaderKeys.Count do begin
            HeaderKeys.Get(i, SelectedHeaderKey);
            ResponseHeaders.GetValues(SelectedHeaderKey, HeaderValues);
            //FileOutsream.WriteText(SelectedHeaderKey + ': ' + HeaderValues[1]);
            //If SelectedHeaderKey = 'Set-Cookie' then
            //    FileOutsream.WriteText(SelectedHeaderKey + ': ' + HeaderValues[2]);
            Message(SelectedHeaderKey + ': ' + HeaderValues[1]);
            If SelectedHeaderKey = 'Set-Cookie' then
                Message(SelectedHeaderKey + ': ' + HeaderValues[2]);
        end;

        /*
        TempBlob.CreateInStream(FileInstream, TextEncoding::UTF8);
        DownloadFromStream(FileInstream, '', '', '', ClientFilename);
        */
        Message(ResponseText);

        If not ResponseMessage.IsSuccessStatusCode then
            Error('Error: %1 %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
    end;

    /*
    procedure UploadFile(pXCSRF: Text; pJESSIONID: Text; pTSHEADER: Text; pAuthToken: Text; pPaymentProfileID: Text)
    var
        RequestMessage: HttpRequestMessage;
        URL: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        JsonObjectHeader: JsonObject;
        JsonObjectLineEmail: JsonObject;
        JsonObjectLinePassword: JsonObject;
        JsonObjectApiVersion: JsonObject;
        JsonArrayVar: JsonArray;
        JsonBody: Text;
        Email: Text;
        Pass: Text;
    begin
        RequestMessage.Method := 'POST';

        URL := 'https://payments.cat.uk.pt-x.com/payments-service/api/file/' + pPaymentProfileID;
        RequestMessage.SetRequestUri(URL);

        Client.Clear();

        RequestHeaders.Clear();
        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('User-Agent', 'api-v2.5');
        //RequestHeaders.Add('Cookie', pJESSIONID + ';' + pTSHEADER);
        RequestHeaders.Add('Cookie', pJESSIONID);
        RequestHeaders.Add('X-CSRF', pXCSRF);
        RequestHeaders.Add('com.bottomline.auth.token', pAuthToken);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'multipart/form-data;boundary=boundary');



        // Fill Body
        Email := 'tesadmin@bartscharity.com';   //TBC
        Pass := 'test';                         //TBC

        JsonObjectLineEmail.Add('key', 'com.bottomline.security.provider.login.email');
        JsonObjectLineEmail.Add('value', Email);
        JsonArrayVar.Add(JsonObjectLineEmail);
        JsonObjectLinePassword.Add('key', 'com.bottomline.security.provider.login.password');
        JsonObjectLinePassword.Add('value', Pass);
        JsonArrayVar.Add(JsonObjectLinePassword);

        JsonObjectHeader.Add('loginTokens', JsonArrayVar);

        JsonObjectApiVersion.Add('major', '1');
        JsonObjectApiVersion.Add('minor', '0');
        JsonObjectApiVersion.Add('patch', '0');
        JsonObjectApiVersion.Add('build', '0');

        JsonObjectHeader.Add('apiVersion', JsonObjectApiVersion);
        JsonObjectHeader.Add('purpose', 'cpay-auth');
        JsonObjectHeader.Add('tokenLocation', 'HEADER');
        JsonObjectHeader.WriteTo(JsonBody);

        Content.WriteFrom(JsonBody);
        RequestMessage.Content := Content;

        Client.Send(RequestMessage, ResponseMessage);

        // Parse the response and save the token and X-CSRF

        If not ResponseMessage.IsSuccessStatusCode then
            Error('Error: %1 %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
    end;
    */

    var
        myInt: Integer;
}