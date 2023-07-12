<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/webpage.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container text-center">
                    <h1 class="title">
                        <xsl:value-of select="'84000 Progress Panel'"/>
                    </h1>
                </div>
            </div>
            
            <main class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-sm-offset-4 col-sm-4 top-margin">
                            <div id="eft-progress-panel" class="panel panel-default">
                                <div class="panel-heading">
                                    <h3 class="panel-title">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'support-label'"/>
                                        </xsl:call-template>
                                    </h3>
                                </div>
                                <div id="eft-progress-panel-body" class="panel-body">
                                    <div id="eft-progress-panel-content">
                                        
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'support-description'"/>
                                        </xsl:call-template>
                                        
                                        <xsl:variable name="publications-summary" select="m:translation-summary/m:publications-summary[@grouping eq 'toh'][@scope eq 'descendant']"/>
                                        
                                        <table class="translation-stats">
                                            <tbody>
                                                <tr>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'published-count-before-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                    <td>
                                                        <xsl:value-of select="format-number($publications-summary/m:pages/@published, '#,###')"/>
                                                    </td>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'published-count-after-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                </tr>
                                                
                                                <tr>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'translation-count-before-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                    <td>
                                                        <xsl:value-of select="format-number($publications-summary/m:pages/@translated, '#,###')"/>
                                                    </td>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'translated-count-after-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                </tr>
                                                <tr>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'translation-count-before-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                    <td>
                                                        <xsl:value-of select="format-number($publications-summary/m:pages/@in-translation, '#,###')"/>
                                                    </td>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'translation-count-after-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                </tr>
                                                <tr>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'kangyur-count-before-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                    <td>
                                                        <xsl:value-of select="format-number($publications-summary/m:pages/@total, '#,###')"/>
                                                    </td>
                                                    <xsl:call-template name="local-text-if-exists">
                                                        <xsl:with-param name="local-key" select="'kangyur-count-after-label'"/>
                                                        <xsl:with-param name="node-name" select="'th'"/>
                                                    </xsl:call-template>
                                                </tr>
                                                
                                            </tbody>
                                        </table>
                                        
                                        <div class="text-center">
                                            <div>
                                                <a class="btn btn-warning uppercase">
                                                    <xsl:attribute name="href">
                                                        <xsl:call-template name="local-text">
                                                            <xsl:with-param name="local-key" select="'sponsor-button-link'"/>
                                                        </xsl:call-template>
                                                    </xsl:attribute>
                                                    <xsl:call-template name="local-text">
                                                        <xsl:with-param name="local-key" select="'sponsor-button-label'"/>
                                                    </xsl:call-template>
                                                </a>
                                            </div>
                                            <xsl:variable name="donate-instructions-link">
                                                <xsl:call-template name="local-text">
                                                    <xsl:with-param name="local-key" select="'donate-instructions-link'"/>
                                                </xsl:call-template>
                                            </xsl:variable>
                                            <xsl:if test="$donate-instructions-link gt ''">
                                                <div class="sml-margin top">
                                                    <a target="_blank">
                                                        <xsl:attribute name="href" select="$donate-instructions-link"/>
                                                        <xsl:attribute name="title">
                                                            <xsl:call-template name="local-text">
                                                                <xsl:with-param name="local-key" select="'donate-instructions-link-title'"/>
                                                            </xsl:call-template>
                                                        </xsl:attribute>
                                                        <xsl:call-template name="local-text">
                                                            <xsl:with-param name="local-key" select="'donate-instructions-label'"/>
                                                        </xsl:call-template>
                                                    </a>
                                                </div>
                                            </xsl:if>
                                        </div>
                                    
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
            
        </xsl:variable>
        
        <xsl:call-template name="widget-page">
            <xsl:with-param name="page-url" select="'https://read.84000.co/widget/progress-panel.html'"/>
            <xsl:with-param name="page-class" select="''"/>
            <xsl:with-param name="page-title" select="'Progress Summary | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="'Overview of the current status of the 84000 project'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
                
    </xsl:template>
</xsl:stylesheet>