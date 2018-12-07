<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
        
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
                            
                            <p class="text-muted text-center small">
                                This data can be shared in xml format at:  
                                <a target="folios-xml">
                                    <xsl:attribute name="href" select="concat($utilities-path, '/folios.xml')"/>
                                    <xsl:value-of select="concat($utilities-path, '/folios.xml')"/>
                                </a>
                            </p>
                            
                            <table class="table table-responsive">
                                <thead>
                                    <tr>
                                        <th>Toh</th>
                                        <th>Title</th>
                                        <th>Folios</th>
                                        <th>Start</th>
                                        <th>End</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="m:translations/m:translation">
                                        <xsl:sort select="number(m:toh/@number)"/>
                                        <xsl:sort select="m:toh/m:base"/>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="m:toh/m:base"/>
                                            </td>
                                            <td>
                                                <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                                            </td>
                                            <td class="nowrap">
                                                <a class="collapsed underline" role="button" data-toggle="collapse" aria-expanded="false">
                                                    <xsl:attribute name="href" select="concat('#translation-folios-', position())"/>
                                                    <xsl:attribute name="aria-controls" select="concat('translation-folios-', position())"/>
                                                    <xsl:value-of select="count(m:folios/m:folio)"/>
                                                </a>
                                            </td>
                                            <td>
                                                <xsl:value-of select="concat('Vol. ', m:location/m:start/@volume, ', page ', m:location/m:start/@page)"/>
                                            </td>
                                            <td>
                                                <xsl:value-of select="concat('Vol. ', m:location/m:end/@volume, ', page ', m:location/m:end/@page)"/>
                                            </td>
                                        </tr>
                                        <tr class="sub">
                                            <td colspan="5">
                                                <div class="collapse">
                                                    <xsl:attribute name="id" select="concat('translation-folios-', position())"/>
                                                    <table class="table table-responsive">
                                                        <thead>
                                                            <tr>
                                                                <th>#</th>
                                                                <th>Folio</th>
                                                                <th>XML</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <xsl:for-each select="m:folios/m:folio">
                                                                <tr>
                                                                    <td class="text-muted">
                                                                        <xsl:value-of select="position()"/>.
                                                                    </td>
                                                                    <td>
                                                                        <xsl:value-of select="concat(@page, '.', @side)"/> 
                                                                    </td>
                                                                    <td>
                                                                        <a target="_blank">
                                                                            <xsl:attribute name="href" select="m:url[@response eq 'xml']"/>
                                                                            <xsl:value-of select="m:url[@response eq 'xml']"/>
                                                                        </a>
                                                                    </td>
                                                                </tr>
                                                            </xsl:for-each>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="2" class="text-right">Total</th>
                                        <td colspan="3">
                                            <xsl:value-of select="format-number(count(m:translations/m:translation/m:folios/m:folio), '#,###')"/>
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
            <xsl:with-param name="page-title" select="'Folios :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Individual Folios'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>