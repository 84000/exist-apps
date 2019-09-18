<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
        
        <xsl:variable name="content">
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <xsl:call-template name="header"/>
                        
                    </div>
                    
                    <div class="panel-body tests">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            
                            <div class="alert alert-info small text-center">
                                <p>
                                    <xsl:text>
                                        This page expresses the folio references in each translation and their link to the eText. This data can be shared in xml format at:  
                                    </xsl:text>
                                    <a target="folios-xml" class="alert-link">
                                        <xsl:attribute name="href" select="concat($utilities-path, '/folios.xml')"/>
                                        <xsl:value-of select="concat($utilities-path, '/folios.xml')"/>
                                    </a>
                                </p>
                            </div>
                            
                            <div class="alert alert-warning small text-center">
                                <p>
                                    <xsl:text>
                                        When validating folio references it is only vital that the start/end pages in the TEI location header match the start/end pages in the eKangyur edition. Then check that each reference links to the correct Tibetan page. 
                                        Folio references may vary while remaining valid e.g. Vol.90, p.124 is correctly expressed as F.63.a although F.62.b is expected. This valid variation.
                                    </xsl:text>
                                </p>
                            </div>
                            
                            <table class="table table-icons table-responsive">
                                <thead>
                                    <tr>
                                        <th>Toh</th>
                                        <th>Title</th>
                                        <th>Start</th>
                                        <th>End</th>
                                        <th>Pages</th>
                                        <th colspan="2">Issues</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="m:translations/m:text">
                                        <xsl:sort select="number(m:toh/@number)"/>
                                        <xsl:sort select="m:toh/m:base"/>
                                        <xsl:variable name="toh-key" select="m:toh/@key"/>
                                        <xsl:variable name="text-row-id" select="concat('text-', position())"/>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="m:toh/m:base"/>
                                            </td>
                                            <td>
                                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                            </td>
                                            <td class="nowrap small">
                                                <xsl:value-of select="concat('Vol. ', m:location/m:volume[1]/@number, ', page ', m:location/m:volume[1]/@start-page)"/>
                                            </td>
                                            <td class="nowrap small">
                                                <xsl:value-of select="concat('Vol. ', m:location/m:volume[last()]/@number, ', page ', m:location/m:volume[last()]/@end-page)"/>
                                            </td>
                                            <td class="nowrap">
                                                <a class="collapsed underline" role="button" data-toggle="collapse" aria-expanded="false">
                                                    <xsl:attribute name="href" select="concat('#', $text-row-id, '-sub')"/>
                                                    <xsl:attribute name="aria-controls" select="concat($text-row-id, '-sub')"/>
                                                    <xsl:value-of select="m:folios/@count-pages"/>
                                                </a>
                                            </td>
                                            <td class="icon">
                                                <xsl:choose>
                                                    <xsl:when test="m:folios[@count-pages ne @count-refs]">
                                                        <i class="fa fa-times-circle"/>
                                                    </xsl:when>
                                                    <xsl:when test="m:folios/m:folio[not(@tei-folio = (@folio-in-volume, @folio-consecutive))]">
                                                        <i class="fa fa-exclamation-circle"/>
                                                    </xsl:when>
                                                </xsl:choose>
                                            </td>
                                            <td class="nowrap text-danger small">
                                                <xsl:if test="m:folios[@count-pages ne @count-refs]">
                                                    <xsl:value-of select="concat(m:folios/@count-refs, ' found')"/>
                                                </xsl:if>
                                            </td>
                                        </tr>
                                        <tr class="sub collapse">
                                            <xsl:attribute name="id" select="concat($text-row-id, '-sub')"/>
                                            <td colspan="7">
                                                <table class="table table-responsive no-top-margin">
                                                    <thead>
                                                        <tr>
                                                            <th>Ref</th>
                                                            <th>Page</th>
                                                            <th colspan="2">@cRef</th>
                                                            <th colspan="2">HTML</th>
                                                            <th colspan="2">XML</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <xsl:for-each select="m:folios/m:folio">
                                                            <xsl:variable name="folio-row-id" select="concat($text-row-id, '-folio-', position())"/>
                                                            <tr>
                                                                <td>
                                                                    <xsl:value-of select="@page-in-text"/>.
                                                                </td>
                                                                <td>
                                                                    <xsl:value-of select="concat('Vol.', @volume, ' p.', @page-in-volume)"/> 
                                                                </td>
                                                                <td>
                                                                    <xsl:choose>
                                                                        <xsl:when test="@tei-folio gt ''">
                                                                            <xsl:value-of select="@tei-folio"/>
                                                                        </xsl:when>
                                                                    </xsl:choose>
                                                                </td>
                                                                <td>
                                                                    <xsl:variable name="preceding-style" as="xs:string?">
                                                                        <xsl:variable name="preceding-folio" select="preceding-sibling::m:folio[@tei-folio = (@folio-in-volume, @folio-consecutive)][1]"/>
                                                                        <xsl:choose>
                                                                            <xsl:when test="$preceding-folio[@tei-folio eq @folio-in-volume]">
                                                                                <xsl:value-of select="'parallel'"/>
                                                                            </xsl:when>
                                                                            <xsl:when test="$preceding-folio[@tei-folio eq @folio-consecutive]">
                                                                                <xsl:value-of select="'consecutive'"/>
                                                                            </xsl:when>
                                                                            <xsl:otherwise>
                                                                                <xsl:value-of select="'none'"/>
                                                                            </xsl:otherwise>
                                                                        </xsl:choose>
                                                                    </xsl:variable>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(@tei-folio = (@folio-in-volume, @folio-consecutive))">
                                                                            <xsl:choose>
                                                                                <xsl:when test="@tei-folio eq ''">
                                                                                    <xsl:attribute name="class" select="'small text-danger'"/>
                                                                                    <xsl:value-of select="'Folio missing'"/>
                                                                                </xsl:when>
                                                                                <xsl:when test="$preceding-style eq 'consecutive'">
                                                                                    <xsl:attribute name="class" select="'small text-warning'"/>
                                                                                    <xsl:value-of select="concat('Logically ', @folio-consecutive)"/>
                                                                                </xsl:when>
                                                                                <!-- <xsl:when test="$preceding-style eq 'parallel'">
                                                                                    <xsl:value-of select="concat('Expected ', @folio-in-volume)"/>
                                                                                </xsl:when> -->
                                                                                <xsl:otherwise>
                                                                                    <xsl:attribute name="class" select="'small text-warning'"/>
                                                                                    <!-- <xsl:value-of select="concat('Expected ', @folio-in-volume, ' or ', @folio-consecutive)"/> -->
                                                                                    <xsl:value-of select="concat('Logically ', @folio-in-volume)"/>
                                                                                </xsl:otherwise>
                                                                            </xsl:choose>
                                                                        </xsl:when>
                                                                    </xsl:choose>
                                                                </td>
                                                                <td>
                                                                    <a>
                                                                        <xsl:attribute name="href" select="m:url[@format eq 'html'][@xml:lang eq 'bo']"/>
                                                                        <xsl:attribute name="data-ajax-target" select="'#popup-footer-source .data-container'"/>
                                                                        <xsl:value-of select="'Tibetan'"/>
                                                                    </a>
                                                                </td>
                                                                <td>
                                                                    <a>
                                                                        <xsl:attribute name="target" select="$text-row-id"/>
                                                                        <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $toh-key, '.html', '#source-link-', @page-in-text)"/>
                                                                        <xsl:value-of select="'English'"/>
                                                                    </a>
                                                                </td>
                                                                <td>
                                                                    <a>
                                                                        <xsl:attribute name="target" select="concat($folio-row-id, '-bo')"/>
                                                                        <xsl:attribute name="href" select="m:url[@format eq 'xml'][@xml:lang eq 'bo']"/>
                                                                        <xsl:value-of select="'Tibetan'"/>
                                                                    </a>
                                                                </td>
                                                                <td>
                                                                    <a>
                                                                        <xsl:attribute name="target" select="concat($folio-row-id, '-en')"/>
                                                                        <xsl:attribute name="href" select="m:url[@format eq 'xml'][@xml:lang eq 'en']"/>
                                                                        <xsl:value-of select="'English'"/>
                                                                    </a>
                                                                </td>
                                                            </tr>
                                                        </xsl:for-each>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="2" class="text-right">Total</th>
                                        <td colspan="5">
                                            <xsl:value-of select="format-number(count(m:translations/m:text/m:folios/m:folio), '#,###')"/>
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
            
            <div id="popup-footer-source" class="fixed-footer collapse hidden-print">
                <div class="fix-height">
                    <div class="data-container">
                        
                    </div>
                </div>
                <div class="fixed-btn-container close-btn-container">
                    <button type="button" class="btn-round close" aria-label="Close">
                        <span aria-hidden="true">
                            <i class="fa fa-times"/>
                        </span>
                    </button>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Folios | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Folios'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>