<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:key name="master-texts" match="/m:response/m:translations-master//m:text" use="@id"/>
    <xsl:key name="master-downloads" match="/m:response/m:translations-master//m:text/m:downloads" use="@resource-id"/>
    
    <xsl:template match="/m:response">
        
        <!--<xsl:variable name="environment" select="m:environment"/>-->
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="reading-room-no-cache-path" select="$environment/m:url[@id eq 'reading-room-no-cache']/text()"/>
        <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
        <xsl:variable name="request" select="m:request"/>
        <xsl:variable name="page-filter" select="$request/m:parameter[@name eq 'page-filter']/text()"/>
        <xsl:variable name="toh-min" select="$request/m:parameter[@name eq 'toh-min']/text()"/>
        <xsl:variable name="toh-max" select="$request/m:parameter[@name eq 'toh-max']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="row">
                
                <!-- Search form -->
                <div class="col-sm-6">
                    <form action="/translations.html" method="get" class="form-horizontal labels-left">
                        
                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                        
                        <input type="hidden" name="page-filter" value="search"/>
                        
                        <fieldset>
                            
                            <legend>
                                <xsl:value-of select="'Search for a Tohoku number'"/>
                            </legend>
                            
                            <div class="form-group">
                                <label for="toh-min" class="col-sm-2 control-label">
                                    <xsl:value-of select="'Tohoku:'"/>
                                </label>
                                <div class="col-sm-2">
                                    <input type="number" name="toh-min" class="form-control" id="toh-min" maxlength="5" placeholder="min.">
                                        <xsl:attribute name="value" select="$toh-min"/>
                                    </input>
                                </div>
                                <div class="col-sm-2">
                                    <input type="number" name="toh-max" class="form-control" id="toh-max" maxlength="5" placeholder="max.">
                                        <xsl:attribute name="value" select="$toh-max"/>
                                    </input>
                                </div>
                                <div class="col-sm-2">
                                    <button type="submit" class="btn btn-primary">
                                        <xsl:value-of select="'Search'"/>
                                    </button>
                                </div>
                            </div>
                            
                        </fieldset>
                        
                    </form>
                </div>
                
                <!-- Actions -->
                <xsl:choose>
                    
                    <xsl:when test="$page-filter eq 'new-version-placeholders' and m:texts[m:text]">
                        <div class="col-sm-6">
                            <form action="/translations.html" method="post" class="form-horizontal">
                                
                                <xsl:attribute name="data-loading" select="'Getting updated files...'"/>
                                
                                <input type="hidden" name="page-filter" value="new-version-placeholders"/>
                                
                                <fieldset>
                                    
                                    <legend>
                                        <xsl:value-of select="'Get all updated placeholder files'"/>
                                    </legend>
                                    
                                    <div class="form-group">
                                        
                                        <xsl:for-each-group select="m:texts/m:text" group-by="@id">
                                            <input type="hidden" name="store[]" value="{ concat(@id, '.all') }"/>
                                        </xsl:for-each-group>
                                        
                                        <div class="col-sm-12">
                                            <button type="submit" class="btn btn-danger btn-sml">
                                                <xsl:value-of select="'Get placeholder files'"/>
                                            </button>
                                        </div>
                                    </div>
                                    
                                </fieldset>
                                
                            </form>
                        </div>
                    </xsl:when>
                    
                    <!--
                    <xsl:when test="$page-filter eq 'new-version-translations' and $environment/m:store-conf[@type eq 'client'] and $request/m:authenticated-user/m:group[@name eq 'git-push']">
                        <div class="col-sm-6">
                            <form method="post" class="form-horizontal bottom-margin">
                                
                                <xsl:attribute name="action" select="concat('translations.html', '?page-filter=', $page-filter)"/>
                                <xsl:attribute name="data-loading" select="'Getting shared data files...'"/>
                                
                                <input type="hidden" name="form-action" value="pull-data-operations"/>
                                
                                <fieldset>
                                    
                                    <legend>
                                        <xsl:value-of select="'Get updated shared data e.g. entities, sponsorship, contributors...'"/>
                                    </legend>
                                    
                                    <div class="form-group">
                                        
                                        <label for="deploy-password" class="col-sm-4 control-label">
                                            <xsl:value-of select="'Deployment password:'"/>
                                        </label>
                                        
                                        <div class="col-sm-4">
                                            <input type="password" name="deploy-password" class="form-control" id="deploy-password" placeholder=""/>
                                        </div>
                                        
                                        <div class="col-sm-4">
                                            <button type="submit" class="btn btn-danger btn-sm">
                                                <xsl:value-of select="'Get updates'"/>
                                            </button>
                                        </div>
                                        
                                    </div>
                                    
                                </fieldset>
                                
                            </form>
                        </div>
                    </xsl:when>
                    
                    <xsl:when test="$page-filter = ('1', 'recent-updates') and $environment/m:store-conf[@type eq 'master'] and $request/m:authenticated-user/m:group[@name eq 'git-push']">
                        <div class="col-sm-6">
                            <form method="post" class="form-horizontal bottom-margin">
                                
                                <xsl:attribute name="action" select="concat('translations.html', '?page-filter=', $page-filter)"/>
                                <xsl:attribute name="data-loading" select="'Pushing shared data...'"/>
                                
                                <input type="hidden" name="form-action" value="push-data-operations"/>
                                
                                <fieldset>
                                    
                                    <legend>
                                        <xsl:value-of select="'Publish updates to shared data files e.g. entities, sponsorship, contributors...'"/>
                                    </legend>
                                    
                                    <div class="form-group">
                                        
                                        <label for="deploy-password" class="col-sm-4 control-label">
                                            <xsl:value-of select="'Deployment password:'"/>
                                        </label>
                                        
                                        <div class="col-sm-4">
                                            <input type="password" name="deploy-password" class="form-control" id="deploy-password" placeholder=""/>
                                        </div>
                                        
                                        <div class="col-sm-4">
                                            <button type="submit" class="btn btn-danger btn-sm">
                                                <xsl:value-of select="'Publish updates'"/>
                                            </button>
                                        </div>
                                        
                                    </div>
                                    
                                </fieldset>
                                
                            </form>
                        </div>
                    </xsl:when> -->
                    
                </xsl:choose>
            
            </div>
            
            <!-- Form to specify status -->
            <form action="/translations.html" method="get" class="form-horizontal filter-form clearfix top-margin">
                
                <xsl:attribute name="data-loading" select="'Loading...'"/>
                
                <div class="center-vertical full-width bottom-margin">
                    
                    <div class="text-muted">
                        <xsl:value-of select="'Select a filter:'"/>
                    </div>
                    
                    <div>
                        <div class="input-group">
                            <select name="page-filter" id="page-filter" class="form-control">
                                
                                <option>
                                    <xsl:value-of select="'[Choose a filter]'"/>
                                </option>
                                
                                <option value="recent-updates">
                                    <xsl:if test="$page-filter eq 'recent-updates'">
                                        <xsl:attribute name="selected" select="'selected'"/>
                                    </xsl:if>
                                    <xsl:value-of select="'Recent updates to published texts'"/>
                                </option>
                                
                                <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                    <optgroup label="Available updates">
                                        <option value="new-version-translations">
                                            <xsl:if test="$page-filter eq 'new-version-translations'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Get updated publications'"/>
                                        </option>
                                        <option value="new-version-placeholders">
                                            <xsl:if test="$page-filter eq 'new-version-placeholders'">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Get updated placeholders'"/>
                                        </option>
                                    </optgroup>
                                </xsl:if>
                                
                                <optgroup label="Show texts by status">
                                    <xsl:for-each select="m:text-statuses/m:status[not(@status-id eq '0')]">
                                        <option>
                                            <xsl:attribute name="value" select="@status-id"/>
                                            <xsl:if test="@status-id eq $page-filter">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(@status-id, ' / ', text())"/>
                                        </option>
                                    </xsl:for-each>
                                </optgroup>
                                
                            </select>
                            <div class="input-group-btn">
                                <button class="btn btn-primary" type="submit">
                                    <xsl:attribute name="title" select="'reload'"/>
                                    <i class="fa fa-refresh"/>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Show count of texts -->
                    <div class="text-right">
                        <xsl:variable name="count-results" select="count(distinct-values(m:texts/m:text/@id | m:recent-updates/m:text/@id))"/>
                        <span class="badge badge-notification">
                            <xsl:value-of select="fn:format-number($count-results,'#,##0')"/>
                        </span>
                        <xsl:choose>
                            <xsl:when test="$count-results eq 1">
                                <xsl:value-of select="' result'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="' results'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    
                </div>
            
            </form>
            
            <!-- List of texts -->
            <xsl:choose>
                
                <xsl:when test="m:texts[m:text]">
                    <table class="table table-responsive">
                        <thead>
                            <tr>
                                <th>
                                    <xsl:value-of select="'Toh.'"/>
                                </th>
                                <th>
                                    <xsl:value-of select="'Title'"/>
                                </th>
                                <th/>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each-group select="m:texts/m:text" group-by="@id">
                                
                                <xsl:sort select="number(m:toh[1]/@number)"/>
                                <xsl:sort select="m:toh[1]/m:base"/>
                                
                                <xsl:variable name="text-group" select="current-group()"/>
                                <xsl:variable name="text-id" select="@id"/>
                                <xsl:variable name="text-status-id" select="@status[1]"/>
                                <xsl:variable name="text-status-group" select="@status-group[1]"/>
                                <xsl:variable name="text-toh" select="m:toh[1]"/>
                                <xsl:variable name="text-titles" select="m:titles[1]"/>
                                <xsl:variable name="text-tei-version" select="m:downloads[1]/@tei-version"/>
                                <xsl:variable name="text-status-updates" select="m:status-updates[1]"/>
                                <xsl:variable name="text-master-first-text" select="key('master-texts', $text-id)[1]"/>
                                <xsl:variable name="text-master-tei-version" select="$text-master-first-text/m:downloads[1]/@tei-version"/>
                                <xsl:variable name="text-master-status-updates" select="$text-master-first-text/m:status-updates[1]"/>
                                <xsl:variable name="text-master-status-id" select="($text-master-first-text/@translation-status, $text-master-first-text/@publication-status)[1]"/>
                                <xsl:variable name="text-master-status-group" select="/m:response/m:text-statuses/m:status[@status-id eq $text-master-status-id]/@group"/>
                                <xsl:variable name="text-marked-up" select="/m:response/m:text-statuses/m:status[@status-id eq $text-status-id][@marked-up eq 'true']"/>
                                
                                <!-- File status -->
                                <xsl:variable name="files-status" as="element(m:file-status)*">
                                    
                                    <!-- TEI status -->
                                    <xsl:element name="file-status" namespace="http://read.84000.co/ns/1.0">
                                        <xsl:attribute name="file-type" select="'tei'"/>
                                        <xsl:attribute name="local-tei-version" select="$text-tei-version"/>
                                        <xsl:attribute name="master-tei-version" select="$text-master-tei-version"/>
                                        <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                            <xsl:if test="($text-master-tei-version gt '' and not(compare($text-master-tei-version, $text-tei-version) eq 0)) or (not(compare($text-status-id, $text-master-status-id) eq 0))">
                                                <xsl:attribute name="status" select="'local-behind'"/>
                                            </xsl:if>
                                        </xsl:if>
                                    </xsl:element>
                                    
                                    <!-- Associated files -->
                                    <xsl:for-each select="('pdf', 'epub', 'rdf', 'cache')">
                                        
                                        <xsl:variable name="file-format" select="."/>
                                        
                                        <xsl:for-each select="$text-group">
                                            
                                            <xsl:variable name="toh-key" select="m:toh/@key"/>
                                            <xsl:variable name="local-downloads" select="m:downloads/m:download"/>
                                            <xsl:variable name="local-file-version" select="$local-downloads[@type eq $file-format]/@version"/>
                                            <xsl:variable name="master-downloads" select="key('master-downloads', $toh-key)"/>
                                            <xsl:variable name="master-file-version" select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                            
                                            <xsl:element name="file-status" namespace="http://read.84000.co/ns/1.0">
                                                
                                                <xsl:attribute name="file-type" select="lower-case($file-format)"/>
                                                <xsl:attribute name="toh-key" select="$toh-key"/>
                                                <xsl:attribute name="local-tei-version" select="$text-tei-version"/>
                                                <xsl:attribute name="master-tei-version" select="$master-downloads/@tei-version"/>
                                                <xsl:attribute name="local-file-version" select="$local-file-version"/>
                                                <xsl:attribute name="master-file-version" select="$master-file-version"/>
                                                
                                                <xsl:choose>
                                                    
                                                    <xsl:when test="$environment/m:store-conf[@type eq 'master']">
                                                        
                                                        <xsl:choose>
                                                            <xsl:when test="$text-tei-version gt '' and $text-marked-up and not(compare($local-file-version, $text-tei-version) eq 0)">
                                                                <xsl:attribute name="status" select="'local-behind'"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        
                                                    </xsl:when>
                                                    
                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                        
                                                        <xsl:choose>
                                                            
                                                            <!-- If master is outdated then just warn -->
                                                            <xsl:when test="not($master-file-version gt '') or not(compare($master-file-version, $master-downloads/@tei-version) eq 0)">
                                                                <xsl:attribute name="status" select="'master-behind'"/>
                                                            </xsl:when>
                                                            
                                                            <!-- If outdated then offer to get from master -->
                                                            <xsl:when test="not(compare($local-file-version, $master-downloads/@tei-version) eq 0)">
                                                                <xsl:attribute name="status" select="'local-behind'"/>
                                                            </xsl:when>
                                                            
                                                        </xsl:choose>
                                                    </xsl:when>
                                                    
                                                </xsl:choose>
                                                
                                            </xsl:element>
                                                                                            
                                        </xsl:for-each>
                                        
                                    </xsl:for-each>
                                
                                </xsl:variable>
                                
                                <tr>
                                    
                                    <xsl:attribute name="id" select="$text-id"/>
                                    
                                    <!-- Toh -->
                                    <td>
                                        <xsl:for-each select="$text-group">
                                            <xsl:if test="position() gt 1">
                                                <br/>
                                            </xsl:if>
                                            <span class="nowrap">
                                                <xsl:if test="position() gt 1">
                                                    <xsl:value-of select="'+ '"/>
                                                </xsl:if>
                                                <xsl:value-of select="m:toh/m:base"/>
                                            </span>
                                        </xsl:for-each>
                                    </td>
                                    
                                    <!-- Data -->
                                    <td>
                                        
                                        <!-- Title -->
                                        <div class="sml-margin bottom">
                                            
                                            <span>
                                                <xsl:value-of select="$text-titles/m:title[@xml:lang eq 'en']"/>
                                            </span>
                                            
                                            <span class="small">
                                                <xsl:value-of select="' / '"/>
                                                <xsl:value-of select="concat(format-number(m:source/m:location[1]/@count-pages, '#,###'), ' pages')"/>
                                            </span>
                                            
                                            <!--<span class="small">
                                                <xsl:value-of select="' / '"/>
                                                <a>
                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text-id, '.html')"/>
                                                    <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                    <xsl:attribute name="title" select="concat('Open ', $text-id, '.html in the Reading Room')"/>
                                                    <xsl:value-of select="$text-id"/>
                                                </a>
                                            </span>-->
                                            
                                            <xsl:for-each select="$text-group">
                                                <span class="small">
                                                    <xsl:value-of select="' / '"/>
                                                    <a>
                                                        <xsl:attribute name="href" select="m:translation-href(m:toh/@key, (), (), (), (), $reading-room-path)"/>
                                                        <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                        <xsl:attribute name="title" select="concat('Open ', m:toh/@key, '.html in the Reading Room')"/>
                                                        <xsl:value-of select="m:toh/@key"/>
                                                    </a>
                                                </span>
                                            </xsl:for-each>
                                            
                                        </div>
                                        
                                        <!-- Links -->
                                        <div class="small sml-margin bottom">
                                            <ul class="list-inline inline-dots">
                                                
                                                <!-- bypass cache -->
                                                <xsl:if test="$reading-room-no-cache-path">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="m:translation-href(m:toh/@key, (), (), (), (), $reading-room-no-cache-path)"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="title" select="'View this text by-passing the cache'"/>
                                                            <xsl:value-of select="'bypass cache'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                                <!-- editor mode -->
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="m:translation-href(m:toh/@key, (), (), (), '?view-mode=editor', $reading-room-path)"/>
                                                        <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                        <xsl:attribute name="title" select="'View this text in editor mode'"/>
                                                        <xsl:value-of select="'editor mode'"/>
                                                    </a>
                                                </li>
                                                
                                                <!-- run tests -->
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat('/test-translations.html?translation-id=', $text-id)"/>
                                                        <xsl:attribute name="target" select="concat('test-translation-', $text-id, '.html')"/>
                                                        <xsl:attribute name="title" select="'Run automated tests on this text'"/>
                                                        <xsl:value-of select="'run tests'"/>
                                                    </a>
                                                </li>
                                                
                                                <!-- edit headers -->
                                                <xsl:if test="$operations-path">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($operations-path ,'/edit-text-header.html?id=', $text-id)"/>
                                                            <xsl:attribute name="target" select="'84000-operations'"/>
                                                            <xsl:attribute name="title" select="'Edit TEI headers in project management'"/>
                                                            <xsl:value-of select="'edit headers'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                
                                                <!-- xml -->
                                                <li>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.xml')"/>
                                                        <xsl:attribute name="target" select="concat(m:toh/@key, '.xml')"/>
                                                        <xsl:attribute name="title" select="'View xml data'"/>
                                                        <xsl:value-of select="'xml'"/>
                                                    </a>
                                                </li>
                                                
                                                <!-- rdf -->
                                                <xsl:for-each select="$text-group">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.rdf')"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.rdf')"/>
                                                            <xsl:attribute name="title" select="concat('Dynamic rdf data for ', m:toh/@key)"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '.rdf')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                
                                                <!-- English txt -->
                                                <xsl:for-each select="$text-group">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '-en.txt')"/>
                                                            <xsl:attribute name="title" select="'Download translation as a text file'"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '-en.txt')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                <xsl:for-each select="$text-group">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '-en-plain.txt')"/>
                                                            <xsl:attribute name="title" select="'Download translation as a text file without annotations'"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '-en-plain.txt')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                
                                                <!-- Tibetan txt -->
                                                <xsl:for-each select="$text-group">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', m:toh/@key, '-bo.txt')"/>
                                                            <xsl:attribute name="title" select="'Download the source as a text file'"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '-bo.txt')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                <xsl:for-each select="$text-group">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', m:toh/@key, '-bo-plain.txt')"/>
                                                            <xsl:attribute name="title" select="'Download the source as a text file without annotations'"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '-bo-plain.txt')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                
                                            </ul>
                                        </div>
                                        
                                        <!-- Location of tei file -->
                                        <div class="small sml-margin bottom">
                                            <a class="break text-muted">
                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                                <xsl:attribute name="target" select="concat($text-id, '.tei')"/>
                                                <xsl:attribute name="title" select="@document-url"/>
                                                <xsl:value-of select="@document-url"/>
                                            </a>
                                        </div>
                                        
                                        <!-- TEI version -->
                                        <div class="sml-margin bottom">
                                            
                                            <ul class="list-inline">
                                                
                                                <!-- Local version -->
                                                <li>
                                                    <span class="small">
                                                        <xsl:value-of select="'Local TEI: '"/>
                                                    </span>
                                                    <span class="label label-info">
                                                        <xsl:value-of select="($text-tei-version[. gt ''], '[No version]')[1]"/>
                                                    </span>
                                                </li>
                                                
                                                <!-- Master version -->
                                                <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                    <li>
                                                        <span class="small">
                                                            <xsl:value-of select="'Master TEI: '"/>
                                                        </span>
                                                        <span class="label label-info">
                                                            <xsl:if test="$files-status[@file-type eq 'tei'][@status eq 'local-behind']">
                                                                <xsl:attribute name="class" select="'label label-danger'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="($text-master-tei-version[. gt ''], '[No version]')[1]"/>
                                                        </span>
                                                    </li>
                                                </xsl:if>
                                                
                                                <!-- Status change -->
                                                <li>
                                                    <ul class="list-inline">
                                                        <li>
                                                            <span class="label label-warning">
                                                                <xsl:if test="$text-status-group eq 'published'">
                                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="$text-status-id"/>
                                                            </span>
                                                        </li>
                                                        <xsl:if test="$environment/m:store-conf[@type eq 'client'] and not(compare($text-status-id, $text-master-status-id) eq 0)">
                                                            <li>
                                                                <i class="fa fa-angle-right"/>
                                                            </li>
                                                            <li>
                                                                <span class="label label-warning">
                                                                    <xsl:if test="$text-master-status-group eq 'published'">
                                                                        <xsl:attribute name="class" select="'label label-success'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="$text-master-status-id"/>
                                                                </span>
                                                            </li>
                                                        </xsl:if>
                                                    </ul>
                                                </li>
                                                
                                                <!-- TEI status -->
                                                <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                    <li>
                                                        <xsl:choose>
                                                            
                                                            <xsl:when test="$files-status[@file-type eq 'tei'][@status eq 'local-behind']">
                                                                <span class="label label-warning">
                                                                    <xsl:value-of select="'TEI behind'"/>
                                                                </span>
                                                            </xsl:when>
                                                            
                                                            <!-- Up to date -->
                                                            <xsl:otherwise>
                                                                <span class="label label-default">
                                                                    <xsl:value-of select="'TEI up-to-date'"/>
                                                                </span>
                                                            </xsl:otherwise>
                                                            
                                                        </xsl:choose>
                                                    </li>
                                                </xsl:if>
                                            
                                            </ul>
                                            
                                        </div>
                                        
                                        <!-- Version update message -->
                                        <xsl:variable name="version-update-message" as="xs:string?">
                                            <xsl:choose>
                                                <xsl:when test="$environment/m:store-conf[@type eq 'client'] and $text-master-status-updates/m:status-update[(@update, @type) = 'text-version'][@current-version eq 'true'][descendant::text()[normalize-space()]]">
                                                    <xsl:value-of select="string-join($text-master-status-updates/m:status-update[(@update, @type) = 'text-version'][@current-version eq 'true']/descendant::text() ! normalize-space(), '; ')"/>
                                                </xsl:when>
                                                <xsl:when test="$environment/m:store-conf[@type eq 'master'] and $text-status-updates/m:status-update[@type eq 'text-version'][@current-version eq 'true'][descendant::text()[normalize-space()]]">
                                                    <xsl:value-of select="string-join($text-status-updates/m:status-update[@type eq 'text-version'][@current-version eq 'true']/descendant::text() ! normalize-space(), '; ')"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:variable>
                                        
                                        <xsl:if test="$version-update-message">
                                            <div class="small sml-margin bottom">
                                                <span class="text-muted">
                                                    <xsl:choose>
                                                        <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                            <xsl:value-of select="'Version note (master): '"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'Version note: '"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                <span class="italic text-danger">
                                                    <xsl:value-of select="$version-update-message"/>
                                                </span>
                                                <xsl:value-of select="' / '"/>
                                                <a target="84000-github">
                                                    <xsl:attribute name="href" select="concat('https://github.com/84000/data-tei/commits/master', substring-after(@document-url, concat($environment/@data-path, '/tei')))"/>
                                                    <xsl:value-of select="'Review change on Github'"/>
                                                </a>
                                            </div>
                                        </xsl:if>
                                        
                                        <hr class="sml-margin"/>
                                        
                                        <!-- files -->
                                        <div class="row">
                                            
                                            <xsl:variable name="file-formats" select="('pdf', 'epub', 'rdf', 'cache')"/>
                                            
                                            <xsl:for-each select="$file-formats">
                                                
                                                <xsl:variable name="file-format" select="."/>
                                                
                                                <div class="col-sm-2">
                                                    
                                                    <xsl:for-each select="$text-group">
                                                        
                                                        <xsl:variable name="toh" select="m:toh"/>
                                                        <xsl:variable name="local-downloads" select="m:downloads/m:download"/>
                                                        <xsl:variable name="local-file-version" select="$local-downloads[@type eq $file-format]/@version"/>
                                                        <xsl:variable name="master-downloads" select="key('master-downloads', $toh/@key)"/>
                                                        <xsl:variable name="master-file-version" select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                                        
                                                        <div class="sml-margin bottom">
                                                            
                                                            <!-- Title / Link -->
                                                            <div class="small">
                                                                <xsl:choose>
                                                                    <xsl:when test="$local-downloads[@type eq $file-format]">
                                                                        <a href="#" class="underline disabled">
                                                                            <xsl:if test="$local-file-version[not(. eq 'none')]">
                                                                                <xsl:attribute name="href" select="concat($reading-room-path, $local-downloads[@type eq $file-format]/@url)"/>
                                                                                <xsl:attribute name="class" select="'small underline'"/>
                                                                            </xsl:if>
                                                                            <xsl:if test="$local-downloads[@type eq $file-format][not(@download-url)]">
                                                                                <xsl:attribute name="target" select="concat($toh/@key, '.', $file-format)"/>
                                                                            </xsl:if>
                                                                            <xsl:value-of select="tokenize($local-downloads[@type eq $file-format]/@url, '/')[last()]"/>
                                                                        </a>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="'[missing]'"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </div>
                                                            
                                                            <!-- Local version -->
                                                            <div class="small">
                                                                <xsl:choose>
                                                                    <xsl:when test="$local-downloads[@type eq $file-format][not(@version = ('none', 'unknown', ''))]/@version">
                                                                        <xsl:value-of select="$local-downloads[@type eq $file-format]/@version"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:attribute name="class" select="'small text-muted'"/>
                                                                        <xsl:value-of select="'[none]'"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </div>
                                                            
                                                            <!-- Master version -->
                                                            <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                                <div class="small">
                                                                    <xsl:choose>
                                                                        <xsl:when test="$master-downloads/m:download[@type eq $file-format][not(@version = ('none', 'unknown', ''))]/@version">
                                                                            <xsl:value-of select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:attribute name="class" select="'small text-muted'"/>
                                                                            <xsl:value-of select="'[none]'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </div>
                                                            </xsl:if>
                                                            
                                                            <!-- Action -->
                                                            <div>
                                                                <xsl:choose>
                                                                    
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'master']">
                                                                        
                                                                        <xsl:if test="$files-status[@file-type eq lower-case($file-format)][@toh-key eq $toh/@key][@status eq 'local-behind']">
                                                                            <span class="label label-primary">
                                                                                <xsl:value-of select="concat(upper-case($file-format), ' behind')"/>
                                                                            </span>
                                                                        </xsl:if>
                                                                        
                                                                    </xsl:when>
                                                                    
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                        
                                                                        <xsl:choose>
                                                                            
                                                                            <!-- If master is outdated then just warn -->
                                                                            <xsl:when test="$files-status[@file-type eq lower-case($file-format)][@toh-key eq $toh/@key][@status eq 'master-behind']">
                                                                                <span class="label label-default">
                                                                                    <xsl:value-of select="'Update on collaboration'"/>
                                                                                </span>
                                                                            </xsl:when>
                                                                            
                                                                            <!-- If outdated then offer to get from master -->
                                                                            <xsl:when test="$files-status[@file-type eq lower-case($file-format)][@toh-key eq $toh/@key][@status eq 'local-behind']">
                                                                                <span class="label label-warning">
                                                                                    <xsl:value-of select="concat(upper-case($file-format), ' behind')"/>
                                                                                </span>
                                                                            </xsl:when>
                                                                            
                                                                            <!-- Up to date -->
                                                                            <xsl:otherwise>
                                                                                <span class="label label-default">
                                                                                    <xsl:value-of select="'up-to-date'"/>
                                                                                </span>
                                                                            </xsl:otherwise>
                                                                            
                                                                        </xsl:choose>
                                                                    </xsl:when>
                                                                    
                                                                </xsl:choose>
                                                                
                                                            </div>
                                                            
                                                        </div>
                                                        
                                                    </xsl:for-each>
                                                    
                                                </div>
                                                
                                            </xsl:for-each>
                                            
                                        </div>
                                        
                                        <hr class="sml-margin"/>
                                        
                                        <!-- Update form -->
                                        <xsl:choose>
                                            
                                            <!-- Alert if local file locked -->
                                            <xsl:when test="@locked-by-user gt ''">
                                                <div class="sml-margin bottom small text-danger italic">
                                                    <xsl:value-of select="concat('Local TEI file is currenly locked by user ', @locked-by-user)"/>
                                                </div>
                                            </xsl:when>
                                            
                                            <!-- Alert if master file locked -->
                                            <xsl:when test="$environment/m:store-conf[@type eq 'client'] and $text-master-first-text[@locked-by-user gt '']">
                                                <div class="sml-margin bottom small text-danger italic">
                                                    <xsl:value-of select="concat('Master TEI file is currenly locked by user ', $text-master-first-text/@locked-by-user)"/>
                                                </div>
                                            </xsl:when>
                                            
                                            <xsl:when test="$environment/m:store-conf[@type = ('client','master')] and $files-status[@status eq 'local-behind']">
                                                <form method="post" class="form-horizontal sml-margin bottom">
                                                    
                                                    <xsl:attribute name="action" select="concat('translations.html', '?page-filter=', $page-filter, '#', $text-id)"/>
                                                    
                                                    <xsl:choose>
                                                        <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                            <xsl:attribute name="data-loading" select="'Getting updated files...'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="data-loading" select="'Creating new files...'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    
                                                    <input type="hidden" name="store[]" value="{ concat($text-id, '.all') }"/>
                                                    
                                                    <xsl:if test="$page-filter eq 'search'">
                                                        <input type="hidden" name="toh-min" value="{ $toh-min }"/>
                                                        <input type="hidden" name="toh-max" value="{ $toh-max }"/>
                                                    </xsl:if>
                                                    
                                                    <div class="form-group">
                                                        
                                                        <div class="col-sm-2">
                                                            <button type="submit" class="btn btn-danger btn-sm btn-block">
                                                                <xsl:choose>
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                        <xsl:value-of select="'Get updated files'"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of select="'Create new versions'"/>
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </button>
                                                        </div>
                                                        
                                                    </div>
                                                    
                                                </form>
                                                
                                            </xsl:when>
                                            
                                            <xsl:otherwise>
                                                <div class="sml-margin bottom small text-success italic">
                                                    <xsl:value-of select="'No updates to this text'"/>
                                                </div>
                                            </xsl:otherwise>
                                            
                                        </xsl:choose>
                                    </td>
                                    
                                </tr>
                                
                            </xsl:for-each-group>
                        </tbody>
                        
                    </table>
                </xsl:when>
                
                <xsl:when test="m:recent-updates[m:text]">
                    
                    <xsl:variable name="recent-updated-texts" select="m:recent-updates/m:text"/>
                    <xsl:for-each select="('new-publication', 'new-version')">
                        
                        <xsl:variable name="recent-update-type" select="."/>
                        
                        <div class="center-vertical full-width">
                            
                            <div>
                                <h3 class="no-top-margin">
                                    <xsl:choose>
                                        <xsl:when test="$recent-update-type eq 'new-publication'">
                                            <xsl:value-of select="'New Publications'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'New Versions'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h3>
                            </div>
                            
                            <!-- Download button -->
                            <xsl:if test="position() eq 1">
                                <div class="text-right">
                                    <a>
                                        <xsl:attribute name="href" select="'translations.xlsx?page-filter=recent-updates'"/>
                                        <xsl:attribute name="title" select="'Download as spreadsheet'"/>
                                        <xsl:attribute name="class" select="'btn btn-warning'"/>
                                        <i class="fa fa-cloud-download"/>
                                        <xsl:value-of select="' download'"/>
                                    </a>
                                </div>
                            </xsl:if>
                            
                        </div>
                        
                        <xsl:choose>
                            
                            <xsl:when test="$recent-updated-texts[@recent-update eq $recent-update-type]">
                                
                                <table class="table no-border width-auto">
                                    
                                    <xsl:for-each select="$recent-updated-texts[@recent-update eq $recent-update-type]">
                                        
                                        <xsl:sort select="number(m:toh[1]/@number)"/>
                                        <xsl:sort select="m:toh[1]/@letter"/>
                                        <xsl:sort select="number(m:toh[1]/@chapter-number)"/>
                                        <xsl:sort select="m:toh[1]/@chapter-letter"/>
                                        
                                        <xsl:variable name="toh-key" select="(m:toh/@key)[1]"/>
                                        
                                        <tr class="vertical-top">
                                            <td>
                                                <span>
                                                    <xsl:attribute name="class">
                                                        <xsl:choose>
                                                            <xsl:when test="@status-group eq 'published'">
                                                                <xsl:value-of select="'label label-success'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="'label label-warning'"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="@status"/>
                                                </span>
                                            </td>
                                            <td>
                                                <h4 class="no-top-margin no-bottom-margin">
                                                    <a>
                                                        <xsl:attribute name="href" select="m:translation-href($toh-key, (), (), (), '?view-mode=editor', $reading-room-path)"/>
                                                        <xsl:attribute name="target" select="concat($toh-key, '.html')"/>
                                                        <xsl:attribute name="title" select="concat('Open ', $toh-key, '.html in the Reading Room')"/>
                                                        <xsl:value-of select="'Toh ' || string-join(m:toh/m:base, ' / ') || ' (' || @id || ') '"/>
                                                    </a>
                                                </h4>
                                                <div class="small">
                                                    <xsl:choose>
                                                        <xsl:when test="$recent-update-type eq 'new-publication'">
                                                            <xsl:variable name="published-statuses" select="/m:response/m:text-statuses/m:status[@type eq 'translation'][@group eq 'published']/@status-id" as="xs:string*"/>
                                                            <xsl:for-each select="tei:change[@type = ('translation-status', 'publication-status')][@status = $published-statuses]">
                                                                <xsl:sort select="@when"/>
                                                                <span class="text-muted">
                                                                    <xsl:value-of select="common:date-user-string(concat('Status ', @status, ' set'), @when, @who)"/>
                                                                </span>
                                                            </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:for-each select="tei:change">
                                                                <xsl:sort select="@when"/>
                                                                <span class="text-muted">
                                                                    <xsl:value-of select="common:date-user-string(concat('Version ', @status, ' created'), @when, @who)"/>
                                                                </span>
                                                                <br/>
                                                                <span class="text-danger">
                                                                    <xsl:value-of select="string-join(('Note: ', descendant::text() ! normalize-space()), '')"/>
                                                                </span>
                                                            </xsl:for-each>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                            </td>
                                        </tr>
                                    
                                    </xsl:for-each>
                                </table>
                            
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <p class="text-muted italic">
                                    <xsl:value-of select="'No matching texts'"/>
                                </p>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    
                    </xsl:for-each>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <p class="text-muted italic text-center">
                        <xsl:value-of select="'~ No matching texts ~'"/>
                    </p>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:variable>
        
        <xsl:variable name="page-alert">
            <xsl:choose>
                
                <xsl:when test="m:updated">
                    <div id="page-alert" class="fixed-footer fix-height collapse in info text-left" role="alert">
                        
                        <xsl:choose>
                            <xsl:when test="m:updated//m:error">
                                <xsl:attribute name="class" select="'fixed-footer fix-height collapse in danger'"/>
                            </xsl:when>
                        </xsl:choose>
                        
                        <div class="container">
                            
                            <xsl:choose>
                                <xsl:when test="m:updated//m:error">
                                    <h2 class="sml-margin top bottom">
                                        <xsl:value-of select="'Update error'"/>
                                    </h2>
                                </xsl:when>
                                <xsl:otherwise>
                                    <h2 class="sml-margin top bottom">
                                        <xsl:value-of select="'Files updated'"/>
                                    </h2>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                            <xsl:if test="m:updated//m:stored">
                                <div class="monospace small">
                                    <ul class="list-unstyled">
                                        <xsl:for-each select="m:updated//m:stored">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </xsl:if>
                            
                            <xsl:if test="m:updated//m:message">
                                <div class="monospace small">
                                    <ul class="list-unstyled">
                                        <xsl:for-each select="m:updated//m:message">
                                            <li>
                                                <xsl:value-of select="."/>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </xsl:if>
                            
                        </div>
                    </div>
                </xsl:when>
                
                <xsl:when test="m:result[@id = ('deploy-pull', 'deploy-push')]">
                    <div id="page-alert" class="fixed-footer fix-height collapse in info text-left" role="alert">
                        <xsl:choose>
                            
                            <xsl:when test="m:result[@id eq 'deploy-pull'][@admin-password-correct eq 'false']">
                                
                                <xsl:attribute name="class" select="'fixed-footer fix-height collapse in danger text-left'"/>
                                
                                <div class="container">
                                    <h2 class="sml-margin top bottom">
                                        <xsl:value-of select="'Password incorrect'"/>
                                    </h2>
                                    <div class="monospace small">
                                        <p>
                                            <xsl:value-of select="'The deploy password provided was incorrect'"/>
                                        </p>
                                    </div>
                                </div>
                                
                            </xsl:when>
                            
                            <xsl:otherwise>
                                
                                <div class="container">
                                    <h2 class="sml-margin top bottom">
                                        <xsl:value-of select="'Files updated'"/>
                                    </h2>
                                    <div class="monospace small">
                                        <xsl:for-each select="m:result//execution">
                                            <p>
                                                <xsl:for-each select="stdout/line">
                                                    <xsl:value-of select="text()"/>
                                                    <br/>
                                                </xsl:for-each>
                                            </p>
                                        </xsl:for-each>
                                    </div>
                                </div>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </div>
                </xsl:when>
                
            </xsl:choose>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translations | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Translations'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                    <xsl:with-param name="page-alert" select="$page-alert"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:function name="m:date-user-string">
        <xsl:param name="action-text" as="xs:string" required="yes"/>
        <xsl:param name="date-time" as="xs:dateTime" required="yes"/>
        <xsl:param name="user-name" as="xs:string" required="yes"/>
        <xsl:value-of select="concat($action-text, ' at ', format-dateTime($date-time, '[H01]:[m01] on [FNn,*-3], [D1o] [MNn,*-3] [Y01]'), ' by ', $user-name)"/>
    </xsl:function>
    
    <!--
    <xsl:function name="m:store-link">
        <xsl:param name="store-file" as="xs:string" required="yes"/>
        <xsl:param name="page-filter" as="xs:string?"/>
        <xsl:param name="toh-min" as="xs:string?"/>
        <xsl:param name="toh-max" as="xs:string?"/>
        <xsl:param name="text-id" as="xs:string?"/>
        <xsl:value-of select="concat('/translations.html?store[]=', ($store-file, '')[1], '&amp;page-filter=', ($page-filter, '')[1], '&amp;toh-min=', ($toh-min, '')[1], '&amp;toh-max=', ($toh-max, '')[1], '#', ($text-id, '')[1])"/>
    </xsl:function>-->
    
</xsl:stylesheet>