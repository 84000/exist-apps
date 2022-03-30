<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()" as="xs:string"/>
    <xsl:variable name="response-model" select="/m:response/@model" as="xs:string"/>
    
    <xsl:variable name="tabs">
        <tabs xmlns="http://read.84000.co/ns/1.0">
            <tab page="translations.html" model="utilities/translations">
                <label>Translations</label>
            </tab>
            <tab page="sections.html" model="utilities/sections">
                <label>Sections</label>
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
            <xsl:if test="$environment/m:git-config/m:pull/m:repo and /m:response/m:request/m:authenticated-user/m:group[@name eq 'dba']">
                <tab page="git-pull.html" model="utilities/git-pull">
                    <label>Pull latest files from the Git repository</label>
                </tab>
            </xsl:if>
            <xsl:if test="/m:response/m:request/m:authenticated-user/m:group[@name eq 'dba']">
                <tab page="reindex.html" model="utilities/reindex">
                    <label>Re-index the data</label>
                </tab>
            </xsl:if>
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
        
        <xsl:copy-of select="$page-alert"/>
        
        <div class="title-band">
            <div class="container">
                <div class="center-vertical full-width">
                    <span class="logo">
                        <img alt="84000 logo">
                            <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                        </img>
                    </span>
                    <span>
                        <h1 class="title">
                            <xsl:value-of select="concat('Utilities / ', $tabs//m:tab[@model eq $response-model]/m:label)"/>
                        </h1>
                    </span>
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
                    <xsl:copy-of select="$content"/>
                </div>
            </div>
        </div>
        
        <!-- Sidebar -->
        <div id="navigation-sidebar" class="fixed-sidebar collapse width hidden-print">
            
            <div class="fix-width">
                <div class="sidebar-content">
                    
                    <h4 class="uppercase">
                        <xsl:value-of select="'84000 Utilities'"/>
                    </h4>
                    <table class="table table-hover no-border">
                        <tbody>
                            <xsl:for-each select="$tabs//m:tab[@page]">
                                <tr class="vertical-middle">
                                    <xsl:if test="@model eq $response-model">
                                        <xsl:attribute name="class" select="'vertical-middle active'"/>
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
                <button type="button" class="btn-round close close-collapse" aria-label="Close">
                    <span aria-hidden="true">
                        <i class="fa fa-times"/>
                    </span>
                </button>
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
        
        <!-- Pop-up footer  -->
        <div id="popup-footer" class="fixed-footer collapse persist hidden-print">
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
        
        <!-- Source pop-up -->
        <div id="popup-footer-source" class="fixed-footer collapse hidden-print">
            <div class="fix-height">
                <div class="data-container">
                    <!-- Ajax data here -->
                    <div class="ajax-target"/>
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
    
</xsl:stylesheet>