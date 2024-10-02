<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:webflow="http://read.84000.co/webflow-api" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/webpage.xsl"/>
    
    <xsl:variable name="webflow-api" select="/m:response/webflow:webflow-api"/>
    
    <xsl:template match="m:results">
        
        <!-- Some tests -->
        <xsl:choose>
            
            <xsl:when test="count(m:structure/m:test[@pass eq '0']) eq 0">
                <div class="alert alert-success small text-center">
                    <p>
                        <xsl:value-of select="'No errors were found in the sections structure.'"/>
                    </p>
                </div>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:for-each select="m:structure/m:test[@pass eq '0']">
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
                        
                        <xsl:if test="/m:response[@model eq 'utilities/sections'][@user-name eq 'admin'] and /m:response/m:environment/m:store-conf[@type eq 'client']">
                            <xsl:choose>
                                <xsl:when test="@id eq 'unmatched-ids'">
                                    <a href="/sections.html?resolve=unmatched-ids" class="btn btn-default btn-sm" target="_self">
                                        <xsl:attribute name="data-loading" select="'Getting TEI files with unmatched @source-ids...'"/>
                                        <xsl:value-of select="'Get TEI files with unmatched @source-ids from Collaboration'"/>
                                    </a>
                                </xsl:when>
                                <xsl:when test="@id eq 'unmatched-tei'">
                                    <a href="/sections.html?resolve=unmatched-tei" class="btn btn-default btn-sm" target="_self">
                                        <xsl:attribute name="data-loading" select="'Updating TEI files with invalid @source-ids...'"/>
                                        <xsl:value-of select="'Update TEI files with invalid @source-ids from Collaboration'"/>
                                    </a>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:if>
                        
                    </div>
                </xsl:for-each>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="m:translation-summary">
        
        <table class="table table-responsive">
            <thead>
                <tr>
                    <th>Section</th>
                    <th/>
                    <th class="small nowrap">Total</th>
                    <th class="small nowrap">Published</th>
                    <!--<th class="small nowrap">In-progress</th>-->
                    <th class="small nowrap">Translated</th>
                    <th class="small nowrap">In-translation</th>
                    <th class="small nowrap">Not started</th>
                </tr>
            </thead>
            <tbody>
                <xsl:call-template name="section-row">
                    <xsl:with-param name="translation-summary" select="."/>
                </xsl:call-template>
            </tbody>
        </table>
        
    </xsl:template>
    
    <xsl:template name="section-row">
        
        <xsl:param name="translation-summary" as="element(m:translation-summary)"/>
        
        <xsl:variable name="section-texts-id" select="concat('section-texts-', $translation-summary/@section-id)"/>
        
        <xsl:variable name="count-text-descendants" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:texts/@total ! xs:integer(.)"/>
        <xsl:variable name="sum-pages-text-descendants" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:pages/@total ! xs:integer(.)"/>
        
        <xsl:variable name="count-text-children" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:texts/@total ! xs:integer(.)"/>
        <xsl:variable name="sum-pages-text-children" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:pages/@total ! xs:integer(.)"/>
        
        <xsl:variable name="texts-webflow-id" select="$translation-summary/m:publication-status[@toh-key = $webflow-api//webflow:item/@id]"/>
        <xsl:variable name="texts-webflow-id-missing" select="$translation-summary/m:publication-status except $texts-webflow-id"/>
        
        <tr>
            
            <td>
                
                <xsl:if test="m:translation-summary">
                    <xsl:attribute name="rowspan" select="'2'"/>
                </xsl:if>
                
                <xsl:call-template name="indent">
                    <xsl:with-param name="counter" select="1"/>
                    <xsl:with-param name="finish" select="count(ancestor::m:translation-summary) + 1"/>
                    <xsl:with-param name="content">
                        <div style="min-height:130px;">
                            <div>
                                <span class="text-bold">
                                    <xsl:value-of select="$translation-summary/m:title"/>
                                </span>
                                <span class="small text-muted">
                                    <xsl:value-of select="concat(' \ ', $translation-summary/@section-id)"/>
                                </span>
                            </div>
                            <div class="sml-margin bottom">
                                <ul class="list-inline inline-dots">
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', $translation-summary/@section-id, '.tei')"/>
                                            <xsl:attribute name="target" select="concat($translation-summary/@section-id, '.tei')"/>
                                            <span class="small">
                                                <xsl:value-of select="'tei'"/>
                                            </span>
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', $translation-summary/@section-id, '.xml')"/>
                                            <xsl:attribute name="target" select="concat($translation-summary/@section-id, '.xml')"/>
                                            <span class="small">
                                                <xsl:value-of select="'xml'"/>
                                            </span>
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', $translation-summary/@section-id, '.json')"/>
                                            <xsl:attribute name="target" select="concat($translation-summary/@section-id, '.json')"/>
                                            <span class="small">
                                                <xsl:value-of select="'json'"/>
                                            </span>
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', $translation-summary/@section-id, '.html')"/>
                                            <xsl:attribute name="target" select="concat($translation-summary/@section-id, '.html')"/>
                                            <span class="small">
                                                <xsl:value-of select="'html'"/>
                                            </span>
                                        </a>
                                    </li>
                                    <!--<li>
                                        <a>
                                            <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', $translation-summary/@section-id, '.navigation.atom')"/>
                                            <xsl:attribute name="target" select="concat($translation-summary/@section-id, '.navigation.atom')"/>
                                            <span class="small">
                                                <xsl:value-of select="'navigation.atom'"/>
                                            </span>
                                        </a>
                                    </li>
                                    <xsl:if test="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:texts/@published ! xs:integer(.) gt 0">
                                        <li>
                                            <a>
                                                <xsl:attribute name="href" select="concat($reading-room-path ,'/section/', $translation-summary/@section-id, '.acquisition.atom')"/>
                                                <xsl:attribute name="target" select="concat($translation-summary/@section-id, '.acquisition.atom')"/>
                                                <span class="small">
                                                    <xsl:value-of select="'acquisition.atom'"/>
                                                </span>
                                            </a>
                                        </li>
                                    </xsl:if>-->
                                    <li>
                                        <a>
                                            <xsl:attribute name="href" select="concat('/test-sections.html?section-id=', $translation-summary/@section-id)"/>
                                            <xsl:attribute name="target" select="concat($translation-summary/@section-id, 'tests')"/>
                                            <span class="small">
                                                <xsl:value-of select="'run tests'"/>
                                            </span>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                            <div class="small text-muted sml-margin bottom">
                                <xsl:value-of select="'TEI file: '"/>
                                <span class="break">
                                    <xsl:value-of select="$translation-summary/@document-url"/>
                                </span>
                            </div>
                            <ul class="list-unstyled">
                                
                                <xsl:variable name="webflow-api-item" select="$webflow-api//webflow:item[@id eq $translation-summary/@section-id]"/>
                                
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="$webflow-api-item and $webflow-api-item[not(@updated gt '')]">
                                            <span class="label label-warning">
                                                <xsl:value-of select="'No Webflow CMS updates'"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:when test="$webflow-api-item">
                                            <span class="label label-default">
                                                <xsl:value-of select="concat('Lastest update to Webflow CMS ', (format-dateTime($webflow-api-item/@updated, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="label label-danger">
                                                <xsl:value-of select="'Not linked to Webflow CMS'"/>
                                            </span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                                
                                <xsl:if test="$webflow-api-item[@updated ! xs:dateTime(.) lt $translation-summary/@last-modified ! xs:dateTime(.)]">
                                    <li>
                                        <span class="label label-warning">
                                            <xsl:value-of select="concat('Latest update in this section ', (format-dateTime($translation-summary/@last-modified, '[D01] [MNn,*-3] [Y] [H01]:[m01]:[s01]'), '[unknown]')[1])"/>
                                        </span>
                                    </li>
                                </xsl:if>
                                
                                <xsl:if test="$texts-webflow-id-missing">
                                    <li>
                                        <span class="label label-danger">
                                            <xsl:value-of select="concat(count($texts-webflow-id-missing), ' texts not linked to Webflow CMS')"/>
                                        </span>
                                    </li>
                                </xsl:if>
                                
                            </ul>
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
                
            </td>
            
            <th class="small nowrap text-warning">this section:</th>
            
            <!-- Count of texts / pages -->
            <td class="small">
                <a href="#" target="_self">
                    <xsl:choose>
                        <xsl:when test="$count-text-children gt 0">
                            <xsl:attribute name="href" select="concat('section-texts.html?section-id=', fn:encode-for-uri($translation-summary/@section-id), '#ajax-source')"/>
                            <xsl:attribute name="data-ajax-target" select="concat('#', $section-texts-id, ' .ajax-target')"/>
                            <xsl:attribute name="aria-controls" select="$section-texts-id"/>
                            <xsl:attribute name="class" select="'underline'"/>
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($count-text-children,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' texts'"/>
                                </span>
                            </span>
                            <br/>
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($sum-pages-text-children,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' pages'"/>
                                </span>
                            </span>
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
            </td>
            
            <!-- Published -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:texts/@published ! xs:integer(.)"/>
                    <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:pages/@published ! xs:integer(.)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
            <!-- Translated -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:texts/@translated ! xs:integer(.)"/>
                    <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:pages/@translated ! xs:integer(.)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
            <!-- In-translation -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:texts/@in-translation ! xs:integer(.)"/>
                    <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:pages/@in-translation ! xs:integer(.)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
            <!-- Not-started -->
            <td class="small">
                <xsl:call-template name="section-stat">
                    <xsl:with-param name="show-stat" select="$count-text-children gt 0"/>
                    <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:texts/@not-started ! xs:integer(.)"/>
                    <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'children']/m:pages/@not-started ! xs:integer(.)"/>
                    <xsl:with-param name="page-total" select="$sum-pages-text-children"/>
                </xsl:call-template>
            </td>
            
        </tr>
        
        <xsl:if test="m:translation-summary">
            
            <tr>
                
                <th class="small nowrap text-warning">+ sub-sections:</th>
                
                <!-- Count of texts / pages -->
                <td class="small">
                    <xsl:choose>
                        <xsl:when test="$count-text-descendants gt $count-text-children">
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($count-text-descendants,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' texts'"/>
                                </span>
                            </span>
                            <br/>
                            <span class="nowrap">
                                <xsl:value-of select="fn:format-number($sum-pages-text-descendants,'#,##0')"/>
                                <span class="text-muted">
                                    <xsl:value-of select="' pages'"/>
                                </span>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>-</xsl:otherwise>
                    </xsl:choose>
                </td>
                
                <!-- Published -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:texts/@published ! xs:integer(.)"/>
                        <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:pages/@published ! xs:integer(.)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
                <!-- Translated -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:texts/@translated ! xs:integer(.)"/>
                        <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:pages/@translated ! xs:integer(.)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
                <!-- In-translation -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:texts/@in-translation ! xs:integer(.)"/>
                        <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:pages/@in-translation ! xs:integer(.)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
                <!-- Not-started -->
                <td class="small">
                    <xsl:call-template name="section-stat">
                        <xsl:with-param name="show-stat" select="$count-text-descendants gt $count-text-children"/>
                        <xsl:with-param name="text-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:texts/@not-started ! xs:integer(.)"/>
                        <xsl:with-param name="page-count" select="$translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']/m:pages/@not-started ! xs:integer(.)"/>
                        <xsl:with-param name="page-total" select="$sum-pages-text-descendants"/>
                    </xsl:call-template>
                </td>
                
            </tr>
            
        </xsl:if>
        
        <tr class="sub">
            <td colspan="7">
                <div class="collapse well well-sm">
                    <xsl:attribute name="id" select="$section-texts-id"/>
                    <div class="ajax-target"/>
                </div>
            </td>
        </tr>
        
        <xsl:for-each select="m:translation-summary">
            <xsl:call-template name="section-row">
                <xsl:with-param name="translation-summary" select="."/>
            </xsl:call-template>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="section-stat">
        
        <xsl:param name="show-stat" as="xs:boolean"/>
        <xsl:param name="text-count" as="xs:integer"/>
        <xsl:param name="page-count" as="xs:integer"/>
        <xsl:param name="page-total" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="$show-stat">
                <span class="nowrap">
                    <xsl:value-of select="fn:format-number($text-count,'#,##0')"/>
                    <span class="text-muted">
                        <xsl:value-of select="' texts'"/>
                    </span>
                </span>
                <br/>
                <span class="nowrap">
                    <xsl:value-of select="fn:format-number($page-count,'#,##0')"/>
                    <span class="text-muted">
                        <xsl:value-of select="' pages'"/>
                    </span>
                </span>
                <br/>
                <span class="nowrap">
                    <xsl:choose>
                        <xsl:when test="$page-total gt 0">
                            <xsl:value-of select="fn:format-number((($page-count div $page-total) * 100), '#,###')"/>
                            <span class="text-muted">
                                <xsl:value-of select="' %'"/>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'0'"/>
                            <span class="text-muted">
                                <xsl:value-of select="' %'"/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:otherwise>-</xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>