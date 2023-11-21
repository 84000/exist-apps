<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:bcrdb="http://www.bcrdb.org/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" xmlns:bdo="http://purl.bdrc.io/ontology/core/" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:ops="http://operations.84000.co" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="request" select="/eft:response/eft:request"/>
    <xsl:variable name="page-attributes" select="($request/eft:segment ! concat('segment-id[]=', @id), $request/@text-id ! concat('text-id=', .), $request/@folio-index ! concat('folio-index=', .))" as="xs:string*"/>
    <xsl:variable name="translation" select="/eft:response/eft:translation"/>
    <xsl:variable name="tmx" select="/eft:response/tmx:tmx[tmx:body/tmx:tu[tmx:tuv[@xml:lang eq 'bo']][tmx:prop[@name eq 'eft:folio-index-in-text']]]"/>
    <xsl:variable name="rdf" select="/eft:response/rdf:RDF"/>
    <xsl:variable name="folio-index-requested" select="($request/@folio-index[not(. eq '')], 1)[1] ! xs:integer(.)"/>
    <xsl:variable name="folio-indexes" select="distinct-values($tmx/tmx:body/tmx:tu/tmx:prop[@name eq 'eft:folio-index-in-text']/text() ! xs:integer(.))"/>
    <xsl:variable name="units-selected" select="$tmx//tmx:tu[@id = $request/eft:segment/@id]"/>
    <xsl:variable name="entities-suggested" select="/eft:response/eft:entities/eft:entity[not(eft:instance/@id = $glossary-prioritised/@xml:id)]"/>
    <xsl:variable name="entities-regex" select="/eft:response/eft:entities/eft:regex/text()" as="xs:string"/>
    <xsl:variable name="segments-joined" as="text()">
        <xsl:value-of select="string-join($request/eft:segment, ' ')"/>
    </xsl:variable>
    <xsl:variable name="segments-raw" as="text()">
        <xsl:value-of select="normalize-space(string-join($units-selected/tmx:tuv[@xml:lang eq 'bo']/tmx:seg, ' '))"/>
    </xsl:variable>
    
    <xsl:template match="/eft:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="container-class" select="'container'"/>
                <xsl:with-param name="tab-content">
                    
                    <!-- Text title and pagination -->
                    <header class="center-vertical full-width">
                        
                        <!-- Text title -->
                        <div>
                            <nav role="navigation" aria-label="Breadcrumbs" class="sml-margin bottom">
                                <ul class="breadcrumb">
                                    <li>
                                        <a>
                                            
                                            <xsl:if test="$translation[eft:toh]">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/eft:toh[1]/@key, '.html')"/>
                                                <xsl:attribute name="target" select="$translation/@id"/>
                                            </xsl:if>
                                            
                                            <xsl:value-of select="common:limit-str($translation/eft:titles/eft:title[@xml:lang eq 'en'][1], 80)"/>
                                            
                                            <span class="small nowrap">
                                                <xsl:value-of select="' / '"/>
                                                <xsl:value-of select="$translation/eft:toh[1]/eft:full/data()"/>
                                            </span>
                                            
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', $translation/eft:toh[1]/@key, '.html')"/>
                                            <xsl:attribute name="target" select="'check-folios'"/>
                                            <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, '/source/', $translation/eft:toh[1]/@key, '.html?page=1')"/>
                                            <xsl:attribute name="data-dualview-title" select="'Folio view'"/>
                                            <xsl:value-of select="'Folio view'"/>
                                        </a>
                                    </li>
                                    <li>
                                        <xsl:sequence select="ops:translation-status($translation/@status-group)"/>
                                    </li>
                                </ul>
                            </nav>
                        </div>
                        
                        <!-- Pagination -->
                        <xsl:if test="$tmx">
                            <div>
                                <nav aria-label="Page navigation" class="pagination-nav pull-right">
                                    <ul class="pagination pagination-sm">
                                        
                                        <li class="disabled">
                                            <span>
                                                <xsl:value-of select="'Folio:'"/>
                                            </span>
                                        </li>
                                        
                                        <xsl:variable name="folio-limiter" select="5"/>
                                        <xsl:for-each select="$folio-indexes">
                                            <xsl:variable name="folio-index" select="."/>
                                            <xsl:choose>
                                                <xsl:when test="$folio-index eq $folio-index-requested">
                                                    
                                                    <li class="active">
                                                        <span>
                                                            <xsl:value-of select="$folio-index"/>
                                                        </span>
                                                    </li>
                                                    
                                                </xsl:when>
                                                <xsl:when test="$folio-index = (min($folio-indexes), max($folio-indexes)) or ($folio-index gt $folio-index-requested and $folio-index le $folio-index-requested + $folio-limiter) or ($folio-index lt $folio-index-requested and $folio-index ge $folio-index-requested - $folio-limiter)">
                                                    
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat('/source-utils.html?text-id=', $request/@text-id,'&amp;folio-index=', $folio-index)"/>
                                                            <!--<xsl:attribute name="data-ajax-target" select="'#source-content'"/>-->
                                                            <xsl:attribute name="title" select="'Go to page ' || $folio-index"/>
                                                            <xsl:attribute name="target" select="'_self'"/>
                                                            <xsl:attribute name="data-loading" select="'Loading page...'"/>
                                                            <xsl:value-of select="$folio-index"/>
                                                        </a>
                                                    </li>
                                                    
                                                </xsl:when>
                                                <xsl:when test="($folio-index gt $folio-index-requested and $folio-index eq $folio-index-requested + ($folio-limiter + 1)) or ($folio-index lt $folio-index-requested and $folio-index eq $folio-index-requested - ($folio-limiter + 1))">
                                                    
                                                    <li class="disabled">
                                                        <span>
                                                            <xsl:value-of select="'...'"/>
                                                        </span>
                                                    </li>
                                                    
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:for-each>
                                        
                                    </ul>
                                </nav>
                            
                            </div>
                        </xsl:if>
                        
                    </header>
                    
                    <div id="source-utils" class="row">
                        
                        <!-- List segments -->
                        <div class="col-sm-7">
                            
                            <hr class="sml-margin no-top-margin"/>
                            
                            <xsl:choose>
                                <xsl:when test="$tmx">
                                    
                                    <form action="/source-utils.html" method="post" data-ajax-target="#source-utils" id="segments" class="filter-form" data-loading="Loading...">
                                        
                                        <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                        <input type="hidden" name="folio-index" value="{ $request/@folio-index }"/>
                                        
                                        <!-- Segments -->
                                        <div class="source tei-parser">
                                            <xsl:for-each select="$tmx//tmx:tu[tmx:tuv[@xml:lang eq 'bo']]">
                                                <xsl:if test="tmx:prop[@name eq 'eft:folio-index-in-text']/text() ! xs:integer(.) eq $folio-index-requested or following-sibling::tmx:tu[1][tmx:prop[@name eq 'eft:folio-index-in-text']/text() ! xs:integer(.) eq $folio-index-requested]">
                                                    
                                                    <xsl:variable name="unit-id" select="@id"/>
                                                    
                                                    <div class="top-vertical">
                                                        
                                                        <div>
                                                            <input type="checkbox" name="segment-id[]" value="{ @id }" id="{ 'segment-' || @id }" data-onchange-pulse="#submitSegmentsStandoff">
                                                                <xsl:if test="$request/eft:segment[@id eq $unit-id]">
                                                                    <xsl:attribute name="checked" select="'checked'"/>
                                                                </xsl:if>
                                                            </input>
                                                        </div>
                                                        
                                                        <div>
                                                            
                                                            <p class="text-bo" for="{ 'segment-' || @id }">
                                                                
                                                                <xsl:if test="$request/eft:segment[@id eq $unit-id]">
                                                                    <xsl:attribute name="class" select="'text-bo text-danger'"/>
                                                                </xsl:if>
                                                                
                                                                <xsl:variable name="regex" select="'\{{2}(folio:)?([^\{\}]+)\}{2}'"/>
                                                                <xsl:analyze-string select="string-join(tmx:tuv[@xml:lang eq 'bo']/tmx:seg)" regex="{ $regex }" flags="i">
                                                                    
                                                                    <xsl:matching-substring>
                                                                        <span class="label label-default text-en">
                                                                            <xsl:value-of select="regex-group(2)"/>
                                                                        </span>
                                                                        <xsl:value-of select="' '"/>
                                                                    </xsl:matching-substring>
                                                                    
                                                                    <xsl:non-matching-substring>
                                                                        <xsl:call-template name="glossarize-source">
                                                                            <xsl:with-param name="text" select="."/>
                                                                        </xsl:call-template>
                                                                    </xsl:non-matching-substring>
                                                                    
                                                                </xsl:analyze-string>
                                                                
                                                            </p>
                                                            
                                                            <p class="sml-margin top text-warning">
                                                                <xsl:call-template name="glossarize-translation">
                                                                    <xsl:with-param name="text" select="string-join(tmx:tuv[@xml:lang eq 'en']/tmx:seg)"/>
                                                                </xsl:call-template>
                                                            </p>
                                                            
                                                        </div>
                                                        
                                                    </div>
                                                    
                                                    <hr class="sml-margin"/>
                                                    
                                                </xsl:if>
                                            </xsl:for-each>
                                        </div>
                                        
                                        <button class="btn btn-primary pull-right hidden" type="submit" id="submitSegments" data-loading="Reloading..." title="Apply selection">
                                            <xsl:value-of select="'Submit'"/>
                                        </button>
                                        
                                    </form>
                                    
                                </xsl:when>
                                <xsl:otherwise>
                                    
                                    <h3>
                                        <xsl:value-of select="'Source file not prepared for annotation'"/>
                                    </h3>
                                    
                                    <p>
                                        <xsl:value-of select="'Please contact the tech team to set up a new project for this text.'"/>
                                        <br/>
                                        <a target="translation-tech-helpdesk" href="https://84000-translate.slack.com/channels/translation-tech-helpdesk">
                                            <xsl:value-of select="'Send a message to the technology team on Slack'"/>
                                        </a>
                                    </p>
                                    
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </div>
                        
                        <!-- Utilities -->
                        <div class="col-sm-5 affix-container">
                            
                            <div data-spy="affix" data-offset-top="60">
                                
                                <div id="accordion" class="list-group accordion accordion-bordered accordion-background affix-scroll">
                                    
                                    <!-- Summary / reload -->
                                    <div class="list-group-item">
                                        <div class="center-vertical full-width">
                                            <div>
                                                <span class="badge badge-notification badge-muted">
                                                    <xsl:if test="count($units-selected) gt 0">
                                                        <xsl:attribute name="class" select="'badge badge-notification'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="count($units-selected)"/>
                                                </span>
                                                <span class="badge-text">
                                                    <xsl:choose>
                                                        <xsl:when test="count($units-selected) eq 1">
                                                            <xsl:value-of select="'segment selected'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'segments selected'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Resources -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'resources'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'resources']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading">
                                                        <xsl:value-of select="'Online resources' "/>
                                                    </h3>
                                                </div>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            <ul class="sml-margin top">
                                                
                                                <!-- Google Drive link -->
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="target" select="'84000-google-drive'"/>
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/source/', $request/@text-id, '.resources')"/>
                                                        <xsl:attribute name="class" select="'link-branded brand-gdrive'"/>
                                                        <xsl:value-of select="$translation/eft:toh[1]/eft:full/data() || ' on 84000 Google Drive'"/>
                                                    </a>
                                                </li>
                                                
                                                <!-- BDRC link -->
                                                <xsl:variable name="link-bdrc-work" select="$rdf/bdo:Work[@rdf:about/string() eq $translation/eft:toh/eft:ref[@type eq 'bdrc-tibetan-id']/@value/string()]"/>
                                                <xsl:if test="$link-bdrc-work">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="target" select="'bdrc'"/>
                                                            <xsl:attribute name="href" select="$link-bdrc-work/@rdf:about"/>
                                                            <xsl:attribute name="class" select="'link-branded brand-bdrc'"/>
                                                            <xsl:value-of select="$translation/eft:toh[1]/eft:full/data() || ' on BDRC'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                                <!-- rKTs link -->
                                                <xsl:variable name="link-rkts" select="$link-bdrc-work/owl:sameAs[@rdf:resource ! matches(., '^http://purl\.rkts\.eu/resource')][1]/@rdf:resource"/>
                                                <xsl:if test="$link-rkts">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="target" select="'rkts'"/>
                                                            <xsl:attribute name="href" select="$link-rkts"/>
                                                            <xsl:attribute name="class" select="'link-branded brand-rkts'"/>
                                                            <xsl:value-of select="$translation/eft:toh[1]/eft:full/data() || ' on rKTs'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                                <!-- Buddhanexus link -->
                                                <xsl:variable name="link-buddhanexus" select="$link-bdrc-work/owl:sameAs[@rdf:resource ! matches(., '^https://buddhanexus\.net/')][1]/@rdf:resource"/>
                                                <xsl:if test="$link-buddhanexus">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="target" select="'buddhanexus'"/>
                                                            <xsl:attribute name="href" select="$link-buddhanexus"/>
                                                            <xsl:attribute name="class" select="'link-branded brand-buddhanexus'"/>
                                                            <xsl:value-of select="$translation/eft:toh[1]/eft:full/data() || ' on Buddhanexus'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="target" select="'steinert'"/>
                                                        <xsl:attribute name="href" select="'https://dictionary.christian-steinert.de'"/>
                                                        <xsl:value-of select="'Christian Steinert Dictionary'"/>
                                                    </a>
                                                </li>
                                                
                                            </ul>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Glossary -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'glossary'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'glossary']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading">
                                                        <xsl:if test="not($glossary-prioritised)">
                                                            <xsl:attribute name="class" select="'list-group-item-heading text-muted'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Glossary' "/>
                                                    </h3>
                                                </div>
                                                <xsl:if test="$glossary-prioritised">
                                                    <div>
                                                        <span class="badge badge-notification">
                                                            <xsl:if test="count($glossary-prioritised) lt 1">
                                                                <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="format-number(count($glossary-prioritised),'#,###')"/>
                                                        </span>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <xsl:for-each select="$glossary-prioritised">
                                                
                                                <xsl:sort select="key('glossary-pre-processed', @xml:id, $root)[1]/@index ! common:enforce-integer(.)"/>
                                                
                                                <hr class="sml-margin"/>
                                                
                                                <div id="{ @xml:id }" class="glossary-item">
                                                    <xsl:call-template name="glossary-item">
                                                        <xsl:with-param name="glossary-item" select="."/>
                                                    </xsl:call-template>
                                                </div>
                                                
                                            </xsl:for-each>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Glossary builder -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'glossary-builder'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'glossary-builder']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:if test="count($units-selected) eq 1">
                                                            <xsl:attribute name="class" select="'list-group-item-heading'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Add to glossary'"/>
                                                    </h3>
                                                </div>
                                                <xsl:if test="$request[@util eq 'glossary-builder'] and count($units-selected) eq 1">
                                                    <div>
                                                        <span class="badge badge-notification">
                                                            <xsl:if test="count($entities-suggested) lt 1">
                                                                <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="format-number(count($entities-suggested), '#,###')"/>
                                                        </span>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <div id="glossary-builder-ajax-content">
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$request[@util eq 'glossary-builder']">
                                                        <xsl:choose>
                                                            <xsl:when test="$entities-suggested">
                                                                
                                                                <form action="/source-utils.html" method="post" class="form-horizontal labels-left" data-loading="Loading...">
                                                                    
                                                                    <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                                                    <input type="hidden" name="folio-index" value="{ $folio-index-requested }"/>
                                                                    <xsl:for-each select="$request/eft:segment[@id]">
                                                                        <input type="hidden" name="segment-id[]" value="{ @id }"/>
                                                                    </xsl:for-each>
                                                                    <input type="hidden" name="form-action" value="glossary-add-items"/>
                                                                    
                                                                    <!-- Type checkboxes -->
                                                                    <!--
                                                                    <div class="center-vertical-sm align-center bottom-margin">
                                                                        <div class="form-group">
                                                                            <xsl:for-each select="eft:request/eft:entity-types/eft:type[@glossary-type]">
                                                                                
                                                                                <div class="checkbox-inline">
                                                                                    <label>
                                                                                        <input type="checkbox" name="term-type[]">
                                                                                            <xsl:attribute name="value" select="@id"/>
                                                                                            <xsl:if test="@selected eq 'selected'">
                                                                                                <xsl:attribute name="checked" select="'checked'"/>
                                                                                            </xsl:if>
                                                                                        </input>
                                                                                        <xsl:value-of select="' ' || eft:label[@type eq 'plural']"/>
                                                                                    </label>
                                                                                </div>
                                                                                
                                                                            </xsl:for-each>
                                                                        </div>
                                                                    </div>-->
                                                                    
                                                                    <!-- New glossary entry form -->
                                                                    <div class="center-vertical full-width sml-margin top">
                                                                        <div>
                                                                            <xsl:value-of select="'Select terms found'"/>
                                                                        </div>
                                                                        <div class="text-right">
                                                                            <a class="underline">
                                                                                <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $translation/@id,  '&amp;resource-type=translation&amp;filter=blank-form#glossary-entry-new')"/>
                                                                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                                                                <xsl:attribute name="data-editor-callbackurl" select="concat($operations-path, '/source-utils.html?', string-join($page-attributes, '&amp;'))"/>
                                                                                <xsl:attribute name="data-ajax-loading" select="'Loading glossary editor...'"/>
                                                                                <xsl:value-of select="'enter a new term'"/>
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                                    
                                                                    <!-- Glossary scan results -->
                                                                    <xsl:call-template name="glossary-suggestions"/>
                                                                    
                                                                </form>
                                                                
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                
                                                                <hr class="sml-margin"/>
                                                                <p class="text-muted italic">
                                                                    <xsl:value-of select="'No suggestions'"/>
                                                                </p>
                                                                
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:when>
                                                    <xsl:when test="count($units-selected) eq 1">
                                                        
                                                        <div class="top-margin loading" data-in-view-replace="{ concat('/source-utils.html?', string-join(($page-attributes, 'util=glossary-builder'), '&amp;'), '#glossary-builder-ajax-content') }"/>
                                                        
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        
                                                        <hr class="sml-margin"/>
                                                        <p class="text-muted italic">
                                                            <xsl:value-of select="'Select a segment'"/>
                                                        </p>
                                                        
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                            </div>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- TM search -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'tm-search'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'tm-search']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:if test="count($units-selected) gt 0">
                                                            <xsl:attribute name="class" select="'list-group-item-heading'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Translation memory'"/>
                                                    </h3>
                                                </div>
                                                <xsl:if test="$request[@util eq 'tm-search'] and count($units-selected) gt 0">
                                                    <div>
                                                        <span class="badge badge-notification">
                                                            <xsl:if test="count(eft:tm-search/eft:results/eft:item) lt 1">
                                                                <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="format-number(count(eft:tm-search/eft:results/eft:item), '#,###')"/>
                                                        </span>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <div id="tm-search-ajax-content">
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$request[@util eq 'tm-search']">
                                                        <xsl:choose>
                                                            <xsl:when test="eft:tm-search/eft:results[eft:item]">
                                                                
                                                                <div id="search-container" class="sml-margin top">
                                                                    <xsl:call-template name="tm-search-results">
                                                                        <xsl:with-param name="results" select="eft:tm-search/eft:results"/>
                                                                    </xsl:call-template>
                                                                </div>
                                                                
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                
                                                                <hr class="sml-margin"/>
                                                                <p class="text-muted italic">
                                                                    <xsl:value-of select="'No results'"/>
                                                                </p>
                                                                
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:when>
                                                    <xsl:when test="count($units-selected) gt 0"> 
                                                        
                                                        <div class="loading" data-in-view-replace="{ concat('/source-utils.html?', string-join(($page-attributes, 'util=tm-search'), '&amp;'), '#tm-search-ajax-content') }"/>
                                                        
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        
                                                        <hr class="sml-margin"/>
                                                        <p class="text-muted italic">
                                                            <xsl:value-of select="'Select a segment'"/>
                                                        </p>
                                                        
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                
                                            </div>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Machine translation -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'machine-translation'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'machine-translation']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading">
                                                        <xsl:if test="count($units-selected) eq 0">
                                                            <xsl:attribute name="class" select="'list-group-item-heading text-muted'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Machine translation'"/>
                                                    </h3>
                                                </div>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <div id="machine-translation-ajax-content">
                                                
                                                <xsl:choose>
                                                    <xsl:when test="$request[@util eq 'machine-translation']">
                                                        
                                                        <hr class="sml-margin"/>
                                                        
                                                        <p>
                                                            <xsl:choose>
                                                                <xsl:when test="eft:machine-translation/eft:response-sentence[text()]">
                                                                    <xsl:value-of select="eft:machine-translation/eft:response-sentence"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:attribute name="class" select="'text-muted italic'"/>
                                                                    <xsl:value-of select="'[No translation returned]'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </p>
                                                
                                                        <xsl:if test="eft:machine-translation">
                                                            
                                                            <hr class="sml-margin"/>
                                                            
                                                            <p class="text-muted italic">
                                                                <xsl:choose>
                                                                    <xsl:when test="eft:machine-translation[eft:trailer/text()]">
                                                                        <xsl:value-of select="eft:machine-translation/eft:trailer"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <small>
                                                                            <i>
                                                                                <xsl:value-of select="'This translation is generated by the MITRA model, being developed at the Berkeley AI Research Lab.'"/>
                                                                            </i>
                                                                        </small>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </p>
                                                            
                                                        </xsl:if>
                                                
                                                    </xsl:when>
                                                    <xsl:when test="count($units-selected) gt 0">
                                                        
                                                        <div class="top-margin loading" data-in-view-replace="{ concat('/source-utils.html?', string-join(($page-attributes, 'util=machine-translation'), '&amp;'), '#machine-translation-ajax-content') }"/>
                                                        
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        
                                                        <hr class="sml-margin"/>
                                                        <p class="text-muted italic">
                                                            <xsl:value-of select="'Select a segment'"/>
                                                        </p>
                                                        
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Translate -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'translate'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'translate']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:if test="count($units-selected) eq 1">
                                                            <xsl:attribute name="class" select="'list-group-item-heading'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Translate'"/>
                                                    </h3>
                                                </div>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <xsl:choose>
                                                <xsl:when test="count($units-selected) eq 1">
                                                    
                                                    <form action="/source-utils.html" method="post" class="" data-loading="Loading...">
                                                        
                                                        <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                                        <input type="hidden" name="folio-index" value="{ $folio-index-requested }"/>
                                                        <xsl:for-each select="$request/eft:segment[@id]">
                                                            <input type="hidden" name="segment-id[]" value="{ @id }"/>
                                                        </xsl:for-each>
                                                        
                                                        <input type="hidden" name="form-action" value="translate"/>
                                                        
                                                        <div class="form-group sml-margin top">
                                                            
                                                            <label for="translation">
                                                                <xsl:choose>
                                                                    <xsl:when test="$units-selected/tmx:tuv[@xml:lang eq 'en']/tmx:seg">
                                                                        <xsl:value-of select="'Revise the translation'"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="'Add a translation'"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </label>
                                                            
                                                            <textarea name="translation" id="translation" class="form-control">
                                                                <xsl:attribute name="rows" select="common:textarea-rows($units-selected/tmx:tuv[@xml:lang eq 'en']/tmx:seg, 5, 60)"/>
                                                                <xsl:value-of select="$units-selected/tmx:tuv[@xml:lang eq 'en']/tmx:seg"/>
                                                            </textarea>
                                                            
                                                        </div>
                                                        
                                                        <div class="form-group">
                                                            <button type="submit" class="btn btn-primary pull-right">
                                                                <xsl:value-of select="'Apply'"/>
                                                            </button>
                                                        </div>
                                                        
                                                    </form>
                                                    
                                                </xsl:when>
                                                <xsl:when test="count($units-selected) gt 1">
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Too many segments selected. Only single segment can be translated.'"/>
                                                    </p>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Select a segment'"/>
                                                    </p>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Split segment -->
                                    <!-- Still problematic and unlikely to be necessary. Disable for now
                                    <xsl:if test="$request[@util eq 'source-split'] and count($request/eft:segment) eq 1">
                                        <xsl:call-template name="expand-item">
                                            <xsl:with-param name="id" select="'source-split'"/>
                                            <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                            <xsl:with-param name="active" select="if($request[@util eq 'source-split']) then true() else false()"/>
                                            <xsl:with-param name="title-opener" select="true()"/>
                                            <xsl:with-param name="persist" select="false()"/>
                                            <xsl:with-param name="title">
                                                <div class="center-vertical align-left">
                                                    <div>
                                                        <h3 class="list-group-item-heading">
                                                            <xsl:value-of select="'Split segment'"/>
                                                        </h3>
                                                    </div>
                                                </div>
                                            </xsl:with-param>
                                            <xsl:with-param name="content">
                                                
                                                <!-\- Form to adjust and re-load -\->
                                                <form action="/source-utils.html" method="post" class="" data-loading="Loading...">
                                                    
                                                    <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                                    <input type="hidden" name="folio-index" value="{ $folio-index-requested }"/>
                                                    <xsl:for-each select="$request/eft:segment[@id]">
                                                        <input type="hidden" name="segment-id[]" value="{ @id }"/>
                                                    </xsl:for-each>
                                                    
                                                    <input type="hidden" name="form-action" value="source-split"/>
                                                    
                                                    <div class="form-group sml-margin top">
                                                        
                                                        <label for="source-split">
                                                            <xsl:value-of select="'Add a return character to the location where the segment should be split'"/>
                                                        </label>
                                                        
                                                        <textarea name="source-split" id="source-split" class="form-control text-bo">
                                                            <xsl:attribute name="rows" select="common:textarea-rows($segments-raw, 3, 60)"/>
                                                            <xsl:value-of select="$segments-raw"/>
                                                        </textarea>
                                                        
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <button type="submit" class="btn btn-primary pull-right">
                                                            <xsl:value-of select="'Apply'"/>
                                                        </button>
                                                    </div>
                                                    
                                                </form>
                                                
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:if>-->
                                    
                                    <!-- Join segments -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'source-join'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'source-join']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:if test="count($units-selected) gt 1">
                                                            <xsl:attribute name="class" select="'list-group-item-heading'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Join segments'"/>
                                                    </h3>
                                                </div>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <xsl:choose>
                                                <xsl:when test="count($units-selected) gt 1">
                                                    
                                                    <form action="/source-utils.html" method="post" class="" data-loading="Loading...">
                                                        
                                                        
                                                        <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                                        <input type="hidden" name="folio-index" value="{ $folio-index-requested }"/>
                                                        <xsl:for-each select="$request/eft:segment[@id]">
                                                            <input type="hidden" name="segment-id[]" value="{ @id }"/>
                                                        </xsl:for-each>
                                                        
                                                        <input type="hidden" name="form-action" value="source-join"/>
                                                        
                                                        <div class="form-group sml-margin top">
                                                            
                                                            <label for="source-joined">
                                                                <xsl:value-of select="'The selected segments will be joined'"/>
                                                            </label>
                                                            
                                                            <textarea name="source-joined" id="source-joined" class="form-control text-bo" disabled="disabled">
                                                                <xsl:attribute name="rows" select="common:textarea-rows($segments-joined, 3, 60)"/>
                                                                <xsl:value-of select="$segments-joined"/>
                                                            </textarea>
                                                            
                                                        </div>
                                                        
                                                        <div class="form-group">
                                                            <button type="submit" class="btn btn-primary pull-right">
                                                                <xsl:value-of select="'Apply'"/>
                                                            </button>
                                                        </div>
                                                        
                                                    </form>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Select more than one segment'"/>
                                                    </p>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Review folios -->
                                    <xsl:variable name="etext-note" select="eft:translation-status/eft:text/eft:etext-note[@segment-id eq $request/eft:segment/@id]" as="element(eft:etext-note)?"/>
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'review-folios'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'review-folios']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:if test="count($units-selected) eq 1">
                                                            <xsl:attribute name="class" select="'list-group-item-heading'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Etext issues'"/>
                                                    </h3>
                                                </div>
                                                <xsl:if test="$request[@util eq 'review-folios'] and count($units-selected) eq 1">
                                                    <div>
                                                        <span class="badge badge-notification">
                                                            <xsl:if test="count($etext-note) eq 0">
                                                                <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="count($etext-note)"/>
                                                        </span>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <xsl:choose>
                                                <xsl:when test="count($units-selected) eq 1">
                                                    
                                                    <!-- Note -->
                                                    <form action="/source-utils.html" method="post" class="sml-margin top" data-loading="Loading...">
                                                        
                                                        <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                                        <input type="hidden" name="folio-index" value="{ $folio-index-requested }"/>
                                                        <xsl:for-each select="$request/eft:segment[@id]">
                                                            <input type="hidden" name="segment-id[]" value="{ @id }"/>
                                                        </xsl:for-each>
                                                        
                                                        <input type="hidden" name="form-action" value="etext-note"/>
                                                        
                                                        <div class="form-group">
                                                            
                                                            <label for="etext-note">
                                                                <xsl:value-of select="'Note about this segment:'"/>
                                                            </label>
                                                            
                                                            <xsl:variable name="etext-note-text" as="text()?">
                                                                <xsl:value-of select="normalize-space(string-join($etext-note, ' '))"/>
                                                            </xsl:variable>
                                                            <textarea name="etext-note" id="etext-note" class="form-control">
                                                                <xsl:attribute name="rows" select="common:textarea-rows($etext-note-text, 5, 60)"/>
                                                                <xsl:value-of select="$etext-note-text"/>
                                                            </textarea>
                                                            
                                                            <xsl:if test="$etext-note[@last-edited]">
                                                                <div class="small text-muted sml-margin top">
                                                                    <xsl:value-of select="common:date-user-string('Last updated', $etext-note/@last-edited, $etext-note/@last-edited-by)"/>
                                                                </div>
                                                            </xsl:if>
                                                            
                                                        </div>
                                                        
                                                        <div class="form-group text-right">
                                                            <button type="submit" class="btn btn-primary">
                                                                <xsl:value-of select="'Submit'"/>
                                                            </button>
                                                        </div>
                                                    </form>
                                                    
                                                    <hr class="sml-margin"/>
                                                    
                                                    <!-- Scans -->
                                                    <div>
                                                        
                                                        <label>
                                                            <xsl:value-of select="'Standard reference scans:'"/>
                                                        </label>
                                                        
                                                        <xsl:variable name="volume" select="$units-selected[1]/tmx:prop[@name eq 'eft:folio-volume']/text() ! xs:integer(.)"/>
                                                        <xsl:variable name="folio-etext-key" select="$units-selected[1]/tmx:prop[@name eq 'eft:folio-etext-key']/text()"/>
                                                        
                                                        <ul>
                                                            
                                                            <!-- W4CZ5369 -->
                                                            <li>
                                                                
                                                                <a>
                                                                    <xsl:attribute name="href" select="'#scan-W4CZ5369'"/>
                                                                    <xsl:attribute name="class" select="'pop-up'"/>
                                                                    <xsl:value-of select="'Degé W4CZ5369 (from Library of Congress)'"/>
                                                                    <br/>
                                                                    <small class="text-muted">
                                                                        <xsl:value-of select="'late post par phud'"/>
                                                                    </small>
                                                                </a>
                                                                
                                                                <div class="hidden">
                                                                    <div id="scan-W4CZ5369">
                                                                        <h3>
                                                                            <xsl:value-of select="'Degé W4CZ5369 (from Library of Congress) '"/>
                                                                            <small class="text-muted">
                                                                                <xsl:value-of select="'late post par phud'"/>
                                                                            </small>
                                                                        </h3>
                                                                        <p class="text-muted italic">
                                                                            <xsl:value-of select="'This text is the basis for the eKangyur. (This image will occasionally be off-alignment, so you may need to adjust a page or two.)'"/>
                                                                        </p>
                                                                        <div>
                                                                            <img class="img-responsive" src="{ eft:scan-src( $volume, $folio-etext-key, 'W4CZ5369' ) }"/>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                
                                                            </li>
                                                            
                                                            <!-- W30532 -->
                                                            <li>
                                                                
                                                                <a>
                                                                    <xsl:attribute name="href" select="'#scan-W30532'"/>
                                                                    <xsl:attribute name="class" select="'pop-up'"/>
                                                                    <xsl:value-of select="'Degé W30532 (printed from the library of Situ Rinpoche)'"/>
                                                                    <br/>
                                                                    <small class="text-muted">
                                                                        <xsl:value-of select="'late post par phud'"/>
                                                                    </small>
                                                                </a>
                                                                
                                                                <div class="hidden">
                                                                    <div id="scan-W30532">
                                                                        <h3>
                                                                            <xsl:value-of select="'Degé W30532 (printed from the library of Situ Rinpoche) '"/>
                                                                            <small class="text-muted">
                                                                                <xsl:value-of select="'late post par phud'"/>
                                                                            </small>
                                                                        </h3>
                                                                        <div>
                                                                            <img class="img-responsive" src="{ eft:scan-src( $volume, $folio-etext-key, 'W30532' ) }"/>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                
                                                            </li>
                                                            
                                                            <!-- adarsha -->
                                                            <li>
                                                                
                                                                <a>
                                                                    <xsl:attribute name="href" select="'#scan-adarsha'"/>
                                                                    <xsl:attribute name="class" select="'pop-up'"/>
                                                                    <xsl:value-of select="'Degé (adarsha.dharma-treasure.org)'"/>
                                                                    <br/>
                                                                    <small class="text-muted">
                                                                        <xsl:value-of select="'seems to be post par phud'"/>
                                                                    </small>
                                                                </a>
                                                                
                                                                <div class="hidden">
                                                                    <div id="scan-adarsha">
                                                                        <h3>
                                                                            <xsl:value-of select="'Degé (adarsha.dharma-treasure.org) '"/>
                                                                            <small class="text-muted">
                                                                                <xsl:value-of select="'seems to be post par phud'"/>
                                                                            </small>
                                                                        </h3>
                                                                        <p class="text-muted italic">
                                                                            <xsl:value-of select="'Note, volumes 100-102 have been reordered to align with the other scans.'"/>
                                                                        </p>
                                                                        <div>
                                                                            <img class="img-responsive" src="{ eft:scan-src( $volume, $folio-etext-key, 'adarsha' ) }"/>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                
                                                            </li>
                                                            
                                                            <!-- W3CN20612 -->
                                                            <li>
                                                                
                                                                <a>
                                                                    <xsl:attribute name="href" select="'#scan-W3CN20612'"/>
                                                                    <xsl:attribute name="class" select="'pop-up'"/>
                                                                    <xsl:value-of select="'Degé W3CN20612 (Tsalparma)'"/>
                                                                    <br/>
                                                                    <small class="text-muted">
                                                                        <xsl:value-of select="'early post par-phud (1762?)'"/>
                                                                    </small>
                                                                </a>
                                                                
                                                                <div class="hidden">
                                                                    <div id="scan-W3CN20612">
                                                                        <h3>
                                                                            <xsl:value-of select="'Degé W3CN20612 (Tsalparma) '"/>
                                                                            <small class="text-muted">
                                                                                <xsl:value-of select="'early post par-phud (1762?)'"/>
                                                                            </small>
                                                                        </h3>
                                                                        <p class="text-muted italic">
                                                                            <xsl:value-of select="'Note that the original volume order in W3CN20612 does not follow the order of the other editions. This script has reordered this volume to match the others. This early version doesn''t have the extra texts in Vol. 81, 83, and 88 that were added to the late post par phud editions.'"/>
                                                                        </p>
                                                                        <div>
                                                                            <img class="img-responsive" src="{ eft:scan-src( $volume, $folio-etext-key, 'W3CN20612' ) }"/>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                
                                                            </li>
                                                            
                                                            <!-- W22084 -->
                                                            <li>
                                                                
                                                                <a>
                                                                    <xsl:attribute name="href" select="'#scan-W22084'"/>
                                                                    <xsl:attribute name="class" select="'pop-up'"/>
                                                                    <xsl:value-of select="'Degé W22084 (printed by 16th Karmapa)'"/>
                                                                    <br/>
                                                                    <small class="text-muted">
                                                                        <xsl:value-of select="'facsimile par phud (1733)'"/>
                                                                    </small>
                                                                </a>
                                                                
                                                                <div class="hidden">
                                                                    <div id="scan-W22084">
                                                                        
                                                                        <h3>
                                                                            <xsl:value-of select="'Degé W22084 (printed by 16th Karmapa) '"/>
                                                                            <small class="text-muted">
                                                                                <xsl:value-of select="'facsimile par phud (1733)'"/>
                                                                            </small>
                                                                        </h3>
                                                                        <p class="text-muted italic">
                                                                            <xsl:value-of select="'par phud recension is NOT the basis for eKangyur but it may be helpful for comparison. It also isn’t used as a main source because it was retouched with marker pens before printing in Delhi.'"/>
                                                                        </p>
                                                                        <div>
                                                                            <img class="img-responsive" src="{eft:scan-src( $volume, $folio-etext-key, 'W22084' ) }"/>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                
                                                            </li>
                                                            
                                                        </ul>
                                                        
                                                    </div>
                                                
                                                </xsl:when>
                                                
                                                <xsl:when test="count($units-selected) gt 1">
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Too many segments selected. Only single segments can be annotated.'"/>
                                                    </p>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Select a segment'"/>
                                                    </p>
                                                    
                                                </xsl:otherwise>
                                                
                                            </xsl:choose>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Source Annotation -->
                                    <xsl:variable name="source-notes" select="eft:translation-status/eft:text/eft:source-note[@segment-id eq $request/eft:segment/@id]" as="element(eft:source-note)*"/>
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'annotate-source'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'annotate-source']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:if test="count($units-selected) eq 1">
                                                            <xsl:attribute name="class" select="'list-group-item-heading'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="'Annotations'"/>
                                                    </h3>
                                                </div>
                                                <xsl:if test="$request[@util eq 'annotate-source'] and count($units-selected) eq 1">
                                                    <div>
                                                        <span class="badge badge-notification">
                                                            <xsl:if test="count($source-notes) eq 0">
                                                                <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="count($source-notes)"/>
                                                        </span>
                                                    </div>
                                                </xsl:if>
                                            </div>
                                            
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <xsl:choose>
                                                <xsl:when test="count($units-selected) eq 1">
                                                    
                                                    <div class="sml-margin top">
                                                        <xsl:for-each select="$source-notes">
                                                            
                                                            <xsl:sort select="@last-updated"/>
                                                            
                                                            <blockquote>
                                                                <p>
                                                                    <xsl:value-of select="normalize-space(text())"/>
                                                                </p>
                                                                <footer>
                                                                    <xsl:value-of select="common:date-user-string('Comment', @last-edited, @last-edited-by)"/>
                                                                </footer>
                                                            </blockquote>
                                                            
                                                        </xsl:for-each>
                                                    </div>
                                                    
                                                    <form action="/source-utils.html" method="post" class="sml-margin top" data-loading="Loading...">
                                                        
                                                        <input type="hidden" name="text-id" value="{ $request/@text-id }"/>
                                                        <input type="hidden" name="folio-index" value="{ $folio-index-requested }"/>
                                                        <xsl:for-each select="$request/eft:segment[@id]">
                                                            <input type="hidden" name="segment-id[]" value="{ @id }"/>
                                                        </xsl:for-each>
                                                        
                                                        <input type="hidden" name="form-action" value="source-note"/>
                                                        
                                                        <div class="form-group">
                                                            <label for="source-note">
                                                                <xsl:value-of select="'Add a note'"/>
                                                            </label>
                                                            <textarea name="source-note" id="source-note" class="form-control" rows="4"/>
                                                        </div>
                                                        
                                                        <div class="form-group text-right">
                                                            <button type="submit" class="btn btn-primary">
                                                                <xsl:value-of select="'Submit'"/>
                                                            </button>
                                                        </div>
                                                        
                                                    </form>
                                                    
                                                </xsl:when>
                                                <xsl:when test="count($units-selected) gt 1">
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Too many segments selected. Only single segment can be annotated.'"/>
                                                    </p>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <hr class="sml-margin"/>
                                                    <p class="text-muted italic">
                                                        <xsl:value-of select="'Select a segment'"/>
                                                    </p>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Bibliography -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'bibliography'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'bibliography']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading text-muted">
                                                        <xsl:value-of select="'Bibliography' "/>
                                                    </h3>
                                                </div>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <hr class="sml-margin"/>
                                            <p class="text-muted italic">
                                                <xsl:value-of select="'To come...'"/>
                                            </p>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                    <!-- Help and feedback -->
                                    <xsl:call-template name="expand-item">
                                        <xsl:with-param name="id" select="'help'"/>
                                        <xsl:with-param name="accordion-selector" select="'#accordion'"/>
                                        <xsl:with-param name="active" select="if($request[@util eq 'help']) then true() else false()"/>
                                        <xsl:with-param name="title-opener" select="true()"/>
                                        <xsl:with-param name="persist" select="false()"/>
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <div>
                                                    <h3 class="list-group-item-heading">
                                                        <xsl:value-of select="'Help &amp; Feedback' "/>
                                                    </h3>
                                                </div>
                                            </div>
                                        </xsl:with-param>
                                        <xsl:with-param name="content">
                                            
                                            <p class="sml-margin top">
                                                <xsl:value-of select="'To report a problem, get help or to make a suggestion for improvement please contact the tech team via '"/>
                                                <a target="translation-tech-helpdesk" href="https://84000-translate.slack.com/channels/translation-tech-helpdesk">
                                                    <xsl:value-of select="'Slack'"/>
                                                </a>
                                            </p>
                                            
                                        </xsl:with-param>
                                    </xsl:call-template>
                                    
                                </div>
                            
                            </div>
                        
                        </div>
                    
                    </div>
                    
                </xsl:with-param>
                <xsl:with-param name="aside-content">
                    
                    <!-- General pop-up for notes and glossary -->
                    <div id="popup-footer-text" class="fixed-footer collapse hidden-print">
                        <div class="fix-height">
                            <div class="container">
                                <div class="data-container tei-parser">
                                    <!-- Ajax data here -->
                                </div>
                            </div>
                        </div>
                        <div class="fixed-btn-container close-btn-container">
                            <button type="button" class="btn-round close close-collapse" aria-label="Close">
                                <span aria-hidden="true">
                                    <i class="fa fa-times"/>
                                </span>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                    <!-- Pop-up for tei-editor -->
                    <xsl:call-template name="tei-editor-footer"/>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="$translation/eft:toh[1]/eft:full/data(.) || ' | Source Utilities | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 Source Utilities'"/>
            <xsl:with-param name="content">
                
                <xsl:sequence select="$content"/>
                
            </xsl:with-param>

        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossarize-source">
        
        <xsl:param name="text" as="xs:string"/>
        
        <xsl:variable name="text-normalized" as="text()">
            <xsl:value-of select="normalize-space($text)"/>
        </xsl:variable>
        
        <xsl:variable name="match-glossary-items" as="element(tei:gloss)*">
            <xsl:for-each select="$glossary-prioritised">
                
                <xsl:variable name="terms" select="eft:glossary-terms-to-match(., 'bo')"/>
                
                <!-- Do an initial check to avoid too much recursion -->
                <xsl:variable name="match-glossary-item-terms-regex" select="common:matches-regex($terms, 'bo')" as="xs:string"/>
                
                <!-- If it matches then include it in the scan -->
                <xsl:if test="matches($text-normalized, $match-glossary-item-terms-regex, 'i')">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:call-template name="glossary-scan-text">
            <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
            <xsl:with-param name="match-glossary-index" select="1"/>
            <xsl:with-param name="location-id" select="'source'"/>
            <xsl:with-param name="text" select="$text-normalized"/>
            <xsl:with-param name="lang" select="'bo'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossarize-translation">
        
        <xsl:param name="text" as="xs:string"/>
        
        <xsl:variable name="text-normalized" as="text()">
            <xsl:value-of select="normalize-space($text)"/>
        </xsl:variable>
        
        <xsl:variable name="match-glossary-items" as="element(tei:gloss)*">
            <xsl:for-each select="$glossary-prioritised">
                
                <xsl:variable name="terms" select="eft:glossary-terms-to-match(., 'en')"/>
                
                <!-- Do an initial check to avoid too much recursion -->
                <xsl:variable name="match-glossary-item-terms-regex" select="common:matches-regex($terms, 'en')" as="xs:string"/>
                
                <!-- If it matches then include it in the scan -->
                <xsl:if test="matches($text-normalized, $match-glossary-item-terms-regex, 'i')">
                    <xsl:sequence select="."/>
                </xsl:if>
                
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:call-template name="glossary-scan-text">
            <xsl:with-param name="match-glossary-items" select="$match-glossary-items"/>
            <xsl:with-param name="match-glossary-index" select="1"/>
            <xsl:with-param name="location-id" select="'source'"/>
            <xsl:with-param name="text" select="$text-normalized"/>
            <xsl:with-param name="lang" select="'en'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="glossary-suggestions">
        
        <xsl:for-each select="$entities-suggested">
            
            <xsl:variable name="entity" select="."/>
            <xsl:variable name="entity-data" as="element(eft:entity-data)?">
                <xsl:call-template name="entity-data">
                    <xsl:with-param name="entity" select="$entity"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:if test="$entity[@xml:id] and $entity-data[@related-entries ! xs:integer(.) gt 0]">
                
                <xsl:variable name="terms-bo-marked" as="element(eft:term-marked)*">
                    <xsl:for-each select="$entity-data/eft:term[@xml:lang eq 'bo']">
                        <xsl:element name="term-marked" namespace="http://read.84000.co/ns/1.0">
                            <xsl:sequence select="common:mark-string(text(), $entities-regex)"/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:variable>
                
                <xsl:variable name="term-bo-marked" select="($terms-bo-marked[*[matches(@class, '(^|\s)mark(\s|$)')]])[1]" as="element(eft:term-marked)?"/>
                
                <hr class="sml-margin"/>
                
                <table class="table no-border full-width no-bottom-margin">
                    
                    <tr>
                        
                        <!-- Tibetan terms -->
                        <td>
                            <a id="{ $entity/@xml:id }" class="block-link">
                                
                                <xsl:attribute name="href" select="concat($reading-room-path, '/glossary/', $entity/@xml:id, '.html')"/>
                                <xsl:attribute name="target" select="concat($entity/@xml:id, '-html')"/>
                                <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, '/glossary/', $entity/@xml:id, '.html')"/>
                                <xsl:attribute name="data-dualview-title" select="string-join(($term-bo-marked, $terms-bo-marked)[1]/descendant::text())"/>
                                <xsl:attribute name="data-dualview-title-lang" select="'text-bo'"/>
                                
                                <ul class="list-inline inline-dots">
                                    <xsl:for-each select="$terms-bo-marked">
                                        <li>
                                            <span class="h2 text-bo">
                                                <xsl:sequence select="node()"/>
                                            </span>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                                
                            </a>
                        </td>
                        
                        <!-- Types -->
                        <td class="text-right">
                            <xsl:call-template name="entity-types-list">
                                <xsl:with-param name="entity" select="$entity"/>
                                <xsl:with-param name="warnings" select="false()"/>
                            </xsl:call-template>
                        </td>
                        
                    </tr>
                    
                    <tr>
                        
                        <!-- Sanskrit terms -->
                        <td>
                            <xsl:if test="$entity-data/eft:term[@xml:lang eq 'Sa-Ltn']">
                                <ul class="list-inline inline-dots">
                                    <xsl:for-each select="$entity-data/eft:term[@xml:lang eq 'Sa-Ltn']">
                                        <li>
                                            <span class="text-sa">
                                                <xsl:value-of select="text()"/>
                                            </span>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:if>
                        </td>
                        
                        <!-- Option to add -->
                        <td class="text-right">
                            
                            <!--<div class="checkbox">
                                <label>
                                    <input type="checkbox" name="entity-add[]" value="{ $entity/@xml:id }" data-show-on-checked="#entity-input-{ $entity/@xml:id }"/>
                                    <xsl:value-of select="'Add'"/>
                                </label>
                            </div>-->
                            
                            <xsl:variable name="form-id" select="string-join(('glossary-entry-new', $entity/@xml:id),'-')"/>
                            
                            <a class="underline">
                                <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $translation/@id,  '&amp;resource-type=translation&amp;filter=blank-form&amp;entity-id=', $entity/@xml:id, '&amp;default-term-bo=', string-join(($term-bo-marked, $terms-bo-marked)[1]/descendant::text()), '#', $form-id)"/>
                                <xsl:attribute name="data-ajax-target" select="'#popup-footer-editor .data-container'"/>
                                <xsl:attribute name="data-editor-callbackurl" select="concat($operations-path, '/source-utils.html?', string-join($page-attributes, '&amp;'))"/>
                                <xsl:attribute name="data-ajax-loading" select="'Loading glossary editor...'"/>
                                <xsl:value-of select="'Add'"/>
                            </a>
                            
                        </td>
                        
                    </tr>
                    
                    <!-- Translation input 
                    <tr class="collapse" id="entity-input-{ $entity/@xml:id }">
                        <td colspan="2">
                            <div class="form-group">
                                <label for="entity-add-term-{ $entity/@xml:id }" class="col-sm-3 control-label">
                                    <xsl:value-of select="'Translation:'"/>
                                </label>
                                <div class="col-sm-9">
                                    <input type="text" name="entity-add-term-{ $entity/@xml:id }" id="entity-add-term-{ $entity/@xml:id }" class="form-control"/>
                                </div>
                            </div>
                        </td>
                    </tr>-->
                    
                </table>
                
                <!-- Publications count
                <div class="sml-margin top">
                    <span class="nowrap">
                        <span class="badge badge-notification">
                            <xsl:value-of select="$entity-data/@related-entries"/>
                        </span>
                        <span class="badge-text">
                            <xsl:choose>
                                <xsl:when test="$entity-data/@related-entries ! xs:integer(.) eq 1">
                                    <xsl:value-of select="'publication'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'publications'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </span>
                </div>-->
                
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="tm-search-results">
        
        <xsl:param name="results" as="element(eft:results)"/>
        
        <xsl:for-each select="$results/eft:item">
            
            <xsl:sort select="@score ! xs:double(.)" order="descending"/>
            
            <div class="search-result" id="search-result-{ @index }">
                
                <!-- Segments -->
                <div>
                    
                    <ul class="list-unstyled search-match-gloss">
                        <xsl:if test="eft:match/eft:tibetan[node()]">
                            <li>
                                <span class="text-bo">
                                    <xsl:apply-templates select="eft:match/eft:tibetan/node()"/>
                                </span>
                            </li>
                        </xsl:if>
                        <xsl:if test="eft:match/eft:translation[node()]">
                            <li>
                                <span class="translation">
                                    <xsl:apply-templates select="eft:match/eft:translation/node()"/>
                                </span>
                            </li>
                        </xsl:if>
                        <xsl:if test="eft:match/eft:sanskrit[node()]">
                            <li>
                                <span class="text-sa">
                                    <xsl:apply-templates select="eft:match/eft:sanskrit/node()"/>
                                </span>
                            </li>
                        </xsl:if>
                    </ul>
                    
                </div>
                
                <!-- Dualview link -->
                <div>
                    <xsl:choose>
                        <xsl:when test="eft:match/@location gt ''">
                            
                            <a>
                                <xsl:attribute name="href" select="concat($reading-room-path, eft:match/@location)"/>
                                <xsl:attribute name="target" select="concat('translation-', eft:header/@resource-id)"/>
                                <xsl:attribute name="data-dualview-href" select="concat($reading-room-path, eft:match/@location)"/>
                                <xsl:attribute name="data-dualview-title" select="eft:header/eft:bibl[1]/eft:toh/eft:full/text()"/>
                                <xsl:apply-templates select="eft:header/eft:titles/eft:title[@xml:lang eq 'en']"/>
                            </a>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="eft:header/eft:titles/eft:title[@xml:lang eq 'en']"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </div>
                
                <!-- Location in the canon -->
                <xsl:for-each select="eft:header/eft:bibl">
                    
                    <xsl:variable name="bibl" select="."/>
                    
                    <div class="ancestors text-muted small">
                        <xsl:value-of select="'in '"/>
                        <ul class="breadcrumb">
                            
                            <xsl:sequence select="common:breadcrumb-items($bibl/eft:parent/descendant-or-self::eft:parent, /eft:response/@lang)"/>
                            
                            <xsl:if test="$bibl/eft:toh/eft:full">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $bibl/eft:toh/@key, '.html')"/>
                                        <xsl:attribute name="target" select="concat($bibl/@resource-id, '.html')"/>
                                        <xsl:apply-templates select="$bibl/eft:toh/eft:full"/>
                                    </a>
                                </li>
                            </xsl:if>
                            
                        </ul>
                    </div>
                    
                </xsl:for-each>
                
                <!-- Contributors -->
                <xsl:if test="eft:header/eft:publication/eft:contributors/eft:author[@role eq 'translatorEng'][text()]">
                    <div class="translators text-muted small">
                        <span class="nowrap">
                            <xsl:value-of select="'Translated by: '"/> 
                        </span>
                        <ul class="list-inline inline-dots">
                            <xsl:for-each select="eft:header/eft:publication/eft:contributors/eft:author[@role eq 'translatorEng'][text()]">
                                <li>
                                    <xsl:value-of select="."/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:if>
                
                <!-- labels -->
                <div>
                    <ul class="list-inline">
                        
                        <xsl:choose>
                            <xsl:when test="eft:match/@type eq 'glossary-term'">
                                <li>
                                    <span class="label label-default">
                                        <xsl:value-of select="'Glossary'"/>
                                    </span>
                                </li>
                            </xsl:when>
                            <xsl:when test="eft:match/@type eq 'tm-unit'">
                                <li>
                                    <span class="label label-default">
                                        <xsl:value-of select="'TM'"/>
                                    </span>
                                </li>
                            </xsl:when>
                        </xsl:choose>
                        
                        <xsl:if test="eft:match/eft:flag[@type eq 'machine-alignment']">
                            <li>
                                <span class="label label-default">
                                    <xsl:value-of select="'Machine alignment'"/>
                                </span>
                            </li>
                        </xsl:if>
                        
                        <xsl:if test="eft:match/eft:flag[@type eq 'alternative-source']">
                            <li>
                                <span class="label label-default">
                                    <xsl:value-of select="'Translated from a different source'"/>
                                </span>
                            </li>
                        </xsl:if>
                        
                        <xsl:if test="eft:match/eft:flag[not(@type = ('machine-alignment','alternative-source','requires-attention'))]">
                            <li>
                                <span class="label label-default">
                                    <xsl:value-of select="eft:match/eft:flag/@type"/>
                                </span>
                            </li>
                        </xsl:if>
                        
                    </ul>
                </div>
                
            </div>
            
        </xsl:for-each>
    
    </xsl:template>
    
    <xsl:function name="eft:scan-src" as="xs:string">
        
        <xsl:param name="volume" as="xs:integer"/>
        <xsl:param name="folio" as="xs:string"/>
        <xsl:param name="source" as="xs:string"/>
        
        <xsl:variable name="folio-index" as="xs:integer">
            <xsl:variable name="number" select="replace($folio, '^(\d+)(.*)(a|b)?$', '$1') ! xs:integer(.)" as="xs:integer?"/>
            <xsl:variable name="letter" select="replace($folio, '^(\d+)(.*)(a|b)?$', '$3')" as="xs:string?"/>
            <xsl:value-of select="($number + 1) * 2 + (if($letter eq 'b') then 1 else 0) "/>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$source eq 'W4CZ5369'">
                
                <xsl:variable name="folio-index-adjusted">
                    <xsl:choose>
                        <xsl:when test="$volume = (1,6,58,75,86,100,101,102)">
                            <xsl:value-of select="$folio-index"/>
                        </xsl:when>
                        <xsl:when test="$volume = (20)">
                            <xsl:value-of select="$folio-index + 3"/>
                        </xsl:when>
                        <xsl:when test="$volume = (14,15,16,17,18,19,21,22,23,24,91)">
                            <xsl:value-of select="$folio-index + 2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$folio-index + 1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:variable name="volume-adjusted" select="($volume + 9126)"/>
                <xsl:value-of select="concat('http://iiif.bdrc.io/bdr:V4CZ5369_I1KG', format-number($volume-adjusted, '0000'), '::I1KG', format-number($volume-adjusted, '0000'), format-number($folio-index-adjusted, '0000'), '.jpg/full/full/0/default.jpg')"/>
                
                <!-- <xsl:value-of select="'http://iiif.bdrc.io/bdr:V4CZ5369_I1KG9160::I1KG91600289.jpg/full/full/0/default.jpg'"/> -->
                
            </xsl:when>
            <xsl:when test="$source eq 'W30532'">
                
                <xsl:variable name="volume-adjusted" select="($volume + 6347)"/>
                
                <xsl:value-of select="concat('http://iiif.bdrc.io/bdr:V30532_I', format-number($volume-adjusted, '0000'), '::',format-number($volume-adjusted, '0000'), format-number($folio-index, '0000'), '.tif/full/full/0/default.jpg')"/>
                
                <!--<xsl:value-of select="'http://iiif.bdrc.io/bdr:V30532_I6381::63810288.tif/full/full/0/default.jpg'"/>-->
                
            </xsl:when>
            <xsl:when test="$source eq 'adarsha'">
                
                <xsl:variable name="volume-adjusted">
                    <xsl:choose>
                        <xsl:when test="$volume eq 100">
                            <xsl:value-of select="101"/>
                        </xsl:when>
                        <xsl:when test="$volume eq 101">
                            <xsl:value-of select="102"/>
                        </xsl:when>
                        <xsl:when test="$volume eq 102">
                            <xsl:value-of select="100"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$volume"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:value-of select="concat('https://files.dharma-treasure.org/degekangyur/degekangyur', $volume-adjusted, '-1/', $volume-adjusted, '-1-', $folio,'.jpg')"/>
                
                <!--<xsl:value-of select="'https://files.dharma-treasure.org/degekangyur/degekangyur34-1/34-1-143b.jpg'"/> -->
                
            </xsl:when>
            <xsl:when test="$source eq 'W3CN20612'">
                
                <xsl:variable name="volume-adjusted">
                    <xsl:choose>
                        <xsl:when test="$volume gt 99">
                            <xsl:value-of select="$volume + (613 - 3)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 96">
                            <xsl:value-of select="$volume + (613 + 4)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 76">
                            <xsl:value-of select="$volume + (613 - 0)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 44">
                            <xsl:value-of select="$volume + (613 - 14)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 38">
                            <xsl:value-of select="$volume + (613 - 22)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 34">
                            <xsl:value-of select="$volume + (613 - 12)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 33">
                            <xsl:value-of select="$volume + (613 + 42)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 32">
                            <xsl:value-of select="$volume + (613 - 17)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 28">
                            <xsl:value-of select="$volume + (613 - 2)"/>
                        </xsl:when>
                        <xsl:when test="$volume gt 13">
                            <xsl:value-of select="$volume + (613 - 13)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$volume + (613 +62)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:value-of select="concat('http://iiif.bdrc.io/bdr:V3CN20612_I3CN2', format-number($volume-adjusted, '0000'), '::I3CN2', format-number($volume-adjusted, '0000'), format-number($folio-index, '0000'), '.jpg/full/full/0/default.jpg')"/>
                
                <!--<xsl:value-of select="'http://iiif.bdrc.io/bdr:V3CN20612_I3CN20689::I3CN206890288.jpg/full/full/0/default.jpg'"/>-->
                
            </xsl:when>
            <xsl:when test="$source eq 'W22084'">
                
                <xsl:variable name="volume-adjusted" select="($volume + 885)"/>
                
                <xsl:value-of select="concat('http://iiif.bdrc.io/bdr:V22084_I', format-number($volume-adjusted, '0000'), '::', format-number($volume-adjusted, '0000'), format-number($folio-index, '0000'), '.tif/full/full/0/default.jpg')"/>
                
                <!-- <xsl:value-of select="'http://iiif.bdrc.io/bdr:V22084_I0919::09190288.tif/full/full/0/default.jpg"/> -->
                
            </xsl:when>
        </xsl:choose>
        
        <!-- 
        <script>
            
            var input = document.getElementById("page");
            
            function getPageInfo(pageStr) {
                var letter = 'a';
                var indexLetter = pageStr.indexOf('a');
                if (indexLetter == -1) {
                    indexLetter = pageStr.indexOf('b');
                    letter = 'b';
                }
                if (indexLetter == -1) return null;
                var numbers = pageStr.substring(0, indexLetter);
                var imageNum = 2 * parseInt(numbers) + 1;
                if (letter == 'b') imageNum += 1;
                return imageNum;
            }
            
            function pad(n, width, z) {
                z = z || '0';
                n = n + '';
                return n.length &gt;= width ? n : new Array(width - n.length + 1).join(z) + n;
            }
            
            function getVolInfo(volStr) {
                var adjust = -62;
                if (parseInt(volStr) &gt; 13) adjust = 13;
                if (parseInt(volStr) &gt; 28) adjust = 2;
                if (parseInt(volStr) &gt; 32) adjust = 17;
                if (parseInt(volStr) &gt; 33) adjust = -42;
                if (parseInt(volStr) &gt; 34) adjust = 12;
                if (parseInt(volStr) &gt; 38) adjust = 22;
                if (parseInt(volStr) &gt; 44) adjust = 14;
                if (parseInt(volStr) &gt; 76) adjust = 0;
                if (parseInt(volStr) &gt; 96) adjust = -4;
                if (parseInt(volStr) &gt; 99) adjust = 3;
                volId4C = 'bdr:V4CZ5369_I1KG9'.concat(parseInt(volStr) + 126);
                volId22 = 'bdr:V22084_I0'.concat(parseInt(volStr) + 885);
                volId30 = 'bdr:V30532_I6'.concat(parseInt(volStr) + 347);
                volId3C = 'bdr:V3CN20612_I3CN20'.concat(parseInt(volStr) + (613 - adjust));
                return [volId4C, volId22, volId30, volId3C];
            }
            
            function getImageName(volume, imageNum) {
                res = [];
                var volInt = parseInt(volume);
                var paddedImageNum = pad('' + imageNum, 4, '0');
                var adjust = 1;
                if (volume == '1') adjust = 0;
                if (volume == '6') adjust = 0;
                if (volume == '14') adjust = 2;
                if (volume == '15') adjust = 2;
                if (volume == '16') adjust = 2;
                if (volume == '17') adjust = 2;
                if (volume == '18') adjust = 2;
                if (volume == '19') adjust = 2;
                if (volume == '20') adjust = 3;
                if (volume == '21') adjust = 2;
                if (volume == '22') adjust = 2;
                if (volume == '23') adjust = 2;
                if (volume == '24') adjust = 2;
                if (volume == '58') adjust = 0;
                if (volume == '75') adjust = 0;
                if (volume == '86') adjust = 0;
                if (volume == '91') adjust = 2;
                if (volume == '100') adjust = 0;
                if (volume == '101') adjust = 0;
                if (volume == '102') adjust = 0;
                var paddedImageNumB = pad('' + (imageNum + adjust), 4, '0');
                var volNum = volInt + 126;
                res[0] = 'I1KG9' + volNum + paddedImageNumB + '.jpg';
                volNum = volInt + 885;
                res[1] = '0' + volNum + paddedImageNum + '.tif';
                volNum = volInt + 347;
                res[2] = '6' + volNum + paddedImageNum + '.tif';
                var adjustV = -62;
                if (volInt &gt; 13) adjustV = 13;
                if (volInt &gt; 28) adjustV = 2;
                if (volInt &gt; 32) adjustV = 17;
                if (volInt &gt; 33) adjustV = -42;
                if (volInt &gt; 34) adjustV = 12;
                if (volInt &gt; 38) adjustV = 22;
                if (volInt &gt; 44) adjustV = 14;
                if (volInt &gt; 76) adjustV = 0;
                if (volInt &gt; 96) adjustV = -4;
                if (volInt &gt; 99) adjustV = 3;
                volNum = volInt + (613 - adjustV);
                res[3] = 'I3CN20' + volNum + paddedImageNum + '.jpg';
                return res;
            }
            
            function adarshaUrl(volume, page) {
                volumeAdjust = volume
                if (volume == '100') volumeAdjust = 101;
                if (volume == '101') volumeAdjust = 102;
                if (volume == '102') volumeAdjust = 100;
                // adarsha url: https://files.dharma-treasure.org/degekangyur/degekangyur1-1/1-1-1b.jpg
                return "https://files.dharma-treasure.org/degekangyur/degekangyur"+volumeAdjust+"-1/"+volumeAdjust+"-1-"+page+".jpg";
            }
            
            function printimage() {
                var volume = document.getElementById('volume').value;
                var page = document.getElementById('page').value;
                var imageNum = getPageInfo(page);
                
                if (imageNum == null) return;
                
                var volIds = getVolInfo(volume);
                
                var imageNames = getImageName(volume, imageNum);
                for (var i = 1; i &lt;= 4; i++) {
                    
                    var imageUrl = 'http://iiif.bdrc.io/' + volIds[i] + '::' + imageNames[i] + '/full/full/0/default.jpg';
                    var imgId = 'theimage' + i;
                    
                    document.getElementById(imgId).src = imageUrl;
                
                }
                
                document.getElementById('theimage5').src = adarshaUrl(volume, page);
            
            }
            
            printimage();
            
        </script>-->
        
    </xsl:function>
    
</xsl:stylesheet>