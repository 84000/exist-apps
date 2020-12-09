<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <!-- Some tests -->
            <xsl:choose>
                <xsl:when test="count(m:results/m:structure/m:test[@pass eq '0']) eq 0">
                    <div class="alert alert-success small text-center">
                        <p>
                            <xsl:value-of select="'No errors were found in the sections structure.'"/>
                        </p>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="m:results/m:structure/m:test[@pass eq '0']">
                        <div class="alert alert-danger small">
                            <p>
                                <xsl:value-of select="concat('Failed test: ', m:title)"/>
                            </p>
                            <ol>
                                <xsl:for-each select="m:details/m:detail">
                                    <li>
                                        <xsl:value-of select="text()"/>
                                    </li>
                                </xsl:for-each>
                            </ol>
                        </div>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            
            <table class="table table-responsive">
                <thead>
                    <tr>
                        <th>Section</th>
                        <th>Texts / Pages</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="m:section">
                        <xsl:sort select="xs:integer(@sort-index)"/>
                        <xsl:call-template name="section-row"/>
                    </xsl:for-each>
                </tbody>
            </table>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Sections | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Sections'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="section-row">
        <xsl:variable name="section-texts-id" select="concat('section-texts-', fn:encode-for-uri(@id))"/>
        <tr>
            <td>
                <xsl:call-template name="indent">
                    <xsl:with-param name="counter" select="1"/>
                    <xsl:with-param name="finish" select="xs:integer(@nesting)"/>
                    <xsl:with-param name="content">
                        <div>
                            <span class="text-bold">
                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                            </span>
                            <small>
                                <xsl:value-of select="concat(' \ ', @id)"/>
                            </small>
                        </div>
                        <ul class="list-inline inline-dots sml-margin bottom">
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.tei')"/>
                                    <xsl:attribute name="target" select="concat(@id, '.tei')"/>
                                    <span class="small">
                                        <xsl:value-of select="'tei'"/>
                                    </span>
                                </a>
                            </li>
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.xml')"/>
                                    <xsl:attribute name="target" select="concat(@id, '.xml')"/>
                                    <span class="small">
                                        <xsl:value-of select="'xml'"/>
                                    </span>
                                </a>
                            </li>
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.json')"/>
                                    <xsl:attribute name="target" select="concat(@id, '.json')"/>
                                    <span class="small">
                                        <xsl:value-of select="'json'"/>
                                    </span>
                                </a>
                            </li>
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.html')"/>
                                    <xsl:attribute name="target" select="concat(@id, '.html')"/>
                                    <span class="small">
                                        <xsl:value-of select="'html'"/>
                                    </span>
                                </a>
                            </li>
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.navigation.atom')"/>
                                    <xsl:attribute name="target" select="concat(@id, '.navigation.atom')"/>
                                    <span class="small">
                                        <xsl:value-of select="'navigation.atom'"/>
                                    </span>
                                </a>
                            </li>
                            <xsl:if test="xs:integer(m:text-stats/m:stat[@type eq 'count-published-children']/@value) gt 0">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', @id, '.acquisition.atom')"/>
                                        <xsl:attribute name="target" select="concat(@id, '.acquisition.atom')"/>
                                        <span class="small">
                                            <xsl:value-of select="'acquisition.atom'"/>
                                        </span>
                                    </a>
                                </li>
                            </xsl:if>
                            <li>
                                <a>
                                    <xsl:attribute name="href" select="concat('/test-sections.html?section-id=', @id)"/>
                                    <xsl:attribute name="target" select="concat(@id, 'tests')"/>
                                    <span class="small">
                                        <xsl:value-of select="'run tests'"/>
                                    </span>
                                </a>
                            </li>
                        </ul>
                        <div class="small text-muted">
                            <xsl:value-of select="'File: '"/>
                            <span class="break">
                                <xsl:value-of select="@uri"/>
                            </span>
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
            </td>
            
            <td>
                <div class="row">
                    <div class="col-sm-4">
                        <span class="small text-muted nowrap">In this section: </span>
                        <br/>
                        <a href="#" target="_self">
                            <xsl:choose>
                                <xsl:when test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/@value) gt 0">
                                    <xsl:attribute name="href" select="concat('section-texts.html?section-id=', fn:encode-for-uri(@id), '#ajax-source')"/>
                                    <xsl:attribute name="data-ajax-target" select="concat('#', $section-texts-id, ' .ajax-target')"/>
                                    <xsl:attribute name="aria-controls" select="$section-texts-id"/>
                                    <xsl:attribute name="class" select="'underline'"/>
                                    <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/@value),'#,##0')"/>
                                    <xsl:value-of select="' / '"/>
                                    <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-text-children']/@value),'#,##0')"/>
                                </xsl:when>
                                <xsl:otherwise>-</xsl:otherwise>
                            </xsl:choose>
                        </a>
                        <!-- Alert user if un-matched texts found -->
                        <xsl:choose>
                            <xsl:when test="/m:response/m:results/m:structure/m:test[@id eq 'unmatched-section-texts']//*[@ref eq $section-texts-id]">
                                <span>
                                    <xsl:attribute name="class" select="'label label-danger'"/>
                                    <xsl:attribute name="title" select="/m:response/m:results/m:structure/m:test[@id eq 'unmatched-section-texts']//*[@ref eq $section-texts-id]/text()"/>
                                    <xsl:value-of select="'error'"/>
                                </span>
                            </xsl:when>
                        </xsl:choose>
                    </div>
                    <div class="col-sm-4">
                        <span class="small text-muted nowrap">Published: </span>
                        <br/>
                        <xsl:choose>
                            <xsl:when test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/@value) gt 0">
                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-published-children']/@value),'#,##0')"/>
                                <xsl:value-of select="' / '"/>
                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-published-children']/@value),'#,##0')"/>
                            </xsl:when>
                            <xsl:otherwise>-</xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="col-sm-4">
                        <span class="small text-muted nowrap">In-progress: </span>
                        <br/>
                        <xsl:choose>
                            <xsl:when test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/@value) gt 0">
                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-in-progress-children']/@value),'#,##0')"/>
                                <xsl:value-of select="' / '"/>
                                <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-in-progress-children']/@value),'#,##0')"/>
                            </xsl:when>
                            <xsl:otherwise>-</xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <xsl:if test="xs:integer(m:text-stats/m:stat[@type eq 'count-text-descendants']/@value) gt xs:integer(m:text-stats/m:stat[@type eq 'count-text-children']/@value)">
                        <div class="col-sm-4">
                            <span class="small text-muted nowrap">Under this section: </span>
                            <br/>
                            <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-text-descendants']/@value),'#,##0')"/>
                            <xsl:value-of select="' / '"/>
                            <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-text-descendants']/@value),'#,##0')"/>
                        </div>
                        <div class="col-sm-4">
                            <span class="small text-muted nowrap">Published: </span>
                            <br/>
                            <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-published-descendants']/@value),'#,##0')"/>
                            <xsl:value-of select="' / '"/>
                            <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-published-descendants']/@value),'#,##0')"/>
                        </div>
                        <div class="col-sm-4">
                            <span class="small text-muted nowrap">In-progress: </span>
                            <br/>
                            <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'count-in-progress-descendants']/@value),'#,##0')"/>
                            <xsl:value-of select="' / '"/>
                            <xsl:value-of select="fn:format-number(xs:integer(m:text-stats/m:stat[@type eq 'sum-pages-in-progress-descendants']/@value),'#,##0')"/>
                        </div>
                    </xsl:if>
                    
                </div>
            </td>
        </tr>
        <tr class="sub">
            <td colspan="2">
                <div class="collapse">
                    <xsl:attribute name="id" select="$section-texts-id"/>
                    <div class="ajax-target"/>
                </div>
            </td>
        </tr>
        <xsl:for-each select="m:section">
            <xsl:sort select="xs:integer(@sort-index)"/>
            <xsl:call-template name="section-row"/>
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>