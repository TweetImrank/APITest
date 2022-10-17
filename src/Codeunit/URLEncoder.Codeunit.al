codeunit 73101 TES_URLEncoder
{
    trigger OnRun()
    begin

    end;

    procedure Ansi2Ascii(_Text: Text): Text
    begin
        FctEncodeURIEncodingTableInit();
        Exit(ConvertStr(_Text, AnsiStr, AsciiStr));
    end;

    procedure Ascii2Ansi(_Text: Text): Text
    begin
        FctEncodeURIEncodingTableInit();
        Exit(ConvertStr(_Text, AsciiStr, AnsiStr));
    end;

    PROCEDURE FctEncodeURI(uri: Text) encodedUri: Text
    VAR
        i: Integer;
        b: Char;
        CharVar: ARRAY[32] OF Char;
        AsciiValue: Integer;
    BEGIN
        // First init encoding table once to save batch processing time
        IF HexDigits = '' THEN
            FctEncodeURIEncodingTableInit;

        encodedUri := '';
        uri := CONVERTSTR(uri, AsciiStr, AnsiStr);
        FOR i := 1 TO STRLEN(uri) DO BEGIN
            b := uri[i];
            // Full URI encode :
            IF (b IN [36, 38, 43, 44, 47, 58, 59, 61, 63, 64, 32, 34, 60, 62, 35, 37, 123, 125, 124, 92, 94, 126, 91, 93, 96]) OR
            // Simple URL encode (within ( ) without \ / : * ? " < > | )
            //IF (b IN [36, 38, 40, 41, 43, 44, 59, 61, 64, 32, 35, 37, 123, 125, 94, 126, 91, 93, 96]) OR
               (b >= 128)
            THEN BEGIN
                encodedUri := encodedUri + '%  ';
                EVALUATE(AsciiValue, FORMAT(b, 0, '<NUMBER>'));
                encodedUri[STRLEN(encodedUri) - 1] := HexDigits[(AsciiValue DIV 16) + 1];
                encodedUri[STRLEN(encodedUri)] := HexDigits[(AsciiValue MOD 16) + 1];
            END ELSE
                encodedUri := encodedUri + COPYSTR(uri, i, 1);
        END;
    END;

    LOCAL PROCEDURE FctEncodeURIEncodingTableInit()
    VAR
        i: Integer;
        b: Char;
        CharVar: ARRAY[32] OF Char;
        AsciiValue: Integer;
    BEGIN
        // Init ascii to ansii encoding table
        HexDigits := '0123456789ABCDEF';
        AsciiStr := '€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯ÝÝÝÝÝµ¶·¸ÝÝ++½¾++--+-+ÆÇ++--Ý-+';
        AsciiStr := AsciiStr + 'ÏÐÑÒÓÔiÖ×Ø++Ý_ÝÞîàáâãäåæçèéêëìíîïðñ=óôõö÷øùúûüýÝÿ';

        CharVar[1] := 196;
        CharVar[2] := 197;
        CharVar[3] := 201;
        CharVar[4] := 242;
        CharVar[5] := 220;
        CharVar[6] := 186;
        CharVar[7] := 191;
        CharVar[8] := 188;
        CharVar[9] := 187;
        CharVar[10] := 193;
        CharVar[11] := 194;
        CharVar[12] := 192;
        CharVar[13] := 195;
        CharVar[14] := 202;
        CharVar[15] := 203;
        CharVar[16] := 200;
        CharVar[17] := 205;
        CharVar[18] := 206;
        CharVar[19] := 204;
        CharVar[20] := 175;
        CharVar[21] := 223;
        CharVar[22] := 213;
        CharVar[23] := 254;
        CharVar[24] := 218;
        CharVar[25] := 219;
        CharVar[26] := 217;
        CharVar[27] := 180;
        CharVar[28] := 177;
        CharVar[29] := 176;
        CharVar[30] := 185;
        CharVar[31] := 179;
        CharVar[32] := 178;
        AnsiStr := 'Çüéâäàåçêëèïîì' + FORMAT(CharVar[1]) + FORMAT(CharVar[2]) + FORMAT(CharVar[3]) + 'æÆôö' + FORMAT(CharVar[4]);
        AnsiStr := AnsiStr + 'ûùÿÖ' + FORMAT(CharVar[5]) + 'ø£Ø×ƒáíóúñÑª' + FORMAT(CharVar[6]) + FORMAT(CharVar[7]);
        AnsiStr := AnsiStr + '®¬½' + FORMAT(CharVar[8]) + '¡«' + FORMAT(CharVar[9]) + '___¦¦' + FORMAT(CharVar[10]) + FORMAT(CharVar[11]);
        AnsiStr := AnsiStr + FORMAT(CharVar[12]) + '©¦¦++¢¥++--+-+ã' + FORMAT(CharVar[13]) + '++--¦-+¤ðÐ';
        AnsiStr := AnsiStr + FORMAT(CharVar[14]) + FORMAT(CharVar[15]) + FORMAT(CharVar[16]) + 'i' + FORMAT(CharVar[17]) + FORMAT(CharVar[18]);
        AnsiStr := AnsiStr + 'Ï++__¦' + FORMAT(CharVar[19]) + FORMAT(CharVar[20]) + 'Ó' + FORMAT(CharVar[21]) + 'ÔÒõ';
        AnsiStr := AnsiStr + FORMAT(CharVar[22]) + 'µ' + FORMAT(CharVar[23]) + 'Þ' + FORMAT(CharVar[24]) + FORMAT(CharVar[25]);
        AnsiStr := AnsiStr + FORMAT(CharVar[26]) + 'ýÝ¯' + FORMAT(CharVar[27]) + '­' + FORMAT(CharVar[28]) + '=¾¶§÷¸' +
                               FORMAT(CharVar[29]);
        AnsiStr := AnsiStr + '¨·' + FORMAT(CharVar[30]) + FORMAT(CharVar[31]) + FORMAT(CharVar[32]) + '_ ';
    END;

    var
        HexDigits: Text[30];
        AsciiStr: Text[250];
        AnsiStr: Text[250];
}
