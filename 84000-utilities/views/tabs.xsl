<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
    <xsl:variable name="model-type" select="/m:response/@model-type"/>
    
    <xsl:variable name="tabs">
        <tabs xmlns="http://read.84000.co/ns/1.0">
            <tab page="translations.html" model="utilities/translations">
                <label>Translations</label>
            </tab>
            <tab page="sections.html" model="utilities/sections">
                <label>Sections</label>
            </tab>
            <tab page="folios.html" model="utilities/folios">
                <label>Folios</label>
            </tab>
            <!-- 
            <tab page="glossary-management.html" model="utilities/glossary-management">
                <label>Glossary management</label>
            </tab> -->
            <tab page="tests.html" model="utilities/tests">
                <label>Tests</label>
            </tab>
            <tab page="layout-checks.html" model="utilities/layout-checks">
                <label>Layout Checks</label>
            </tab>
            <tab page="requests.html" model="utilities/requests">
                <label>Page requests</label>
            </tab>
            <tab page="client-errors.html" model="utilities/client-errors">
                <label>Client Errors</label>
            </tab>
            <xsl:if test="$environment/m:snapshot-conf">
                <tab page="snapshot.html" model="utilities/snapshot">
                    <label>Make a data snapshot</label>
                </tab>
            </xsl:if>
            <xsl:if test="$environment/m:deployment-conf and /m:response/@user-name eq 'admin'">
                <tab page="deployment.html" model="utilities/deployment">
                    <label>Deploy the software</label>
                </tab>
            </xsl:if>
            <xsl:if test="/m:response/@user-name eq 'admin'">
                <tab page="reindex.html" model="utilities/reindex">
                    <label>Re-index the data</label>
                </tab>
            </xsl:if>
        </tabs>
    </xsl:variable>
    
    <xsl:template name="header">
        
        <span class="title">
            <xsl:value-of select="concat('84000 Utilities / ', $tabs//m:tab[@model eq $model-type]/m:label)"/>
        </span>
        
        <span>
            <a href="#navigation-sidebar" class="center-vertical together pull-right show-sidebar">
                <span class="btn-round-text">
                    <xsl:value-of select="'Navigation'"/>
                </span>
                <span>
                    <span class="btn-round sml">
                        <i class="fa fa-bars"/>
                    </span>
                </span>
            </a>
        </span>
        
    </xsl:template>
    
    <xsl:template name="tabs">
        
        <xsl:param name="active-tab"/>
        
        <div id="navigation-sidebar" class="fixed-sidebar collapse width hidden-print">
            
            <div class="container">
                <div class="fix-width">
                    <h4 class="uppercase">
                        <xsl:value-of select="'84000 Utilities'"/>
                    </h4>
                    <table class="table table-hover no-border">
                        <tbody>
                            <xsl:for-each select="$tabs//m:tab">
                                <tr>
                                    <xsl:if test="@model eq $model-type">
                                        <xsl:attribute name="class" select="'active'"/>
                                    </xsl:if>
                                    <td>
                                        <a href="translations.html">
                                            <xsl:attribute name="href" select="@page"/>
                                            <xsl:value-of select="m:label"/>
                                        </a>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td>
                                    <a target="reading-room">
                                        <xsl:attribute name="href" select="$reading-room-path"/>
                                        <xsl:value-of select="'Go to the 84000 Reading Room'"/>
                                    </a>
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                    
                </div>
            </div>
            
            <div class="fixed-btn-container close-btn-container right">
                <button type="button" class="btn-round close" aria-label="Close">
                    <span aria-hidden="true">
                        <i class="fa fa-times"/>
                    </span>
                </button>
            </div>
            
        </div>
        
    </xsl:template>
    
</xsl:stylesheet>