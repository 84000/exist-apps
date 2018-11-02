<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="tabs.xsl"/>
    
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
                            <a target="_self">
                                <xsl:attribute name="href" select="$reading-room-path"/>
                                Reading Room
                            </a>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="alert alert-danger" role="alert">
                            Due to an underlying restriction in the database platform only database administrators can generate new versions of eBooks.
                        </div>
                        
                        <xsl:if test="m:updated">
                            <div class="alert alert-success" role="alert">
                                <xsl:value-of select="m:updated"/>
                            </div>
                        </xsl:if>
                        
                        <xsl:if test="$environment/m:store-conf">
                            <ul class="list-inline">
                                <li>
                                    <span class="small">
                                        Key:
                                    </span>
                                </li>
                                <li>
                                    <span class="label label-info">
                                        current version
                                    </span>
                                </li>
                                <li>
                                    <span class="label label-primary">
                                        dynamic
                                    </span>
                                </li>
                                <li>
                                    <span class="label label-success">
                                        file is the latest version
                                    </span>
                                </li>
                                <li>
                                    <span class="label label-warning">
                                        file is an old version
                                    </span>
                                </li>
                                <li>
                                    <span class="label label-danger">
                                        there is no file
                                    </span>
                                </li>
                                <li>
                                    <span class="label label-default">
                                        disabled
                                    </span>
                                </li>
                            </ul>
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
                                        <tr>
                                            <xsl:attribute name="id" select="$toh/@key"/>
                                            <td rowspan="2">
                                                <xsl:value-of select="m:toh/m:base"/>
                                            </td>
                                            <td>
                                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                            </td>
                                            <td colspan="2" class="nowrap">
                                                <xsl:value-of select="@id"/>
                                                <div class="label label-warning pull-right">
                                                    <xsl:if test="@status-id eq '1'">
                                                        <xsl:attribute name="class" select="'label label-success pull-right'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="@status-id"/>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr class="sub">
                                            <td>
                                                <ul class="list-inline">
                                                    <li>
                                                        <span class="label label-info">
                                                            <xsl:value-of select="m:downloads/@tei-version"/>
                                                        </span>
                                                    </li>
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $toh/@key, '.xml')"/>
                                                            <xsl:attribute name="target" select="concat($toh/@key, '.xml')"/>
                                                            <span class="label label-primary">
                                                                <xsl:value-of select="concat($toh/@key, '.xml')"/>
                                                            </span>
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', $toh/@key, '.html')"/>
                                                            <xsl:attribute name="target" select="concat($toh/@key, '.html')"/>
                                                            <span class="label label-primary">
                                                                <xsl:value-of select="concat($toh/@key, '.html')"/>
                                                            </span>
                                                        </a>
                                                    </li>
                                                    <xsl:for-each select="m:downloads/m:download">
                                                        <li>
                                                            <a>
                                                                <xsl:choose>
                                                                    <xsl:when test="compare(@version, $tei-version) eq 0">
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, @url)"/>
                                                                        <span class="label label-success">
                                                                            <xsl:value-of select="concat('Download ', $toh/@key, '.', @type)"/>
                                                                        </span>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:choose>
                                                                            <xsl:when test="$environment/m:store-conf">
                                                                                <xsl:attribute name="href" select="concat('/translations.html?store=', $toh/@key, '.', @type, '#', $toh/@key)"/>
                                                                                <xsl:choose>
                                                                                    <xsl:when test="@version gt '0'">
                                                                                        <span class="label label-warning">
                                                                                            <xsl:value-of select="concat('Update ', $toh/@key, '.', @type)"/>
                                                                                        </span>
                                                                                    </xsl:when>
                                                                                    <xsl:otherwise>
                                                                                        <span class="label label-danger">
                                                                                            <xsl:value-of select="concat('Create ', $toh/@key, '.', @type)"/>
                                                                                        </span>
                                                                                    </xsl:otherwise>
                                                                                </xsl:choose>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:attribute name="href" select="'#'"/>
                                                                                <span class="label label-default">
                                                                                    <xsl:choose>
                                                                                        <xsl:when test="@version gt '0'">
                                                                                            <xsl:value-of select="concat(@type, ' out of date')"/>
                                                                                        </xsl:when>
                                                                                        <xsl:otherwise>
                                                                                            <xsl:value-of select="concat(@type, ' missing')"/>
                                                                                        </xsl:otherwise>
                                                                                    </xsl:choose>
                                                                                </span>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                        
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                            </a>
                                                        </li>
                                                    </xsl:for-each>
                                                </ul>
                                                <span class="small">
                                                    File: 
                                                    <a>
                                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/translation/', @id, '.tei')"/>
                                                        <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                                        <xsl:value-of select="@uri"/>
                                                    </a>
                                                </span>
                                            </td>
                                            <td>                                                
                                                <small class="text-muted">
                                                    Translated words:
                                                </small>
                                                <br/>
                                                <xsl:value-of select="fn:format-number(xs:integer(@wordCount),'#,##0')"/>
                                            </td>
                                            <td>
                                                <small class="text-muted">
                                                    Glossary terms:
                                                </small>
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
</xsl:stylesheet>