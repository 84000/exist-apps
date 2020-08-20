<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:exslt="http://exslt.org/common" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment" as="element(m:environment)"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()" as="xs:string"/>
    
    <!-- Page header -->
    <xsl:template name="operations-page">
        <xsl:param name="active-tab"/>
        <xsl:param name="page-content" required="yes"/>
        
        <div class="title-band hidden-print">
            <div class="container">
                <div class="center-vertical full-width">
                    <span class="logo">
                        <img alt="84000 logo">
                            <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                        </img>
                    </span>
                    <span>
                        <h1>
                            <xsl:value-of select="'Project Management'"/>
                        </h1>
                    </span>
                    <span class="text-right">
                        <a target="reading-room">
                            <xsl:attribute name="href" select="$reading-room-path"/>
                            <xsl:value-of select="'Reading Room'"/>
                        </a>
                    </span>
                </div>
            </div>
        </div>
        
        <div class="content-band">
            <div class="container">
                <xsl:call-template name="tabs">
                    <xsl:with-param name="active-tab" select="$active-tab"/>
                </xsl:call-template>
                <div class="tab-content">
                    <xsl:copy-of select="$page-content"/>
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
        
        <!-- Source pop-up -->
        <div id="popup-footer-source" class="fixed-footer collapse hidden-print">
            <div class="fix-height">
                <div class="data-container">
                    <!-- Ajax data here -->
                </div>
            </div>
            <div class="fixed-btn-container close-btn-container">
                <button type="button" class="btn-round close close-collapse" aria-label="Close">
                    <span aria-hidden="true">
                        <i class="fa fa-times"/>
                    </span>
                </button>
            </div>
        </div>
        
    </xsl:template>
    
    <!-- Generic alert -->
    <xsl:template name="alert-updated">
        <xsl:if test="m:updates/m:updated[@update]">
            <div class="alert alert-success alert-temporary" role="alert">
                <xsl:value-of select="'Updated'"/>
            </div>
            <!--<xsl:if test="/m:response/@model-type eq 'operations/edit-text-header'">-->
                <xsl:choose>
                    <xsl:when test="m:updates/m:updated[@update][@node eq 'text-version']">
                        <div class="alert alert-warning" role="alert">
                            <xsl:value-of select="'The version number has been updated'"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="alert alert-danger" role="alert">
                            <xsl:value-of select="'To ensure these updates are deployed to the distribution server please update the version in the status section!!'"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            <!--</xsl:if>-->
        </xsl:if>
    </xsl:template>
    
    <!-- Alert if translation is locked -->
    <xsl:template name="alert-translation-locked">
        <xsl:if test="m:translation/@locked-by-user gt ''">
            <div class="alert alert-danger" role="alert">
                <xsl:value-of select="concat('File ', m:translation/@document-url, ' is currenly locked by user ', m:translation/@locked-by-user, '. ')"/>
                <xsl:value-of select="'You cannot modify this file until the lock is released.'"/>
            </div>
        </xsl:if>
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
                <a href="search.html">
                    <xsl:value-of select="'Search'"/>
                </a>
            </li>
            <!--<li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sections'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sections.html">
                    <xsl:value-of select="'Sections'"/>
                </a>
            </li>-->
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
                    <xsl:value-of select="'Contributors'"/>
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
            <xsl:if test="$active-tab eq 'operations/glossary'">
                <li role="presentation">
                    <xsl:if test="$active-tab eq 'operations/glossary'">
                        <xsl:attribute name="class" select="'active'"/>
                    </xsl:if>
                    <a>
                        <xsl:choose>
                            <xsl:when test="/m:response/m:request/@resource-id gt ''">
                                <xsl:attribute name="href" select="concat('/glossary.html?resource-id=', /m:response/m:request/@resource-id)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href" select="'/glossary.html'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="'Glossary'"/>
                    </a>
                </li>
            </xsl:if>
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
                        <xsl:attribute name="href" select="concat('/edit-text-submission.html?text-id=', /m:response/m:request/@text-id, '&amp;submission-id=', /m:response/m:request/@submission-id)"/>
                        <xsl:value-of select="'Edit Submission'"/>
                    </a>
                </li>
            </xsl:if>
            <li role="presentation">
                <xsl:if test="$active-tab eq 'operations/sys-config'">
                    <xsl:attribute name="class" select="'active'"/>
                </xsl:if>
                <a href="sys-config.html">
                    <xsl:value-of select="'System Config'"/>
                </a>
            </li>
        </ul>
        
    </xsl:template>
    
</xsl:stylesheet>