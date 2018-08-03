xquery version "3.0";

declare namespace json="http://www.json.org";

declare option exist:serialize "method=json media-type=text/javascript indent=no";

<collection json:array="true">
{
    request:get-data()
}
</collection>