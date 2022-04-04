<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="/m:response/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="alert alert-info small text-center">
                <p>This does <strong>NOT</strong> reflect Reading Room site traffic as most requests will be mediated by the CDN. This will however reflect the full diversity of requests made to the server.</p>
            </div>
            
            <table class="table table-responsive">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Url</th>
                        <th>Last requested</th>
                        <th>First requested</th>
                        <th>Count</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="m:requests/m:request">
                        <tr>
                            <td class="text-muted">
                                <xsl:value-of select="/m:response/m:requests/@first-record + (position() - 1)"/>.
                            </td>
                            <td class="wrap">
                                <xsl:value-of select="@request-string"/>
                            </td>
                            <td class="nowrap">
                                <xsl:value-of select="@latest"/>
                            </td>
                            <td class="nowrap">
                                <xsl:value-of select="@first"/>
                            </td>
                            <td class="nowrap">
                                <xsl:value-of select="format-number(@count, '#,###')"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
            
            <!-- Pagination -->
            <xsl:copy-of select="common:pagination(m:requests/@first-record, m:requests/@max-records, m:requests/@count-records, 'requests.html')"/>
            
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Requests | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Log of requests to the Reading Room'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>