<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    <xsl:include href="../../84000-reading-room/xslt/functions.xsl"/>
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
                            
                            <p class="text-muted text-center small">
                                This does not reflect Reading Room site traffic as most requests will be mediated by the CDN.
                                <br/>This will however reflect the full diversity of requests made to the server.
                            </p>
                            
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
                                            <td>
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
                                                <xsl:value-of select="@count"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                            
                            <!-- Pagination -->
                            <xsl:copy-of select="common:pagination(m:requests/@first-record, m:requests/@max-records, m:requests/@count-records)"/>
                            
                        </div>
                        
                    </div>
                    
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Requests :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Log of requests to the Reading Room'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>