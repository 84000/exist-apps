<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="reading-room-no-cache-path" select="$environment/m:url[@id eq 'reading-room-no-cache']/text()"/>
        <xsl:variable name="texts-status" select="/m:response/m:request/m:parameter[@name eq 'texts-status']/text()"/>
        <xsl:variable name="diff" select="not($texts-status) or $texts-status eq 'diff'"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="center-vertical align-left full-width bottom-margin">
                    
                    <div>
                        <form action="translations.html" method="post" class="form-horizontal filter-form sml-margin top">
                            
                            <!-- Which files to show? -->
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
                            
                        </form>
                    </div>
                    
                    <div>
                        <span class="badge badge-notification">
                            <xsl:value-of select="fn:format-number(count(distinct-values(m:texts/m:text/@id)),'#,##0')"/>
                        </span>
                        <xsl:value-of select="' texts with this status'"/>
                    </div>
                    
                </div>
                
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
                                    <xsl:variable name="group-master-first-text" select="/m:response/m:translations-master//m:text[@id eq $text-id][1]"/>
                                    <xsl:variable name="group-master-tei-version" select="$group-master-first-text/m:downloads[1]/@tei-version"/>
                                    <xsl:variable name="group-master-status-updates" select="$group-master-first-text/m:status-updates[1]"/>
                                    <xsl:variable name="group-master-status-id" select="$group-master-first-text/@translation-status"/>
                                    <xsl:variable name="text-marked-up" select="/m:response/m:text-statuses/m:status[@status-id eq $group-status-id][@marked-up eq 'true']"/>
                                    
                                    <xsl:variable name="text-links">
                                        <ul class="list-inline inline-dots sml-margin bottom">
                                            <xsl:if test="$reading-room-no-cache-path">
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-no-cache-path ,'/translation/', $text-id, '.html')"/>
                                                        <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                        <xsl:attribute name="title" select="'View this text by-passing the cache'"/>
                                                        <xsl:value-of select="'bypass cache'"/>
                                                    </a>
                                                </li>
                                            </xsl:if>
                                            <li>
                                                <a class="small">
                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text-id, '.html?view-mode=editor')"/>
                                                    <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                    <xsl:attribute name="title" select="'View this text in editor mode'"/>
                                                    <xsl:value-of select="'editor mode'"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a class="small">
                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.xml')"/>
                                                    <xsl:attribute name="target" select="concat($text-id, '.xml')"/>
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
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', m:toh/@key, '.en.txt')"/>
                                                        <xsl:attribute name="title" select="'Download translation as a text file'"/>
                                                        <xsl:value-of select="concat(m:toh/@key, '.en.txt')"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                            <xsl:for-each select="current-group()">
                                                <li>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/source/', m:toh/@key, '.bo.txt')"/>
                                                        <xsl:attribute name="title" select="'Download the source as a text file'"/>
                                                        <xsl:value-of select="concat(m:toh/@key, '.bo.txt')"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:variable>
                                    
                                    <xsl:variable name="tei-options">
                                        <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                            <div class="sml-margin bottom">
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
                                            </div>
                                        </xsl:if>
                                    </xsl:variable>
                                    
                                    <xsl:variable name="file-options">
                                        <div class="row">
                                            
                                            <!--<!-\- Titles column -\->
                                            <div class="col-sm-4">
                                                
                                                <!-\- Title / Link -\->
                                                <div class="small text-muted">
                                                    <xsl:value-of select="'File'"/>
                                                </div>
                                                
                                                <!-\- Local version -\->
                                                <div class="small text-muted">
                                                    <xsl:choose>
                                                        <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                            <xsl:value-of select="'Local version:'"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="'File version:'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                                
                                                <!-\- Master version -\->
                                                <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                    <div class="small text-muted">
                                                        <xsl:value-of select="'Collaboration'"/>
                                                    </div>
                                                </xsl:if>
                                                
                                            </div>-->
                                            
                                            <xsl:variable name="file-formats" select="('pdf', 'epub', 'azw3', 'rdf')"/>
                                            <xsl:for-each select="$file-formats">
                                                
                                                <xsl:variable name="file-format" select="."/>
                                                
                                                <div class="col-sm-3">
                                                    
                                                    <xsl:for-each select="current-group()">
                                                        
                                                        <xsl:variable name="toh" select="m:toh"/>
                                                        <xsl:variable name="text-downloads" select="m:downloads/m:download"/>
                                                        <xsl:variable name="file-version" select="$text-downloads[@type eq $file-format]/@version"/>
                                                        <xsl:variable name="master-downloads" select="/m:response/m:translations-master//m:text/m:downloads[@resource-id eq $toh/@key]"/>
                                                        <xsl:variable name="master-file-version" select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                                        
                                                        <!-- Title / Link -->
                                                        <div>
                                                            <a href="#" class="small disabled underline">
                                                                <xsl:if test="not($file-version eq 'none')">
                                                                    <xsl:attribute name="href" select="concat($reading-room-path, '/data/', $toh/@key, '.', $file-format)"/>
                                                                    <xsl:attribute name="class" select="'small underline'"/>
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
                                                                    <xsl:if test="$group-tei-version gt '' and not(compare($file-version, $group-tei-version) eq 0) and $text-marked-up">
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
                                                                            <span class="label label-default">
                                                                                <xsl:value-of select="'Update collaboration'"/>
                                                                            </span>
                                                                        </xsl:when>
                                                                        
                                                                        <!-- If outdated then offer to get from master -->
                                                                        <xsl:when test="not(compare($file-version, $master-downloads/@tei-version) eq 0)">
                                                                            <a class="store-file">
                                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, if($texts-status) then concat('&amp;texts-status=', $texts-status) else '', '#', $text-id)"/>
                                                                                <xsl:attribute name="title" select="'Get updated file'"/>
                                                                                <xsl:attribute name="data-loading" select="'Getting updated file...'"/>
                                                                                <span class="label label-primary">
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
                                                        <br class="small"/>
                                                        
                                                    </xsl:for-each>
                                                    
                                                </div>
                                                
                                            </xsl:for-each>
                                            
                                        </div>
                                    </xsl:variable>
                                    
                                    <!-- Translation title -->
                                    <tr>
                                        <xsl:attribute name="id" select="$text-id"/>
                                        <td class="sml-margin top">
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
                                        <td>
                                            
                                            <div class="row">
                                                
                                                <xsl:variable name="status-change">
                                                    <!-- Show if it's a status change -->
                                                    <xsl:if test="$environment/m:store-conf[@type eq 'client'] and ($diff or not(compare($group-status-id, $group-master-status-id) eq 0))">
                                                        <div class="center-vertical align-right">
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
                                                    </xsl:if>
                                                </xsl:variable>
                                                
                                                <div class="col-sm-10">
                                                    <xsl:if test="$status-change">
                                                        <xsl:attribute name="class" select="'col-sm-8'"/>
                                                    </xsl:if>
                                                    
                                                    <!-- Title -->
                                                    <div>
                                                        <a class="sml-margin top break">
                                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $text-id, '.html')"/>
                                                            <xsl:attribute name="target" select="concat($text-id, '.html')"/>
                                                            <xsl:attribute name="title" select="'View this text in the Reading Room'"/>
                                                            <xsl:value-of select="$group-titles/m:title[@xml:lang eq 'en']"/>
                                                            <small>
                                                                <xsl:value-of select="concat(' / ', $text-id)"/>
                                                            </small>
                                                        </a>
                                                    </div>
                                                    
                                                    <!-- Links -->
                                                    <xsl:copy-of select="$text-links"/>
                                                    
                                                </div>
                                                
                                                
                                                <!-- Change of status -->
                                                <xsl:if test="$status-change">
                                                    <div class="col-sm-2 sml-margin top">
                                                        <xsl:copy-of select="$status-change"/>
                                                    </div>
                                                </xsl:if>
                                                
                                                <!-- Update all -->
                                                <div class="col-sm-2">
                                                    <a href="#" class="btn btn-info btn-sm disabled">
                                                        <xsl:choose>
                                                            <xsl:when test="$file-options//xhtml:a[@class eq 'store-file'] | $tei-options//xhtml:a[@class eq 'store-file']">
                                                                <xsl:attribute name="class" select="'btn btn-danger btn-sm'"/>
                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $text-id, '.all', if($texts-status) then concat('&amp;texts-status=', $texts-status) else '', '#', $text-id)"/>
                                                                <xsl:choose>
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                        <xsl:attribute name="data-loading" select="'Getting updated files...'"/>
                                                                        <xsl:value-of select="'Get updated files'"/>
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
                                                
                                            </div>
                                            
                                            <div class="row sml-margin bottom small">
                                                
                                                <!-- Location of tei file -->
                                                <div class="col-sm-10 text-muted">
                                                    <xsl:value-of select="'TEI file: '"/>
                                                    <a class="break">
                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                                        <xsl:attribute name="target" select="concat($text-id, '.tei')"/>
                                                        <xsl:attribute name="title" select="@uri"/>
                                                        <xsl:value-of select="@uri"/>
                                                    </a>
                                                </div>
                                                
                                                <!-- Local version -->
                                                <div class="col-sm-2">
                                                    <xsl:choose>
                                                        <xsl:when test="$group-tei-version gt ''">
                                                            <xsl:value-of select="concat('Version: ', $group-tei-version)"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:attribute name="class" select="'small text-muted'"/>
                                                            <xsl:value-of select="'[No version]'"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </div>
                                            </div>
                                            
                                            <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                <div class="row sml-margin bottom">
                                                    
                                                    <!-- Master version and version update message -->
                                                    <div class="col-sm-10">
                                                        <div class="small italic text-danger">
                                                            <xsl:value-of select="concat('Collaboration TEI version : ', $group-master-tei-version)"/>
                                                            <xsl:if test="$group-master-status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][text()]">
                                                                <xsl:value-of select="concat(' - ', $group-master-status-updates/m:status-update[@update eq 'text-version'][@current-version eq 'true'][1])"/>
                                                            </xsl:if>
                                                        </div>
                                                    </div>
                                                    
                                                    <!-- Action -->
                                                    <div class="col-sm-2">
                                                        <xsl:copy-of select="$tei-options"/>
                                                    </div>
                                                </div>
                                            </xsl:if>
                                            
                                        </td>
                                    </tr>
                                    
                                    <tr class="sub">
                                        <td/>
                                        <td>
                                            <xsl:copy-of select="$file-options"/>
                                        </td>
                                    </tr>
                                    
                                </xsl:for-each-group>
                            </tbody>
                            
                        </table>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <p class="text-muted italic">
                            <xsl:value-of select="'No texts with this status'"/>
                        </p>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </div>
        </xsl:variable>
        
        <xsl:variable name="page-alert">
            <xsl:if test="m:updated">
                <div id="page-alert" class="collapse in info" role="alert">
                    <xsl:if test="m:updated//m:error">
                        <xsl:attribute name="class" select="'collapse in danger'"/>
                    </xsl:if>
                    <h2 class="sml-margin top bottom">
                        <xsl:value-of select="'File updated'"/>
                    </h2>
                    <xsl:value-of select="m:updated"/>
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