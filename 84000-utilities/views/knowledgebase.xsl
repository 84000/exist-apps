<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="utilities-path" select="$environment/m:url[@id eq 'utilities']/text()"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="collapse" id="new-page-form-container">
                <form action="knowledgebase.html" method="post" class="form-inline text-center bottom-margin">
                    <input type="hidden" name="form-action" value="new-page"/>
                    <div class="form-group">
                        <div class="input-group">
                            <label class="input-group-addon">
                                <xsl:value-of select="'Title: '"/>
                            </label>
                            <input type="text" name="title" class="form-control" id="title" size="70"/>
                            <div class="input-group-btn">
                                <button type="submit" class="btn btn-primary">
                                    <xsl:value-of select="'Create new page'"/>
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            
            <table class="table table-responsive">
                <thead>
                    <tr>
                        <th>
                            <span>
                                <xsl:value-of select="'Title'"/>
                            </span>
                        </th>
                        <td class="text-right">
                            <a href="#new-page-form-container" data-toggle="collapse">
                                <xsl:value-of select="'Add a new page'"/>
                            </a>
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="m:knowledgebase/m:page">
                        <xsl:sort select="m:sort-name"/>
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                </tbody>
            </table>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Knowledgebase Pages | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Utilities for Knowledgebase Pages'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template match="m:page[parent::m:knowledgebase]">
        <xsl:variable name="page-id" select="concat('page-', fn:encode-for-uri(@xml:id))"/>
        <tr>
            <td colspan="2">
                <div>
                    <span class="text-bold">
                        <xsl:value-of select="m:titles/m:title[@xml:lang eq 'en']"/>
                    </span>
                    <small>
                        <xsl:value-of select="concat(' / ', @kb-id)"/>
                    </small>
                </div>
                <ul class="list-inline inline-dots sml-margin bottom">
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.tei')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.tei')"/>
                            <span class="small">
                                <xsl:value-of select="'tei'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.xml')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.xml')"/>
                            <span class="small">
                                <xsl:value-of select="'xml'"/>
                            </span>
                        </a>
                    </li>
                    <li>
                        <a>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', @kb-id, '.html')"/>
                            <xsl:attribute name="target" select="concat(@kb-id, '.html')"/>
                            <span class="small">
                                <xsl:value-of select="'html'"/>
                            </span>
                        </a>
                    </li>
                </ul>
                <div class="small text-muted">
                    <xsl:value-of select="concat('File: ', @uri)"/>
                </div>
            </td>
        </tr>
        
    </xsl:template>
    
    
</xsl:stylesheet>