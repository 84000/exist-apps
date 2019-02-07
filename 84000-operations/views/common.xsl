<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:exslt="http://exslt.org/common" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:template name="operations-page">
        <xsl:param name="reading-room-path" required="yes"/>
        <xsl:param name="active-tab"/>
        <xsl:param name="page-content" required="yes"/>
        
        <div class="container">
            <div class="panel panel-default">
                
                <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                    <span class="title">
                        84000 Operations Reports
                    </span>
                    <span class="text-right">
                        <a target="reading-room">
                            <xsl:attribute name="href" select="$reading-room-path"/>
                            Reading Room
                        </a>
                    </span>
                </div>
                
                <div class="panel-body">
                    
                    <xsl:call-template name="tabs">
                        <xsl:with-param name="active-tab" select="$active-tab"/>
                    </xsl:call-template>
                    
                    <div class="tab-content">
                        <xsl:copy-of select="$page-content"/>
                    </div>
                    
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template name="tabs">
        <xsl:param name="active-tab"/>
        <ul class="nav nav-tabs active-tab-refresh hidden-print" role="tablist">
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/index'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="index.html">
                    <xsl:value-of select="'Summary'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/search'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="search.html?status=none">
                    <xsl:value-of select="'Search'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sponsors'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sponsors.html">
                    <xsl:value-of select="'Sponsors'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translators'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translators.html">
                    <xsl:value-of select="'Translators'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-teams'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-teams.html">
                    <xsl:value-of select="'Translator Teams'"/>
                </a>
            </li>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/translator-institutions'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="translator-institutions.html">
                    <xsl:value-of select="'Translator Institutions'"/>
                </a>
            </li>
            <xsl:if test="$active-tab eq 'operations/edit-text-header'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Text Header'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-sponsors'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-sponsors.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Text Sponsors'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-sponsor'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-sponsor.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Sponsor'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Contributor'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-team'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-team.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Translator Team'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-translator-institution'">
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-translator-institution.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Translator Institution'"/>
                    </a>
                </li>
            </xsl:if>
            <xsl:if test="$active-tab eq 'operations/edit-text-submission'">
                <li role="presentation">
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-header.html?id=', /m:response/m:request/@text-id, '#submissions-form')"/>
                        <xsl:value-of select="'Edit Text Header'"/>
                    </a>
                </li>
                <li role="presentation">
                    <xsl:attribute name="class" select="'active'"/>
                    <a>
                        <xsl:attribute name="href" select="concat('/edit-text-submission.html?id=', /m:response/m:request/@id)"/>
                        <xsl:value-of select="'Edit Submission'"/>
                    </a>
                </li>
            </xsl:if>
        </ul>
        
    </xsl:template>
    
</xsl:stylesheet>