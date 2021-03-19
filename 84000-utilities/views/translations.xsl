<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:key name="master-texts" match="/m:response/m:translations-master//m:text" use="@id"/>
    <xsl:key name="master-downloads" match="/m:response/m:translations-master//m:text/m:downloads" use="@resource-id"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="reading-room-no-cache-path" select="$environment/m:url[@id eq 'reading-room-no-cache']/text()"/>
        <xsl:variable name="texts-status" select="/m:response/m:request/m:parameter[@name eq 'texts-status']/text()"/>
        <xsl:variable name="diff" select="not($texts-status) or $texts-status eq 'diff'"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                
                <form action="/translations.html" method="post" class="form-horizontal filter-form">
                    
                    <div class="center-vertical full-width bottom-margin">
                        
                        <!-- Select a status -->
                        <div>
                            <select name="texts-status" id="texts-status" class="form-control">
                                <!-- If it's a client then add an option to view different files -->
                                <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                    <option value="diff">
                                        <xsl:if test="$diff">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="'Texts where there is a new version of the TEI'"/>
                                    </option>
                                </xsl:if>
                                <xsl:for-each select="m:text-statuses/m:status[not(@status-id eq '0')]">
                                    <option>
                                        <xsl:attribute name="value" select="@status-id"/>
                                        <xsl:if test="@status-id eq $texts-status">
                                            <xsl:attribute name="selected" select="'selected'"/>
                                        </xsl:if>
                                        <xsl:value-of select="concat(@status-id, ' / ', text())"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        
                        <!-- Refresh button -->
                        <div>
                            <button class="btn btn-default" type="submit">
                                <i class="fa fa-refresh"/>
                            </button>
                        </div>
                        
                        <!-- Show count of texts -->
                        <div>
                            <span class="badge badge-notification">
                                <xsl:value-of select="fn:format-number(count(distinct-values(m:texts/m:text/@id)),'#,##0')"/>
                            </span>
                            <xsl:value-of select="' texts with this status'"/>
                        </div>
                        
                    </div>
                
                </form>
                
                <xsl:choose>
                    
                    <xsl:when test="count(m:texts/m:text) gt 0">
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
                                    <xsl:variable name="group-toh" select="m:toh[1]"/>
                                    <xsl:variable name="group-titles" select="m:titles[1]"/>
                                    <xsl:variable name="group-tei-version" select="m:downloads[1]/@tei-version"/>
                                    <xsl:variable name="group-master-first-text" select="key('master-texts', $text-id)[1]"/>
                                    <xsl:variable name="group-master-tei-version" select="$group-master-first-text/m:downloads[1]/@tei-version"/>
                                    <xsl:variable name="group-master-status-updates" select="$group-master-first-text/m:status-updates[1]"/>
                                    <xsl:variable name="group-master-status-id" select="$group-master-first-text/@translation-status"/>
                                    <xsl:variable name="text-marked-up" select="/m:response/m:text-statuses/m:status[@status-id eq $group-status-id][@marked-up eq 'true']"/>
                                    
                                    <xsl:variable name="tei-options">
                                        <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                            <xsl:choose>
                                                
                                                <!-- If outdated then offer to get from master -->
                                                <xsl:when test="($group-master-tei-version gt '' and not(compare($group-master-tei-version, $group-tei-version) eq 0)) or (not(compare($group-status-id, $group-master-status-id) eq 0))">
                                                    <a class="store-file">
                                                        <xsl:attribute name="href" select="concat('/translations.html?store=', $text-id, '.tei', if($texts-status) then concat('&amp;texts-status=', $texts-status) else '', '#', $text-id)"/>
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
                                                                    <xsl:if test="not($file-version eq 'none')">
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
                                                                        <xsl:if test="$group-tei-version gt '' and $file-format = ('pdf', 'epub', 'azw3', 'rdf') and not(compare($file-version, $group-tei-version) eq 0) and $text-marked-up">
                                                                            <a class="store-file">
                                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, if($texts-status) then concat('&amp;texts-status=', $texts-status) else '', '#', $text-id)"/>
                                                                                <xsl:attribute name="title" select="'Update this file'"/>
                                                                                <xsl:attribute name="data-loading" select="'Updating this file...'"/>
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
                                                                                    <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, if($texts-status) then concat('&amp;texts-status=', $texts-status) else '', '#', $text-id)"/>
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
                                            <div>
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
                                            
                                            <!-- Links -->
                                            <ul class="list-inline inline-dots sml-margin bottom">
                                                <xsl:if test="$reading-room-no-cache-path">
                                                    <li>
                                                        <a class="small">
                                                            <xsl:attribute name="href" select="concat($reading-room-no-cache-path ,'/translation/', m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                            <xsl:attribute name="title" select="'View this text by-passing the cache'"/>
                                                            <xsl:value-of select="'bypass cache'"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', m:toh/@key, '.html?view-mode=editor')"/>
                                                        <xsl:attribute name="target" select="concat(m:toh/@key, '.html')"/>
                                                        <xsl:attribute name="title" select="'View this text in editor mode'"/>
                                                        <xsl:value-of select="'editor mode'"/>
                                                    </a>
                                                </li>
                                                <!--<li>
                                                <a class="small">
                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text-id, '.html?view-mode=annotation')"/>
                                                    <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                    <xsl:attribute name="title" select="'View this text in annotation mode'"/>
                                                    <xsl:value-of select="'annotation mode'"/>
                                                </a>
                                            </li>-->
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.xml')"/>
                                                        <xsl:attribute name="target" select="concat(m:toh/@key, '.xml')"/>
                                                        <xsl:attribute name="title" select="'View xml data'"/>
                                                        <xsl:value-of select="'xml'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat('/test-translations.html?translation-id=', $text-id)"/>
                                                        <xsl:attribute name="target" select="concat('test-translation-', $text-id)"/>
                                                        <xsl:attribute name="title" select="'Run automated tests on this text'"/>
                                                        <xsl:value-of select="'run tests'"/>
                                                    </a>
                                                </li>
                                                <xsl:for-each select="current-group()">
                                                    <li>
                                                        <a class="small">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.rdf')"/>
                                                            <xsl:attribute name="target" select="concat(m:toh/@key, '.rdf')"/>
                                                            <xsl:attribute name="title" select="concat('Dynamic rdf data for ', m:toh/@key)"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '.rdf')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                <xsl:for-each select="current-group()">
                                                    <li>
                                                        <a class="small">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '-en.txt')"/>
                                                            <xsl:attribute name="title" select="'Download translation as a text file'"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '-en.txt')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                                <xsl:for-each select="current-group()">
                                                    <li>
                                                        <a class="small">
                                                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', m:toh/@key, '-bo.txt')"/>
                                                            <xsl:attribute name="title" select="'Download the source as a text file'"/>
                                                            <xsl:value-of select="concat(m:toh/@key, '-bo.txt')"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                            
                                            <!-- Location of tei file -->
                                            <div class="small text-muted sml-margin bottom">
                                                <xsl:value-of select="'TEI file: '"/>
                                                <a class="break">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                                    <xsl:attribute name="target" select="concat($text-id, '.tei')"/>
                                                    <xsl:attribute name="title" select="@uri"/>
                                                    <xsl:value-of select="@uri"/>
                                                </a>
                                            </div>
                                            
                                            <!-- Version update message -->
                                            <div class="small italic text-danger">
                                                <xsl:choose>
                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client'] and $group-master-status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][text()]">
                                                        <xsl:value-of select="concat('Master TEI: ', $group-master-tei-version, ' - ', $group-master-status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][1])"/>
                                                    </xsl:when>
                                                    <xsl:when test="$environment/m:store-conf[@type eq 'master'] and m:status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][text()]">
                                                        <xsl:value-of select="concat('Version note: ', m:status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][1])"/>
                                                    </xsl:when>
                                                </xsl:choose>
                                            </div>
                                            
                                        </td>
                                        
                                        <td rowspan="2">
                                            
                                            <!-- Local version -->
                                            <div class="small nowrap">
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
                                                <div class="small nowrap">
                                                    <xsl:value-of select="concat('Master: ', $group-master-tei-version)"/>
                                                </div>
                                            </xsl:if>
                                            
                                            
                                            <!-- Status change -->
                                            <xsl:if test="$environment/m:store-conf[@type eq 'client'] and ($diff or not(compare($group-status-id, $group-master-status-id) eq 0))">
                                                <div class="row sml-margin bottom">
                                                    <div class="col-sm-12">
                                                        <div class="center-vertical align-left">
                                                            <span>
                                                                <span class="label label-warning">
                                                                    <xsl:if test="$group-status-id eq '1'">
                                                                        <xsl:attribute name="class" select="'label label-success'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="$group-status-id"/>
                                                                </span>
                                                            </span>
                                                            <xsl:if test="not(compare($group-status-id, $group-master-status-id) eq 0)">
                                                                <span>
                                                                    <i class="fa fa-angle-right"/>
                                                                </span>
                                                                <span>
                                                                    <span class="label label-warning">
                                                                        <xsl:if test="$group-master-status-id eq '1'">
                                                                            <xsl:attribute name="class" select="'label label-success'"/>
                                                                        </xsl:if>
                                                                        <xsl:value-of select="$group-master-status-id"/>
                                                                    </span>
                                                                </span>
                                                            </xsl:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </xsl:if>
                                            
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
                                                            <xsl:attribute name="href" select="concat('/translations.html?store=', $text-id, '.all', if($texts-status) then concat('&amp;texts-status=', $texts-status) else '', '#', $text-id)"/>
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
                    
                    <xsl:otherwise>
                        <hr/>
                        <div>
                            <p class="text-muted italic">
                                <xsl:value-of select="'No texts with this status'"/>
                            </p>
                        </div>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </div>
        </xsl:variable>
        
        <xsl:variable name="page-alert">
            <xsl:if test="m:updated">
                <div id="page-alert" class="collapse in info" role="alert">
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
                            <ul class="list-inline inline-dots">
                                <xsl:for-each select="m:updated//m:stored">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:if>
                        
                        <xsl:if test="m:updated//m:message">
                            <ul class="list-inline inline-dots">
                                <xsl:for-each select="m:updated//m:message">
                                    <li>
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
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
    
</xsl:stylesheet>