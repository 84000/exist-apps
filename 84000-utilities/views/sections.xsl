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
                        
                        <div class="tab-content">
                            
                            <table class="table table-responsive">
                                <thead>
                                    <tr>
                                        <th>Section</th>
                                        <th>Texts</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="//m:child">
                                        <tr>
                                            <td>
                                                <xsl:call-template name="indent">
                                                    <xsl:with-param name="counter" select="1"/>
                                                    <xsl:with-param name="finish" select="xs:integer(@nesting)"/>
                                                    <xsl:with-param name="content">
                                                        <xsl:value-of select="m:title"/>
                                                        <ul class="list-inline">
                                                            <li>
                                                                <a>
                                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.tei')"/>
                                                                    <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                                                    <span class="label label-warning">
                                                                        <xsl:value-of select="concat(@id, '.tei / live')"/>
                                                                    </span>
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a>
                                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.xml')"/>
                                                                    <xsl:attribute name="target" select="concat(@id, '.xml')"/>
                                                                    <span class="label label-warning">
                                                                        <xsl:value-of select="concat(@id, '.xml / live')"/>
                                                                    </span>
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a>
                                                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.html')"/>
                                                                    <xsl:attribute name="target" select="concat(@id, '.html')"/>
                                                                    <span class="label label-warning">
                                                                        <xsl:value-of select="concat(@id, '.html / live')"/>
                                                                    </span>
                                                                </a>
                                                            </li>
                                                        </ul>
                                                        <div class="small">
                                                            File: 
                                                            <a class="break">
                                                                <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.tei')"/>
                                                                <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                                                <xsl:value-of select="@uri"/>
                                                            </a>
                                                        </div>
                                                    </xsl:with-param>
                                                </xsl:call-template>
                                            </td>
                                            
                                            <td>
                                                <div class="row">
                                                    <div class="col-sm-4">
                                                        <span class="small text-muted nowrap">In this section: </span>
                                                        <br/>
                                                        <xsl:choose>
                                                            <xsl:when test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/text()) gt 0">
                                                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']),'#,##0')"/>
                                                                <a class="small underline" target="_self">
                                                                    <xsl:attribute name="href" select="concat('section-texts.html?section-id=', fn:encode-for-uri(@id))"/>
                                                                    <xsl:attribute name="data-ajax-target" select="concat('#section-texts-', position())"/>
                                                                    <xsl:attribute name="aria-controls" select="concat('section-texts-', position())"/>
                                                                    show
                                                                </a>
                                                            </xsl:when>
                                                            <xsl:otherwise>-</xsl:otherwise>
                                                        </xsl:choose>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <span class="small text-muted nowrap">Published: </span>
                                                        <br/>
                                                        <xsl:choose>
                                                            <xsl:when test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/text()) gt 0">
                                                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-published-children']),'#,##0')"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>-</xsl:otherwise>
                                                        </xsl:choose>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <span class="small text-muted nowrap">In-progress: </span>
                                                        <br/>
                                                        <xsl:choose>
                                                            <xsl:when test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/text()) gt 0">
                                                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-in-progress-children']),'#,##0')"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>-</xsl:otherwise>
                                                        </xsl:choose>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <span class="small text-muted nowrap">Under this section: </span>
                                                        <br/>
                                                        <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-text-descendants']),'#,##0')"/>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <span class="small text-muted nowrap">Published: </span>
                                                        <br/>
                                                        <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-published-descendants']),'#,##0')"/>
                                                    </div>
                                                    <div class="col-sm-4">
                                                        <span class="small text-muted nowrap">In-progress: </span>
                                                        <br/>
                                                        <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-in-progress-descendants']),'#,##0')"/>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr class="sub">
                                            <td colspan="2">
                                                <div class="collapse">
                                                    <xsl:attribute name="id" select="concat('section-texts-', position())"/>
                                                    Texts
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                            
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sections :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Sections'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="indent">
        <xsl:param name="counter"/>
        <xsl:param name="finish"/>
        <xsl:param name="content"/>
        <span class="indent">
            <xsl:choose>
                <xsl:when test="$counter eq $finish">
                    <xsl:copy-of select="$content"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="indent">
                        <xsl:with-param name="counter" select="$counter + 1"/>
                        <xsl:with-param name="finish" select="$finish"/>
                        <xsl:with-param name="content" select="$content"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
</xsl:stylesheet>