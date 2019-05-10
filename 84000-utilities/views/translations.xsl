<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="reading-room-no-cache-path" select="$environment/m:url[@id eq 'reading-room-no-cache']/text()"/>
        <xsl:variable name="texts-status" select="/m:response/m:translations/m:text-status[1]/@id"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <span class="title">
                            <xsl:value-of select="'84000 Utilities'"/>
                        </span>
                        
                        <span class="text-right">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                <xsl:value-of select="'Reading Room'"/>
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <div class="row">
                                
                                <div class="col-sm-7">
                                    <form action="translations.html" method="post" class="form-horizontal filter-form sml-margin top">
                                        <select name="texts-status" id="texts-status" class="form-control">
                                            <xsl:for-each select="m:text-statuses/m:status">
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
                                <div class="col-sm-5">
                                    <div class="alert alert-info">
                                        <p class="small">
                                            <xsl:value-of select="'Lists the status of current translations and related files.'"/>
                                        </p>
                                    </div>
                                </div>
                            </div>
                            
                            <xsl:if test="m:updated">
                                <div class="alert alert-success" role="alert">
                                    <xsl:if test="m:updated//m:error">
                                        <xsl:attribute name="class" select="'alert alert-danger'"/>
                                    </xsl:if>
                                    <xsl:value-of select="concat('Updated: ', m:updated)"/>
                                    <xsl:if test="m:updated/@resource-id">
                                        <xsl:value-of select="' | '"/>
                                        <a class="scroll-to-anchor alert-link">
                                            <xsl:attribute name="href" select="concat('#', m:updated/@resource-id)"/>
                                            <xsl:value-of select="'Go to this row'"/>
                                        </a>
                                    </xsl:if>
                                </div>
                            </xsl:if>
                            
                            <table class="table table-responsive">
                                <thead>
                                    <tr>
                                        <th>
                                            <xsl:value-of select="'Toh.'"/>
                                        </th>
                                        <th>
                                            <xsl:value-of select="'Title'"/>
                                        </th>
                                        <th>
                                            <xsl:value-of select="'Stats'"/>
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="m:translations/m:translation">
                                        <xsl:sort select="number(m:toh/@number)"/>
                                        <xsl:sort select="m:toh/m:base"/>
                                        <xsl:variable name="toh" select="m:toh"/>
                                        <xsl:variable name="tei-version" select="m:downloads/@tei-version"/>
                                        <xsl:variable name="text-downloads" select="m:downloads/m:download"/>
                                        <xsl:variable name="text-id" select="@id"/>
                                        <xsl:variable name="status-id" select="@status-id"/>
                                        
                                        <!-- Translation title -->
                                        <tr>
                                            <xsl:attribute name="id" select="$toh/@key"/>
                                            <td>
                                                <xsl:value-of select="m:toh/m:base"/>
                                            </td>
                                            <td>
                                                <div>
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $toh/@key, '.html')"/>
                                                        <xsl:attribute name="target" select="concat($toh/@key, '.html')"/>
                                                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                                    </a>
                                                    <xsl:if test="$reading-room-no-cache-path">
                                                        <xsl:value-of select="' / '"/>
                                                        <a class="small">
                                                            <xsl:attribute name="href" select="concat($reading-room-no-cache-path ,'/translation/', $toh/@key, '.html')"/>
                                                            <xsl:attribute name="target" select="concat($toh/@key, '.html')"/>
                                                            <xsl:value-of select="'bypass cache'"/>
                                                        </a>
                                                    </xsl:if>
                                                    <xsl:value-of select="' / '"/>
                                                    <a class="small">
                                                        <xsl:attribute name="href" select="concat('/test-translations.html?translation-id=', $text-id)"/>
                                                        <xsl:attribute name="target" select="concat('test-translation-', $text-id)"/>
                                                        <xsl:value-of select="'run tests'"/>
                                                    </a>
                                                </div>
                                                <div class="small text-muted">
                                                    <xsl:value-of select="@uri"/>
                                                </div>
                                            </td>
                                            <td rowspan="2" class="nowrap">
                                                
                                                <div>
                                                    <xsl:value-of select="$text-id"/>
                                                    <div class="label label-warning pull-right">
                                                        <xsl:if test="$status-id eq '1'">
                                                            <xsl:attribute name="class" select="'label label-success pull-right'"/>
                                                        </xsl:if>
                                                        <xsl:value-of select="$status-id"/>
                                                    </div>
                                                </div>
                                                <div class="row sml-margin top">
                                                    <div class="col-sm-6">                                                
                                                        <span class="text-muted small nowrap">
                                                            <xsl:value-of select="'Translated words:'"/>
                                                        </span>
                                                        <br/>
                                                        <xsl:value-of select="fn:format-number(xs:integer(@wordCount),'#,##0')"/>
                                                    </div>
                                                    <div class="col-sm-6">      
                                                        <span class="text-muted small nowrap">
                                                            <xsl:value-of select="'Glossary items:'"/>
                                                        </span>
                                                        <br/>
                                                        <xsl:value-of select="fn:format-number(xs:integer(@glossaryCount),'#,##0')"/>
                                                    </div>
                                                </div>
                                                
                                            </td>
                                        </tr>
                                        
                                        <!-- Files status -->
                                        <tr class="sub">
                                            <td/>
                                            <td>
                                                <xsl:variable name="master-downloads" select="/m:response/m:translations-master/m:translations/m:translation/m:downloads[@resource-id eq $toh/@key]"/>
                                                <xsl:variable name="file-formats" select="('pdf', 'epub', 'azw3')"/>
                                                <div class="small">
                                                    <div class="row">
                                                        
                                                        <!-- Location column -->
                                                        <div class="col-sm-2 text-muted">
                                                            <xsl:value-of select="'File:'"/>
                                                        </div>
                                                        
                                                        <!-- TEI column -->
                                                        <div class="col-sm-2">
                                                            <a class="underline">
                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                                                <xsl:attribute name="target" select="concat($text-id, '.tei')"/>
                                                                <xsl:attribute name="title" select="@uri"/>
                                                                <xsl:value-of select="'TEI'"/>
                                                            </a>
                                                        </div>
                                                        
                                                        <!-- File format columns -->
                                                        <xsl:for-each select="$file-formats">
                                                            <xsl:variable name="file-format" select="."/>
                                                            <xsl:variable name="file-version" select="$text-downloads[@type eq $file-format]/@version"/>
                                                            <div class="col-sm-2">
                                                                <a href="#" class="disabled">
                                                                    <xsl:if test="$file-version ne 'none'">
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/data/', $toh/@key, '.', $file-format)"/>
                                                                        <xsl:attribute name="class" select="'underline'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="upper-case($file-format)"/>
                                                                </a>
                                                            </div>
                                                        </xsl:for-each>
                                                        
                                                    </div>
                                                    
                                                    <!-- Version row -->
                                                    <div class="row">
                                                        
                                                        <!-- Location column -->
                                                        <div class="col-sm-2 text-muted">
                                                            <xsl:choose>
                                                                <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                    <xsl:value-of select="'Local version:'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="'File version:'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            
                                                        </div>
                                                        
                                                        
                                                        <!-- TEI column -->
                                                        <div class="col-sm-2">
                                                            <xsl:value-of select="$tei-version"/>
                                                        </div>
                                                        
                                                        <!-- File format columns -->
                                                        <xsl:for-each select="$file-formats">
                                                            <xsl:variable name="file-format" select="."/>
                                                            <div class="col-sm-2">
                                                                <xsl:value-of select="$text-downloads[@type eq $file-format]/@version"/>
                                                            </div>
                                                        </xsl:for-each>
                                                        
                                                    </div>
                                                    
                                                    <!-- Master version row (not if master) -->
                                                    <xsl:if test="$environment/m:store-conf[@type eq 'client']">
                                                        <div class="row">
                                                            
                                                            <!-- Location column -->
                                                            <div class="col-sm-2 text-muted">
                                                                <xsl:value-of select="'Collaboration:'"/>
                                                            </div>
                                                            
                                                            <!-- TEI column -->
                                                            <div class="col-sm-2">
                                                                <xsl:value-of select="$master-downloads/@tei-version"/>
                                                            </div>
                                                            
                                                            <!-- File format columns -->
                                                            <xsl:for-each select="$file-formats">
                                                                <xsl:variable name="file-format" select="."/>
                                                                <div class="col-sm-2">
                                                                    <xsl:value-of select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                                                </div>
                                                            </xsl:for-each>
                                                        </div>
                                                    </xsl:if>
                                                    
                                                    <!-- Action row -->
                                                    <div class="row">
                                                        
                                                        <xsl:choose>
                                                            <xsl:when test="$environment/m:store-conf[@type eq 'master']">
                                                                
                                                                <!-- Location column -->
                                                                <div class="col-sm-2"/>
                                                                
                                                                <!-- TEI column -->
                                                                <div class="col-sm-2"/>
                                                                
                                                                <!-- File format columns -->
                                                                <xsl:for-each select="$file-formats">
                                                                    
                                                                    <xsl:variable name="file-format" select="."/>
                                                                    <xsl:variable name="file-version" select="$text-downloads[@type eq $file-format]/@version"/>
                                                                    
                                                                    <div class="col-sm-2">
                                                                        
                                                                        <!-- Versions don't match so offer create option -->
                                                                        <xsl:if test="compare($file-version, $tei-version) ne 0 and $tei-version gt ''">
                                                                            <a>
                                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, '&amp;texts-status=', $texts-status)"/>
                                                                                <xsl:attribute name="title" select="'Create this file'"/>
                                                                                <span class="label label-warning">
                                                                                    <xsl:value-of select="concat('Create ', upper-case($file-format))"/>
                                                                                </span>
                                                                            </a>
                                                                        </xsl:if>
                                                                        
                                                                    </div>
                                                                </xsl:for-each>
                                                                
                                                            </xsl:when>
                                                            
                                                            <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                
                                                                <!-- Location column -->
                                                                <div class="col-sm-2"/>
                                                                
                                                                <!-- TEI column -->
                                                                <div class="col-sm-2">
                                                                    <xsl:choose>
                                                                        
                                                                        <!-- If outdated then offer to get from master -->
                                                                        <xsl:when test="compare($master-downloads/@tei-version, $tei-version) ne 0">
                                                                            <a>
                                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.tei', '&amp;texts-status=', $texts-status)"/>
                                                                                <span class="label label-danger">
                                                                                    <xsl:value-of select="concat('Get ', $master-downloads/@tei-version)"/>
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
                                                                </div>
                                                                
                                                                <!-- File format columns -->
                                                                <xsl:for-each select="$file-formats">
                                                                    
                                                                    <xsl:variable name="file-format" select="."/>
                                                                    <xsl:variable name="file-version" select="$text-downloads[@type eq $file-format]/@version"/>
                                                                    <xsl:variable name="master-file-version" select="$master-downloads/m:download[@type eq $file-format]/@version"/>
                                                                    
                                                                    <div class="col-sm-2">
                                                                        <xsl:choose>
                                                                            
                                                                            <!-- If master is outdated then just warn -->
                                                                            <xsl:when test="compare($master-file-version, $master-downloads/@tei-version) ne 0">
                                                                                <span class="label label-info">
                                                                                    <xsl:value-of select="'Update collaboration'"/>
                                                                                </span>
                                                                            </xsl:when>
                                                                            
                                                                            <!-- If outdated then offer to get from master -->
                                                                            <xsl:when test="compare($file-version, $master-downloads/@tei-version) ne 0">
                                                                                <a>
                                                                                    <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, '&amp;texts-status=', $texts-status)"/>
                                                                                    <xsl:attribute name="title" select="'Update this file'"/>
                                                                                    <span class="label label-danger">
                                                                                        <xsl:value-of select="concat('Get ', $master-downloads/@tei-version)"/>
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
                                                                    </div>
                                                                </xsl:for-each>
                                                                
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </div>
                                                </div>
                                                
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <td/>
                                        <td>
                                            <small class="text-muted">
                                                <xsl:value-of select="'Texts: '"/>
                                            </small>
                                            <xsl:value-of select="fn:format-number(xs:integer(count(m:translations/m:translation)),'#,##0')"/>
                                        </td>
                                        <td>
                                            <div class="row">
                                                <div class="col-sm-6">
                                                    <small class="text-muted">
                                                        <xsl:value-of select="'Total words: '"/>
                                                    </small>
                                                    <br/>
                                                    <xsl:value-of select="fn:format-number(xs:integer(sum(m:translations/m:translation/@wordCount)),'#,##0')"/>
                                                </div>
                                                <div class="col-sm-6">
                                                    <small class="text-muted">
                                                        <xsl:value-of select="'Total terms: '"/>
                                                    </small>
                                                    <br/>
                                                    <xsl:value-of select="fn:format-number(xs:integer(sum(m:translations/m:translation/@glossaryCount)),'#,##0')"/>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Link to top of page -->
            <div class="hidden-print">
                <div id="link-to-top-container" class="fixed-btn-container">
                    <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                        <i class="fa fa-arrow-up" aria-hidden="true"/>
                    </a>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translations | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Translations'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:function name="m:date-user-string">
        <xsl:param name="action-text" as="xs:string" required="yes"/>
        <xsl:param name="date-time" as="xs:dateTime" required="yes"/>
        <xsl:param name="user-name" as="xs:string" required="yes"/>
        <xsl:value-of select="concat($action-text, ' at ', format-dateTime($date-time, '[H01]:[m01] on [FNn,*-3], [D1o] [MNn,*-3] [Y01]'), ' by ', $user-name)"/>
    </xsl:function>
    
</xsl:stylesheet>