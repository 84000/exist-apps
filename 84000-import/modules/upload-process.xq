xquery version "3.1" encoding "UTF-8";

import module namespace config="http://agilehumanities.ca/apps/84000/config" at "config.xqm";
import module namespace util = "http://exist-db.org/xquery/util";
import module namespace hc = "http://expath.org/ns/http-client";
import module namespace transform = "http://exist-db.org/xquery/transform";

declare option exist:serialize "method=html media-type=text/html indent=no";

declare variable $xslt as document-node() := doc($config:oxGto84000-stylesheet); 

declare function local:base-file-name($upload-name as xs:string)
as xs:string
{
    replace(xmldb:encode($upload-name), "^(.*)\..*$", "$1")
};

declare function local:word-doc-name($upload-name as xs:string)
as xs:string
{
    concat(local:base-file-name($upload-name), '.docx')
};

declare function local:tei-doc-name($upload-name as xs:string)
as xs:string
{
    concat(local:base-file-name($upload-name), '.tei.xml')
};

let $field-name as xs:string := "file-upload"

let $upload-name as xs:string := request:get-uploaded-file-name($field-name)
let $upload-size as xs:double := request:get-uploaded-file-size($field-name)

(: Store the file as a binary file in the Word docs collection :)
let $doc-filename := local:word-doc-name($upload-name)
let $stored-file as xs:string? := 
    xmldb:store-as-binary(
        $config:wordDocs, 
        $doc-filename, 
        request:get-uploaded-file-data($field-name)
    )
let $doc-group:= sm:chgrp(xs:anyURI(concat($config:wordDocs, '/', $doc-filename)), $config:app-group)
let $doc-permissions:= sm:chmod(xs:anyURI(concat($config:wordDocs, '/', $doc-filename)), 'rw-rw-r--')

(: Convert the stored file to preliminary TEI by posting a request to the configured
 : word-conversion service.
:)
let $request := 
    <hc:request 
        method="post" 
        href="{$config:word-converter}" 
        override-media-type="application/xml">
        <hc:multipart media-type="multipart/form-data" boundary="existdb">
          <hc:header name="Accept" value="application/xml"/>
          <hc:header name="Cache-Control" value="no-cache" />
          <hc:header name="Content-Disposition" value="form-data; name=upload; filename=foo.xml"/>
          <hc:body media-type="application/vnd.openxmlformats-officedocument.wordprocessingml.document">
               { util:binary-doc($stored-file) }
          </hc:body>
        </hc:multipart>
    </hc:request>

let $response := hc:send-request($request)

let $headers := $response[1]
let $oxTEI as item() := $response[2]

(:
let $stored-name := concat($base-store-name, '.oxg.tei.xml')
let $stored-xml as xs:string? := xmldb:store($oxG-collection, $stored-name, $oxTEI)
let $oxdoc := doc($oxG-collection||"/"||$stored-name)
:)
(:
let $tei as item() := transform:transform($oxTEI, $xslt, ())
let $stored-tei := xmldb:store($config:TEIDocs, local:tei-doc-name($upload-name), $tei)
:)
let $tei as item() := transform:transform($oxTEI, $xslt, ())
let $tei-filename := local:tei-doc-name($upload-name)
let $stored-tei := xmldb:store($config:TEIDocs, $tei-filename, $tei)
let $tei-group:= sm:chgrp(xs:anyURI(concat($config:TEIDocs, '/', $tei-filename)), $config:app-group)
let $tei-permissions:= sm:chmod(xs:anyURI(concat($config:TEIDocs, '/', $tei-filename)), 'rw-rw-r--')

return
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>84000 Importer</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta data-template="config:app-meta"/>
        <link rel="shortcut icon" href="$shared/resources/images/exist_icon_16x16.ico"/>
        <link rel="stylesheet" type="text/css" href="$shared/resources/css/bootstrap-3.0.3.min.css"/>
        <link rel="stylesheet" type="text/css" href="resources/css/style.css"/>
        <script type="text/javascript" src="$shared/resources/scripts/jquery/jquery-1.7.1.min.js"/>
        <script type="text/javascript" src="$shared/resources/scripts/loadsource.js"/>
        <script type="text/javascript" src="$shared/resources/scripts/bootstrap-3.0.3.min.js"/>
    </head>
    <body id="body">
        <nav class="navbar navbar-default" role="navigation">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"/>
                    <span class="icon-bar"/>
                    <span class="icon-bar"/>
                </button>
                <a data-template="config:app-title" class="navbar-brand" href="../index.html">84000 Importer</a>
            </div>
            <div class="navbar-collapse collapse" id="navbar-collapse-1">
                <ul class="nav navbar-nav">
                    <li>
                        <a href="../index.html">Importer</a>
                    </li>
                    <li>
                        <a href="../storedDocs.html">Stored Docs</a>
                    </li>
                </ul>
            </div>
        </nav>
        <div id="content" class="container">
            <dl class="row">
                <dt class="col-sm-3">Original File</dt>
                <dd class="col-sm-9">{ $upload-name }</dd>

                <dt class="col-sm-3">Stored as</dt>
                <dd class="col-sm-9">{ $stored-file }</dd>
                
                <dt class="col-sm-3">TEI file</dt>
                <dd class="col-sm-9">{ $stored-tei }</dd>
            </dl>
  		</div>
        <footer>

        </footer>
    </body>
</html>