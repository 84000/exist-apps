<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:template name="tabs">
        
        <xsl:param name="active-tab"/>
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>

        <ul class="nav nav-tabs active-tab-refresh" role="tablist">
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/translations'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translations.html">
                    Translations
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/sections'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sections.html">
                    Sections
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/folios'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="folios.html">
                    Folios
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/tests'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="tests.html">
                    Tests
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/layout-checks'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="layout-checks.html">
                    Layout Checks
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/requests'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="requests.html">
                    Requests
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'utilities/client-errors'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="client-errors.html">
                    Client Errors
                </a>
            </li>
            <xsl:if test="$environment/m:snapshot-conf">
                <li role="presentation">
                    <xsl:if test="$active-tab eq 'utilities/snapshot'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a href="snapshot.html">
                        Data Snapshot
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$environment/m:deployment-conf">
                <li role="presentation">
                    <xsl:if test="$active-tab eq 'utilities/deployment'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a href="deployment.html">
                        Deploy Code
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'utilities/edit-text-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@id)"/>
                        Edit Text Header
                    </a>
                </li>
            </xsl:if>
        </ul>
        
    </xsl:template>
    
</xsl:stylesheet>