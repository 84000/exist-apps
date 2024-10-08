<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xf="http://exist-db.org/xquery/file" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="response-model" select="/m:response/@model" as="xs:string"/>
    
    <xsl:variable name="tabs">
        <tabs xmlns="http://read.84000.co/ns/1.0">
            <tab page="translations.html" model="utilities/translations">
                <label>Translations</label>
            </tab>
            <tab page="sections.html" model="utilities/sections">
                <label>Catalogue Sections</label>
            </tab>
            <tab page="knowledgebase.html" model="utilities/knowledgebase">
                <label>Knowledge Base Articles</label>
            </tab>
            <tab page="folios.html" model="utilities/folios">
                <label>Folios</label>
            </tab>
            <tab page="linked-texts.html" model="utilities/linked-texts">
                <label>Linked Texts</label>
            </tab>
            <tab page="cross-references.html" model="utilities/cross-references">
                <label>Cross-references</label>
            </tab>
            <tab page="tests.html" model="utilities/tests">
                <label>Tests</label>
            </tab>
            <!--<tab page="layout-checks.html" model="utilities/layout-checks">
                <label>Layout Checks</label>
            </tab>-->
            <tab page="requests.html" model="utilities/requests">
                <label>Page requests</label>
            </tab>
            <tab page="client-errors.html" model="utilities/client-errors">
                <label>Client Errors</label>
            </tab>
            <xsl:if test="$environment/m:git-config/m:push/m:repo and /m:response/m:request/m:authenticated-user/m:group[@name eq 'git-push']">
                <tab page="git-push.html" model="utilities/git-push">
                    <label>Push updated files to the Git repository</label>
                </tab>
            </xsl:if>
            <xsl:if test="$environment/m:git-config/m:pull/m:repo and /m:response/m:request/m:authenticated-user/m:group[@name eq 'git-push']">
                <tab page="git-pull.html" model="utilities/git-pull">
                    <label>Pull latest files from the Git repository</label>
                </tab>
            </xsl:if>
            <xsl:if test="/m:response/m:request/m:authenticated-user/m:group[@name eq 'dba']">
                <tab page="reindex.html" model="utilities/reindex">
                    <label>Re-index the data</label>
                </tab>
            </xsl:if>
            <tab model="utilities/test-functions">
                <label>Automated Tests on Xquery functions</label>
            </tab>
            <tab model="utilities/test-translations">
                <label>Automated Tests on Translations</label>
            </tab>
            <tab model="utilities/test-sections">
                <label>Automated Tests on Sections</label>
            </tab>
            <tab model="utilities/text-searches">
                <label>Automated Tests on Full-text Searches</label>
            </tab>
            <tab model="utilities/validate">
                <label>TEI File Validation</label>
            </tab>
            <tab model="utilities/section-texts">
                <label>Texts in a Section</label>
            </tab>
        </tabs>
    </xsl:variable>
    
    <xsl:template name="utilities-page">
        
        <xsl:param name="content"/>
        <xsl:param name="page-alert"/>
        
        <xsl:sequence select="$page-alert"/>
        
        <div class="title-band">
            <div class="container">
                <div class="center-vertical full-width">
                    <div class="logo">
                        <img alt="84000 logo">
                            <xsl:attribute name="src" select="'/frontend/imgs/84000-logo.png'"/>
                        </img>
                    </div>
                    <div>
                        <nav role="navigation" aria-label="Breadcrumbs">
                            <ul class="breadcrumb">
                                
                                <li>
                                    <a href="/index.html">
                                        <h1 class="title">
                                            <xsl:value-of select="'Publishing Utilities'"/>
                                        </h1>
                                    </a>
                                </li>
                                
                                <xsl:variable name="tab-selected" select="$tabs//m:tab[@model eq $response-model]"/>
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="$tab-selected[@page]">
                                            <a>
                                                <xsl:attribute name="href" select="$tab-selected/@page"/>
                                                <xsl:attribute name="data-loading" select="'Loading ' || $tab-selected/m:label/data() || '...'"/>
                                                <xsl:value-of select="$tab-selected/m:label"/>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$tab-selected/m:label"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </li>
                                
                            </ul>
                        </nav>
                    </div>
                    <span>
                        <a href="#navigation-sidebar" class="center-vertical align-right show-sidebar">
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
                </div>
            </div>
        </div>
        
        <div class="content-band">
            <div class="container">
                <div class="tab-content">
                    <xsl:sequence select="$content"/>
                </div>
            </div>
        </div>
        
        <!-- Sidebar -->
        <div id="navigation-sidebar" class="fixed-sidebar collapse width hidden-print">
            
            <div class="fix-width">
                <div class="sidebar-content">
                    
                    <h4 class="hidden">
                        <xsl:value-of select="'84000 Publishing Utilities'"/>
                    </h4>
                    
                    <table class="table table-hover no-border">
                        <tbody>
                            <xsl:for-each select="$tabs//m:tab[@page]">
                                <tr>
                                    <xsl:if test="@model eq $response-model">
                                        <xsl:attribute name="class" select="'vertical-middle active'"/>
                                    </xsl:if>
                                    <td>
                                        <a>
                                            <xsl:attribute name="href" select="@page"/>
                                            <xsl:attribute name="data-loading" select="'Loading ' || m:label/data() || '...'"/>
                                            <xsl:value-of select="m:label"/>
                                        </a>
                                    </td>
                                </tr>
                            </xsl:for-each>
                            <tr>
                                <td>
                                    <a target="reading-room">
                                        <xsl:attribute name="href" select="$reading-room-path"/>
                                        <xsl:value-of select="'Go to the 84000 Reading Room'"/>
                                    </a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    
                </div>
            </div>
            
            <div class="fixed-btn-container close-btn-container right">
                <button type="button" class="btn-round close close-collapse" aria-label="Close">
                    <span aria-hidden="true">
                        <i class="fa fa-times"/>
                    </span>
                </button>
            </div>
            
        </div>
        
        <!-- Pop-up footer  -->
        <div id="popup-footer-text" class="fixed-footer collapse persist hidden-print">
            <div class="fix-height">
                <div class="container">
                    <div class="data-container">
                        <!-- Ajax data here -->
                    </div>
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
        
        <!-- Pop-up for tei-editor -->
        <div id="popup-footer-editor" class="fixed-footer collapse hidden-print">
            <div class="fix-height">
                <div class="container">
                    <div class="data-container">
                        <!-- Ajax data here -->
                    </div>
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
    
    <xsl:template name="exec-output">
        
        <xsl:param name="output"/>
        
        <xsl:for-each select="$output">
            <xsl:choose>
                <xsl:when test="self::execution">
                    <strong>
                        <xsl:value-of select="concat($environment/m:label, '$ ', commandline/text())"/>
                    </strong>
                    <br/>
                    <xsl:for-each select="stdout/line">
                        <xsl:value-of select="concat('  ', text())"/>
                        <br/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="self::xf:sync">
                    <strong>
                        <xsl:value-of select="concat('Sync: ', @collection)"/>
                    </strong>
                    <br/>
                    <xsl:choose>
                        <xsl:when test="xf:update">
                            <xsl:for-each select="xf:update">
                                <xsl:value-of select="concat('Updated: ', @name)"/>
                                <br/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'No updates'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="self::m:debug">
                    <xsl:if test="m:command">
                        <strong>
                            <xsl:value-of select="concat($environment/m:label, '$ ', m:command)"/>
                        </strong>
                        <br/>
                    </xsl:if>
                    <xsl:for-each select="m:output">
                        <xsl:value-of select="text()"/>
                        <br/>
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>
            <hr/>
        </xsl:for-each>
        
    </xsl:template>
    
</xsl:stylesheet>