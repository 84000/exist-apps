<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            84000 Utilities
                        </span>
                        
                        <span class="text-right">
                            <a target="reading-room">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                Reading Room
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <xsl:if test="$environment/m:store-conf[@type eq 'master']">
                            <div class="alert alert-danger small text-center" role="alert">
                                Due to an underlying restriction in the database platform only database administrators can generate new versions of eBooks.
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="m:updated">
                            <div class="alert alert-success" role="alert">
                                <xsl:value-of select="m:updated"/>
                            </div>
                        </xsl:if>
                        
                        <div class="tab-content">
                            
                            <table class="table table-responsive">
                                <thead>
                                    <tr>
                                        <th>Toh.</th>
                                        <th>Title</th>
                                        <th colspan="2">Stats</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="//m:translations/m:translation">
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
                                                <a class="text-color">
                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $toh/@key, '.html')"/>
                                                    <xsl:attribute name="target" select="concat($toh/@key, '.html')"/>
                                                    <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                                </a>
                                                <xsl:if test="$environment/m:store-conf[@type eq 'master']">
                                                    <span class="small">
                                                         / 
                                                    </span>
                                                    <a target="_self" class="small">
                                                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', $text-id, '#publication-status-form')"/>
                                                        edit
                                                    </a>
                                                </xsl:if>
                                            </td>
                                            <td colspan="2" class="nowrap">
                                                
                                                <xsl:value-of select="$text-id"/>
                                                
                                                <div class="label label-warning pull-right">
                                                    <xsl:if test="$status-id eq '1'">
                                                        <xsl:attribute name="class" select="'label label-success pull-right'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="$status-id"/>
                                                </div>
                                                
                                            </td>
                                        </tr>
                                        
                                        <!-- Files status -->
                                        <tr class="sub">
                                            <td>
                                            </td>
                                            <td>
                                                
                                                <xsl:variable name="master-text" select="/m:response/m:translations-master/m:texts/m:text[@resource-id eq $toh/@key]"/>
                                                <xsl:variable name="master-tei-version" select="$master-text/m:downloads/@tei-version"/>
                                                <xsl:variable name="master-downloads" select="$master-text/m:downloads/m:download"/>
                                                <xsl:variable name="file-formats" select="('pdf', 'epub', 'azw3')"/>
                                                <div class="small">
                                                    <div class="row">
                                                        
                                                        <!-- Location column -->
                                                        <div class="col-sm-2 text-muted">
                                                            File:
                                                        </div>
                                                        
                                                        <!-- TEI column -->
                                                        <div class="col-sm-2">
                                                            <a class="underline">
                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text-id, '.tei')"/>
                                                                <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                                                <xsl:attribute name="title" select="@uri"/>
                                                                TEI
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
                                                            Version:
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
                                                                Collaboration:
                                                            </div>
                                                            
                                                            <!-- TEI column -->
                                                            <div class="col-sm-2">
                                                                <xsl:value-of select="$master-tei-version"/>
                                                            </div>
                                                            
                                                            <!-- File format columns -->
                                                            <xsl:for-each select="$file-formats">
                                                                <xsl:variable name="file-format" select="."/>
                                                                <div class="col-sm-2">
                                                                    <xsl:value-of select="$master-downloads[@type eq $file-format]/@version"/>
                                                                </div>
                                                            </xsl:for-each>
                                                        </div>
                                                    </xsl:if>
                                                    
                                                    <!-- Action row -->
                                                    <div class="row">
                                                        
                                                        <!-- Location column -->
                                                        <div class="col-sm-2"/>
                                                        
                                                        <!-- TEI column -->
                                                        <div class="col-sm-2">
                                                            <xsl:choose>
                                                                
                                                                <!-- Client actions -->
                                                                <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                    <xsl:choose>
                                                                        
                                                                        <!-- If outdated then offer to get from master -->
                                                                        <xsl:when test="compare($master-tei-version, $tei-version) ne 0">
                                                                            <a>
                                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.tei#', $toh/@key)"/>
                                                                                <span class="label label-success">
                                                                                    <xsl:value-of select="concat('Get ', $master-tei-version)"/>
                                                                                </span>
                                                                            </a>
                                                                        </xsl:when>
                                                                        
                                                                        <!-- Up to date -->
                                                                        <xsl:otherwise>
                                                                            <span class="label label-default">up-to-date</span>
                                                                        </xsl:otherwise>
                                                                        
                                                                    </xsl:choose>
                                                                </xsl:when>
                                                                
                                                            </xsl:choose>
                                                        </div>
                                                        
                                                        <!-- File format columns -->
                                                        <xsl:for-each select="$file-formats">
                                                            <xsl:variable name="file-format" select="."/>
                                                            <xsl:variable name="file-version" select="$text-downloads[@type eq $file-format]/@version"/>
                                                            <xsl:variable name="master-file-version" select="$master-downloads[@type eq $file-format]/@version"/>
                                                            <div class="col-sm-2">
                                                                <xsl:choose>
                                                                    
                                                                    <!-- Client actions -->
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'client']">
                                                                        <xsl:choose>
                                                                            
                                                                            <!-- If master is outdated then just warn -->
                                                                            <xsl:when test="compare($master-file-version, $master-tei-version) ne 0">
                                                                                <span class="label label-info">Update collaboration</span>
                                                                            </xsl:when>
                                                                            
                                                                            <!-- If outdated then offer to get from master -->
                                                                            <xsl:when test="compare($file-version, $master-file-version) ne 0">
                                                                                <a>
                                                                                    <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, '#', $toh/@key)"/>
                                                                                    <xsl:attribute name="title" select="'Update this file'"/>
                                                                                    <span class="label label-warning">
                                                                                        <xsl:if test="$status-id eq '1'">
                                                                                            <xsl:attribute name="class" select="'label label-success'"/>
                                                                                        </xsl:if>
                                                                                        <xsl:value-of select="concat('Get ', $master-file-version)"/>
                                                                                    </span>
                                                                                </a>
                                                                            </xsl:when>
                                                                            
                                                                            <!-- Up to date -->
                                                                            <xsl:otherwise>
                                                                                <span class="label label-default">up-to-date</span>
                                                                            </xsl:otherwise>
                                                                            
                                                                        </xsl:choose>
                                                                    </xsl:when>
                                                                    
                                                                    <!-- Master actions -->
                                                                    <xsl:when test="$environment/m:store-conf[@type eq 'master']">
                                                                        <xsl:choose>
                                                                            
                                                                            <!-- Versions don't match so offer create option -->
                                                                            <xsl:when test="compare($file-version, $tei-version) ne 0">
                                                                                <a>
                                                                                    <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', $file-format, '#', $toh/@key)"/>
                                                                                    <xsl:attribute name="title" select="'Create this file'"/>
                                                                                    <span class="label label-warning">
                                                                                        <xsl:if test="$status-id eq '1'">
                                                                                            <xsl:attribute name="class" select="'label label-success'"/>
                                                                                        </xsl:if>
                                                                                        <xsl:value-of select="concat('Create ', upper-case($file-format))"/>
                                                                                    </span>
                                                                                </a>
                                                                            </xsl:when>
                                                                            
                                                                        </xsl:choose>
                                                                    </xsl:when>
                                                                    
                                                                </xsl:choose>
                                                            </div>
                                                        </xsl:for-each>
                                                        
                                                    </div>
                                                </div>
                                                
                                                <!-- Translation notes / link to the header form, only on master -->
                                                <xsl:variable name="translation-status" select="/m:response/m:translation-status/m:text[@text-id eq $text-id]"/>
                                                <xsl:if test="$environment/m:store-conf[@type eq 'master'] and ($translation-status/m:task[not(@checked-off)] or $translation-status/m:notes/text())">
                                                    <div class="top-vertical">
                                                        
                                                        <xsl:if test="$translation-status/m:task[not(@checked-off)]">
                                                            <!-- If there are tasks then link to the form -->
                                                            <span>
                                                                <span class="badge badge-notification">
                                                                    <xsl:value-of select="count($translation-status/m:task[not(@checked-off)])"/>
                                                                </span>
                                                            </span>
                                                        </xsl:if>
                                                        
                                                        <span>
                                                            <a class="printable">
                                                                <div class="small collapse-one-line">
                                                                    <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', $text-id, '#publication-status-form')"/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="$translation-status/m:notes/text()">
                                                                            <xsl:value-of select="$translation-status/m:notes"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            [No notes]
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </div>
                                                            </a>
                                                        </span>
                                                    </div>
                                                </xsl:if>
                                                
                                            </td>
                                            <td>                                                
                                                <span class="text-muted small nowrap">Translated words:</span>
                                                <br/>
                                                <xsl:value-of select="fn:format-number(xs:integer(@wordCount),'#,##0')"/>
                                            </td>
                                            <td>
                                                <span class="text-muted small nowrap">Glossary terms:</span>
                                                <br/>
                                                <xsl:value-of select="fn:format-number(xs:integer(@glossaryCount),'#,##0')"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <td/>
                                        <td>
                                            <small class="text-muted">
                                                Texts:
                                            </small>
                                            <br/>
                                            <xsl:value-of select="fn:format-number(xs:integer(count(//m:translations/m:translation)),'#,##0')"/>
                                        </td>
                                        <td>
                                            <small class="text-muted">
                                                Total words:
                                            </small>
                                            <br/>
                                            <xsl:value-of select="fn:format-number(xs:integer(sum(//m:translations/m:translation/@wordCount)),'#,##0')"/>
                                        </td>
                                        <td>
                                            <small class="text-muted">
                                                Total terms:
                                            </small>
                                            <br/>
                                            <xsl:value-of select="fn:format-number(xs:integer(sum(//m:translations/m:translation/@glossaryCount)),'#,##0')"/>
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
            <xsl:with-param name="page-title" select="'Translations :: 84000 Utilities'"/>
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