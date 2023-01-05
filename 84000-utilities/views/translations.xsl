<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:key name="master-texts" match="/m:response/m:translations-master//m:text" use="@id"/>
    <xsl:key name="master-downloads" match="/m:response/m:translations-master//m:text/m:downloads" use="@resource-id"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="reading-room-no-cache-path" select="$environment/m:url[@id eq 'reading-room-no-cache']/text()"/>
        <xsl:variable name="operations-path" select="$environment/m:url[@id eq 'operations']/text()"/>
        <xsl:variable name="page-filter" select="/m:response/m:request/m:parameter[@name eq 'page-filter']/text()"/>
        <xsl:variable name="toh-min" select="/m:response/m:request/m:parameter[@name eq 'toh-min']/text()"/>
        <xsl:variable name="toh-max" select="/m:response/m:request/m:parameter[@name eq 'toh-max']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                
                <!-- Form to specify status -->
                <form action="/translations.html" method="post" class="form-horizontal filter-form clearfix">
                    <xsl:attribute name="data-loading" select="'Loading...'"/>
                    
                    <div class="row bottom-margin">
                        
                        <!-- Select a status -->
                        <div class="col-sm-9">
                            <div class="input-group">
                                <select name="page-filter" id="page-filter" class="form-control">
                                    
                                    <option value="recent-updates">
                                        <xsl:if test="not($page-filter) or $page-filter eq 'recent-updates'">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Recent updates to published texts'"/>
                                    </option>
                                    
                                    <option value="search">
                                        <xsl:if test="$page-filter eq 'search'">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Search for a text'"/>
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
                                    <button class="btn btn-default" type="submit">
                                        <xsl:attribute name="title" select="'reload'"/>
                                        <i class="fa fa-refresh"/>
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-sm-3">
                            <div class="center-vertical full-width">
                                
                                <!-- Show count of texts -->
                                <div>
                                    <div class="sml-margin top">
                                        <span class="badge badge-notification">
                                            <xsl:value-of select="fn:format-number(count(distinct-values(m:texts/m:text/@id | m:recent-updates/m:text/@id)),'#,##0')"/>
                                        </span>
                                        <xsl:value-of select="' results'"/>
                                    </div>
                                </div>
                                
                                <!-- Download button -->
                                <xsl:if test="m:recent-updates[m:text]">
                                    <div>
                                        <a>
                                            <xsl:attribute name="href" select="'translations.xlsx?page-filter=recent-updates'"/>
                                            <xsl:attribute name="title" select="'Download as spreadsheet'"/>
                                            <xsl:attribute name="class" select="'btn btn-default'"/>
                                            <i class="fa fa-cloud-download"/>
                                            <xsl:value-of select="' download'"/>
                                        </a>
                                    </div>
                                </xsl:if>
                                
                            </div>
                            
                        </div>
                        
                    </div>
                
                </form>
                
                <!-- Further forms to filter / update -->
                <xsl:choose>
                    
                    <xsl:when test="$page-filter eq 'search'">
                        <form action="/translations.html" method="post" class="form-inline bottom-margin">
                            <input type="hidden" name="page-filter" value="search"/>
                            <div class="form-group">
                                <label for="toh-min">Tohoku:</label>
                                <input type="number" name="toh-min" class="form-control" id="toh-min" maxlength="5" placeholder="min.">
                                    <xsl:attribute name="value" select="/m:response/m:request/m:parameter[@name eq 'toh-min']/text()"/>
                                </input>
                                <input type="number" name="toh-max" class="form-control" id="toh-max" maxlength="5" placeholder="max.">
                                    <xsl:attribute name="value" select="/m:response/m:request/m:parameter[@name eq 'toh-max']/text()"/>
                                </input>
                                <button type="submit" class="btn btn-primary">Search</button>
                            </div>
                        </form>
                    </xsl:when>
                    
                    <xsl:when test="$page-filter eq 'new-version-placeholders' and m:texts[m:text]">
                        <form action="/translations.html" method="post" class="form-inline bottom-margin">
                            <xsl:attribute name="data-loading" select="'Getting updated files...'"/>
                            <input type="hidden" name="page-filter" value="new-version-placeholders"/>
                            <xsl:for-each-group select="m:texts/m:text" group-by="@id">
                                <input type="hidden" name="store[]" value="{ concat(@id, '.all') }"/>
                            </xsl:for-each-group>
                            <button type="submit" class="btn btn-danger btn-sml">Get all updated placeholder files</button>                            
                        </form>
                    </xsl:when>
                    
                </xsl:choose>
                
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
                                    
                                    <xsl:variable name="text-id" select="@id"/>
                                    <xsl:variable name="group-status-id" select="@status[1]"/>
                                    <xsl:variable name="group-status-group" select="@status-group[1]"/>
                                    <xsl:variable name="group-toh" select="m:toh[1]"/>
                                    <xsl:variable name="group-titles" select="m:titles[1]"/>
                                    <xsl:variable name="group-tei-version" select="m:downloads[1]/@tei-version"/>
                                    <xsl:variable name="group-master-first-text" select="key('master-texts', $text-id)[1]"/>
                                    <xsl:variable name="group-master-tei-version" select="$group-master-first-text/m:downloads[1]/@tei-version"/>
                                    <xsl:variable name="group-master-status-updates" select="$group-master-first-text/m:status-updates[1]"/>
                                    <xsl:variable name="group-master-status-id" select="$group-master-first-text/@translation-status"/>
                                    <xsl:variable name="group-master-status-group" select="/m:response/m:text-statuses/m:status[@status-id eq $group-master-status-id]/@group"/>
                                    <xsl:variable name="text-marked-up" select="/m:response/m:text-statuses/m:status[@status-id eq $group-status-id][@marked-up eq 'true']"/>
                                    
                                    <!-- Tei options -->
                                    <xsl:variable name="tei-options">
                                        <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                            <xsl:choose>
                                                
                                                <!-- If outdated then offer to get from master -->
                                                <xsl:when test="($group-master-tei-version gt '' and not(compare($group-master-tei-version, $group-tei-version) eq 0)) or (not(compare($group-status-id, $group-master-status-id) eq 0))">
                                                    <a class="store-file">
                                                        <xsl:attribute name="href" select="m:store-link(concat($text-id, '.tei'), $page-filter, $toh-min, $toh-max, $text-id)"/>
                                                        <xsl:attribute name="title" select="'Get updated TEI'"/>
                                                        <xsl:attribute name="data-loading" select="'Getting updated TEI...'"/>
                                                        <span class="label label-warning">
                                                            <xsl:value-of select="'Get updated TEI'"/>
                                                        </span>
                                                    </a>
                                                </xsl:when>
                                                
                                                <!-- Up to date -->
                                                <xsl:otherwise>
                                                    <span class="label label-default">
                                                        <xsl:value-of select="'Up to date'"/>
                                                    </span>
                                                </xsl:otherwise>
                                                
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:variable>
                                    
                                    <!-- Associated file options -->
                                    <xsl:variable name="file-options">
                                        <div class="row sml-margin bottom">
                                            
                                            <xsl:variable name="file-formats" select="('pdf', 'epub', 'azw3', 'rdf', 'cache')"/>
                                            
                                            <xsl:for-each select="$file-formats">
                                                
                                                <xsl:variable name="file-format" select="."/>
                                                
                                                <div class="col-sm-2">
                                                    
                                                    <xsl:for-each select="current-group()">
                                                        
                                                        <xsl:variable name="toh" select="m:toh"/>
                                                        <xsl:variable name="text-downloads" select="m:downloads/m:download"/>
                                                        <xsl:variable name="file-version" select="$text-downloads[@type eq $file-format]/@version"/>
                                                        <xsl:variable name="master-downloads" select="key('master-downloads', $toh/@key)"/>
                                                        <xsl:variable name="master-file-version" select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                                        
                                                        <div class="sml-margin bottom">
                                                            
                                                            <!-- Title / Link -->
                                                            <div>
                                                                <a href="#" class="small underline disabled">
                                                                    <xsl:if test="$file-version[not(. eq 'none')]">
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, $text-downloads[@type eq $file-format]/@url)"/>
                                                                        <xsl:attribute name="class" select="'small underline'"/>
                                                                    </xsl:if>
                                                                    <xsl:if test="$text-downloads[@type eq $file-format][not(@download-url)]">
                                                                        <xsl:attribute name="target" select="concat($toh/@key, '.', $file-format)"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="concat($toh/@key, '.', $file-format)"/>
                                                                </a>
                                                            </div>
                                                            
                                                            <!-- Local version -->
                                                            <div class="small">
                                                                <xsl:choose>
                                                                    <xsl:when test="$text-downloads[@type eq $file-format][not(@version = ('none', 'unknown', ''))]/@version">
                                                                        <xsl:value-of select="$text-downloads[@type eq $file-format]/@version"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:attribute name="class" select="'small text-muted'"/>
                                                                        <xsl:value-of select="'[None]'"/>
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
                                                                            <xsl:value-of select="'[None]'"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </div>
                                                            </xsl:if>
                                                            
                                                            <!-- Action -->
                                                            <div>
                                                                <xsl:choose>
                                                                    
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'master']">
                                                                        
                                                                        <!-- Versions don't match so offer create option -->
                                                                        <xsl:if test="$group-tei-version gt '' and $file-format = ('pdf', 'epub', 'azw3', 'rdf', 'cache') and not(compare($file-version, $group-tei-version) eq 0) and $text-marked-up">
                                                                            <xsl:variable name="file-name" select="concat($toh/@key, '.', $file-format)"/>
                                                                            <a class="store-file">
                                                                                <xsl:attribute name="href" select="m:store-link($file-name, $page-filter, $toh-min, $toh-max, $text-id)"/>
                                                                                <xsl:attribute name="title" select="concat('Update ', $file-name)"/>
                                                                                <xsl:attribute name="data-loading" select="concat('Updating ', $file-name, ' ...')"/>
                                                                                <span class="label label-primary">
                                                                                    <xsl:value-of select="concat('Update ', upper-case($file-format))"/>
                                                                                </span>
                                                                            </a>
                                                                        </xsl:if>
                                                                        
                                                                    </xsl:when>
                                                                    
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                        
                                                                        <xsl:choose>
                                                                            
                                                                            <!-- If master is outdated then just warn -->
                                                                            <xsl:when test="not($master-file-version gt '') or not(compare($master-file-version, $master-downloads/@tei-version) eq 0)">
                                                                                <span class="label label-info">
                                                                                    <xsl:value-of select="'Update collaboration'"/>
                                                                                </span>
                                                                            </xsl:when>
                                                                            
                                                                            <!-- If outdated then offer to get from master -->
                                                                            <xsl:when test="not(compare($file-version, $master-downloads/@tei-version) eq 0)">
                                                                                <a class="store-file">
                                                                                    <xsl:attribute name="href" select="m:store-link(concat($toh/@key, '.', $file-format), $page-filter, $toh-min, $toh-max, $text-id)"/>
                                                                                    <xsl:attribute name="title" select="'Get updated file'"/>
                                                                                    <xsl:attribute name="data-loading" select="'Getting updated file...'"/>
                                                                                    <span class="label label-warning">
                                                                                        <xsl:value-of select="concat('Get updated ', upper-case($file-format))"/>
                                                                                    </span>
                                                                                </a>
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
                                    </xsl:variable>
                                    
                                    <tr>
                                        
                                        <xsl:attribute name="id" select="$text-id"/>
                                        
                                        <!-- Toh -->
                                        <td rowspan="2">
                                            <xsl:for-each select="current-group()">
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
                                                    <xsl:value-of select="$group-titles/m:title[@xml:lang eq 'en']"/>
                                                </span>
                                                
                                                <span class="small">
                                                    <xsl:value-of select="' / '"/>
                                                    <xsl:value-of select="concat(m:location[1]/@count-pages, ' pages')"/>
                                                </span>
                                                
                                                <span class="small">
                                                    <xsl:value-of select="' / '"/>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text-id, '.html')"/>
                                                        <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                        <xsl:attribute name="title" select="concat('Open ', $text-id, '.html in the Reading Room')"/>
                                                        <xsl:value-of select="$text-id"/>
                                                    </a>
                                                </span>
                                                
                                                <xsl:for-each select="current-group()">
                                                    <span class="small">
                                                        <xsl:value-of select="' / '"/>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="title" select="concat('Open ', m:toh/@key, '.html in the Reading Room')"/>
                                                            <xsl:value-of select="m:toh/@key"/>
                                                        </a>
                                                    </span>
                                                </xsl:for-each>
                                                
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
                                            
                                            <!-- Locations of other files -->
                                            <div class="small sml-margin bottom">
                                                <ul class="list-inline inline-dots">
                                                    
                                                    <xsl:if test="$reading-room-no-cache-path">
                                                        <li>
                                                            <a>
                                                                <xsl:attribute name="href" select="concat($reading-room-no-cache-path ,'/translation/', m:toh/@key, '.html')"/>
                                                                <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                                <xsl:attribute name="title" select="'View this text by-passing the cache'"/>
                                                                <xsl:value-of select="'bypass cache'"/>
                                                            </a>
                                                        </li>
                                                    </xsl:if>
                                                    
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html?view-mode=editor')"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="title" select="'View this text in editor mode'"/>
                                                            <xsl:value-of select="'editor mode'"/>
                                                        </a>
                                                    </li>
                                                    
                                                    <!--<li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text-id, '.html?view-mode=annotation')"/>
                                                            <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                            <xsl:attribute name="title" select="'View this text in annotation mode'"/>
                                                            <xsl:value-of select="'annotation mode'"/>
                                                        </a>
                                                    </li>-->
                                                    
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat('/test-translations.html?translation-id=', $text-id)"/>
                                                            <xsl:attribute name="target" select="concat('test-translation-', $text-id)"/>
                                                            <xsl:attribute name="title" select="'Run automated tests on this text'"/>
                                                            <xsl:value-of select="'run tests'"/>
                                                        </a>
                                                    </li>
                                                    
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
                                                    
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.xml')"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.xml')"/>
                                                            <xsl:attribute name="title" select="'View xml data'"/>
                                                            <xsl:value-of select="'xml'"/>
                                                        </a>
                                                    </li>
                                                    
                                                    <xsl:for-each select="current-group()">
                                                        <li>
                                                            <a>
                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.rdf')"/>
                                                                <xsl:attribute name="target" select="concat(m:toh/@key, '.rdf')"/>
                                                                <xsl:attribute name="title" select="concat('Dynamic rdf data for ', m:toh/@key)"/>
                                                                <xsl:value-of select="concat(m:toh/@key, '.rdf')"/>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                    
                                                    <xsl:for-each select="current-group()">
                                                        <li>
                                                            <a>
                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '-en.txt')"/>
                                                                <xsl:attribute name="title" select="'Download translation as a text file'"/>
                                                                <xsl:value-of select="concat(m:toh/@key, '-en.txt')"/>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                    
                                                    <xsl:for-each select="current-group()">
                                                        <li>
                                                            <a>
                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/source/', m:toh/@key, '-bo.txt')"/>
                                                                <xsl:attribute name="title" select="'Download the source as a text file'"/>
                                                                <xsl:value-of select="concat(m:toh/@key, '-bo.txt')"/>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                    
                                                </ul>
                                            </div>
                                            
                                            <!-- Alert if file locked -->
                                            <xsl:if test="@locked-by-user gt ''">
                                                <div class="sml-margin bottom">
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="concat('Local TEI file is currenly locked by user ', @locked-by-user)"/>
                                                    </span>
                                                </div>
                                            </xsl:if>
                                            
                                            <!-- Version update message -->
                                            <xsl:variable name="version-update-message" as="xs:string?">
                                                <xsl:choose>
                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client'] and $group-master-status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][text()]">
                                                        <xsl:value-of select="concat('Master TEI: ', $group-master-tei-version, ' - ', $group-master-status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][1])"/>
                                                    </xsl:when>
                                                    <xsl:when test="$environment/m:store-conf[@type eq 'master'] and m:status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][text()]">
                                                        <xsl:value-of select="concat('Version note: ', m:status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][1])"/>
                                                    </xsl:when>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:if test="$version-update-message">
                                                <div class="small">
                                                    <span class="italic text-danger">
                                                        <xsl:value-of select="$version-update-message"/>
                                                    </span>
                                                    <xsl:value-of select="' / '"/>
                                                    <a target="84000-github">
                                                        <xsl:attribute name="href" select="concat('https://github.com/84000/data-tei/commits/master', substring-after(@document-url, concat($environment/@data-path, '/tei')))"/>
                                                        <xsl:value-of select="'Github'"/>
                                                    </a>
                                                </div>
                                            </xsl:if>
                                            
                                            <!-- Alert if file locked -->
                                            <xsl:if test="$environment/m:store-conf[@type eq 'client'] and $group-master-first-text[@locked-by-user gt '']">
                                                <div class="sml-margin top">
                                                    <span class="label label-danger">
                                                        <xsl:value-of select="concat('Master TEI file is currenly locked by user ', $group-master-first-text/@locked-by-user)"/>
                                                    </span>
                                                </div>
                                            </xsl:if>
                                            
                                        </td>
                                        
                                        <td rowspan="2">
                                            
                                            <!-- Local version -->
                                            <div class="small nowrap sml-margin bottom">
                                                <xsl:choose>
                                                    <xsl:when test="$group-tei-version gt ''">
                                                        <xsl:value-of select="concat('Local: ', $group-tei-version)"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="class" select="'small nowrap text-muted'"/>
                                                        <xsl:value-of select="'[No version]'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </div>
                                            
                                            <!-- Collaboration version -->
                                            <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                <div class="small nowrap sml-margin bottom">
                                                    <xsl:value-of select="concat('Master: ', $group-master-tei-version)"/>
                                                </div>
                                            </xsl:if>
                                            
                                            <!-- Status change -->
                                            <div class="row sml-margin bottom">
                                                <div class="col-sm-12">
                                                    <div class="center-vertical align-left">
                                                        <span>
                                                            <span class="label label-warning">
                                                                <xsl:if test="$group-status-group eq 'published'">
                                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="$group-status-id"/>
                                                            </span>
                                                        </span>
                                                        <xsl:if test="$environment/m:store-conf[@type eq 'client'] and not(compare($group-status-id, $group-master-status-id) eq 0)">
                                                            <span>
                                                                <i class="fa fa-angle-right"/>
                                                            </span>
                                                            <span>
                                                                <span class="label label-warning">
                                                                    <xsl:if test="$group-master-status-group eq 'published'">
                                                                        <xsl:attribute name="class" select="'label label-success'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="$group-master-status-id"/>
                                                                </span>
                                                            </span>
                                                        </xsl:if>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <!-- Get TEI -->
                                            <div class="sml-margin bottom">
                                                <xsl:copy-of select="$tei-options"/>
                                            </div>
                                            
                                            <!-- Update all -->
                                            <div>
                                                <a href="#" class="btn btn-info btn-sm disabled">
                                                    <xsl:choose>
                                                        <xsl:when test="$file-options//xhtml:a[@class eq 'store-file'] | $tei-options//xhtml:a[@class eq 'store-file']">
                                                            <xsl:attribute name="class" select="'btn btn-danger btn-sm'"/>
                                                            <xsl:attribute name="href" select="m:store-link(concat($text-id, '.all'), $page-filter, $toh-min, $toh-max, $text-id)"/>
                                                            <xsl:choose>
                                                                <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                    <xsl:attribute name="data-loading" select="'Getting updated files...'"/>
                                                                    <xsl:value-of select="'Get all updated files'"/>
                                                                </xsl:when>
                                                                <xsl:when test="$environment/m:store-conf[@type eq 'master']">
                                                                    <xsl:attribute name="data-loading" select="'Creating new files...'"/>
                                                                    <xsl:value-of select="'Create new versions'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="$environment/m:store-conf/@type"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'Files up to date'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </a>
                                            </div>
                                        
                                        </td>
                                        
                                    </tr>
                                    
                                    <tr class="sub">
                                        
                                        <td>
                                            
                                            <!-- File options -->
                                            <xsl:copy-of select="$file-options"/>
                                            
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
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $toh-key, '.html')"/>
                                                            <xsl:attribute name="target" select="concat($toh-key, '.html')"/>
                                                            <xsl:attribute name="title" select="concat('Open ', $toh-key, '.html in the Reading Room')"/>
                                                            <xsl:value-of select="'Toh ' || string-join(m:toh/m:base, ' / ') || ' (' || @id || ') '"/>
                                                        </a>
                                                    </h4>
                                                    <div class="small">
                                                        <xsl:choose>
                                                            <xsl:when test="$recent-update-type eq 'new-publication'">
                                                                <xsl:for-each select="tei:note[@update eq 'translation-status'][@value = ('1', '1.a')]">
                                                                    <xsl:sort select="@date-time"/>
                                                                    <span class="text-muted">
                                                                        <xsl:value-of select="common:date-user-string('Published', @date-time, @user)"/>
                                                                    </span>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:for-each select="tei:note">
                                                                    <xsl:sort select="@date-time"/>
                                                                    <span class="text-muted">
                                                                        <xsl:value-of select="common:date-user-string(concat('Version ', @value, ' created'), @date-time, @user)"/>
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
                        <p class="text-muted italic">
                            <xsl:value-of select="'No matching texts'"/>
                        </p>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </div>
        
        </xsl:variable>
        
        <xsl:variable name="page-alert">
            <xsl:if test="m:updated">
                <div id="page-alert" class="fixed-footer fix-height collapse in info" role="alert">
                    <div class="container">
                        
                        <xsl:choose>
                            <xsl:when test="m:updated//m:error">
                                <xsl:attribute name="class" select="'collapse in danger'"/>
                                <h2 class="sml-margin top bottom">
                                    <xsl:value-of select="'Update error'"/>
                                </h2>
                            </xsl:when>
                            <xsl:otherwise>
                                <h2 class="sml-margin top bottom">
                                    <xsl:value-of select="'File updated'"/>
                                </h2>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        <xsl:if test="m:updated//m:stored">
                            <div>
                                <ul class="list-inline inline-dots">
                                    <xsl:for-each select="m:updated//m:stored">
                                        <li>
                                            <xsl:value-of select="."/>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="m:updated//m:message">
                            <div>
                                <ul class="list-inline inline-dots">
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
            </xsl:if>
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

    <xsl:function name="m:store-link">
        <xsl:param name="store-file" as="xs:string" required="yes"/>
        <xsl:param name="page-filter" as="xs:string?"/>
        <xsl:param name="toh-min" as="xs:string?"/>
        <xsl:param name="toh-max" as="xs:string?"/>
        <xsl:param name="text-id" as="xs:string?"/>
        <xsl:value-of select="concat('/translations.html?store[]=', ($store-file, '')[1], '&amp;page-filter=', ($page-filter, '')[1], '&amp;toh-min=', ($toh-min, '')[1], '&amp;toh-max=', ($toh-max, '')[1], '#', ($text-id, '')[1])"/>
    </xsl:function>
    
</xsl:stylesheet>