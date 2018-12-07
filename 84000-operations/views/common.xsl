<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:exslt="http://exslt.org/common" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:template name="tabs">
        <xsl:param name="active-tab"/>
        <ul class="nav nav-tabs" role="tablist">
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/index'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="index.html">
                    Summary
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/search'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="search.html?status=none">
                    Search
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sponsors'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sponsors.html">
                    Sponsors
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translators'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translators.html">
                    Translators
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-teams'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-teams.html">
                    Translator Teams
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-institutions'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-institutions.html">
                    Translator Institutions
                </a>
            </li>
            <xsl:if test="$active-tab eq 'operations/edit-text-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@id)"/>
                        Edit Text Header
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-sponsors'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', /m:response/m:request/@id)"/>
                        Edit Text Sponsors
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-sponsor'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-sponsor.html?id=', /m:response/m:request/@id)"/>
                        Edit Sponsor
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', /m:response/m:request/@id)"/>
                        Edit Contributor
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-team'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', /m:response/m:request/@id)"/>
                        Edit Translator Team
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-institution'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', /m:response/m:request/@id)"/>
                        Edit Translator Institution
                    </a>
                </li>
            </xsl:if>
        </ul>
    </xsl:template>
    
    <xsl:template name="link-to-top">
        <!-- Link to top of page -->
        <div class="hidden-print">
            <div id="link-to-top-container" class="fixed-btn-container">
                <a href="#top" id="link-to-top" class="btn-round scroll-to-anchor" title="Return to the top of the page">
                    <i class="fa fa-arrow-up" aria-hidden="true"/>
                </a>
            </div>
        </div>
    </xsl:template>
    
</xsl:stylesheet>