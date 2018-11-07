<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
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
                            
                            <ul>
                                <li>
                                    Run TEI Validation
                                    <br/>
                                    <span class="text-muted small">
                                        These pages validate each TEI file against the XML Schema.
                                    </span>
                                    <ul>
                                        <li>
                                            <a href="/validate.html?type=translations" target="validate-translations">Translations</a>
                                        </li>
                                        <li>
                                            <a href="/validate.html?type=sections" target="validate-sections">Sections</a>
                                        </li>
                                        <li>
                                            <a href="/validate.html?type=placeholders&amp;section=O1JC11494" target="validate-kangyur-placeholders">Kangyur placeholders</a>
                                        </li>
                                        <li>
                                            <a href="/validate.html?type=placeholders&amp;section=O1JC7630" target="validate-tengyur-placeholders">Tengyur placeholders</a>
                                        </li>
                                    </ul>
                                </li>
                                <li>
                                    Run Automated Tests
                                    <div class="text-muted small">
                                        These pages runs automated tests on the reading room app and shows the results.
                                        <br/>All texts should pass all tests before a new version is relased.
                                        <br/>
                                        <span class="text-danger">Please use these page sparingly as they use lots of server resources.</span>
                                    </div>
                                    <ul>
                                        <li>
                                            <a href="/test-translations.html" target="test-translations">Translations</a>
                                        </li>
                                        <li>
                                            <a href="/test-sections.html" target="test-sections">Sections</a>
                                        </li>
                                    </ul>
                                </li>
                                <li>
                                    <a target="resources">  
                                        <xsl:attribute name="href" select="$environment/m:url[@id eq 'resources']/text()"/>
                                        84000 Resources
                                    </a>
                                    <p class="text-muted small">
                                        Check the resources browser.
                                    </p>
                                </li>
                                <li>
                                    <a target="server-error">
                                        <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'reading-room']/text(), '/invalid-route.html')"/>
                                        Server Error Page
                                    </a>
                                    <p class="text-muted small">
                                        This is the page returned by a server error.
                                    </p>
                                </li>
                                <li>
                                    <a target="exist-error">
                                        <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'reading-room']/text(), '/translation/invalid-translation.html')"/>
                                        eXist Error Page
                                    </a>
                                    <p class="text-muted small">
                                        This is the page returned by an eXist-db exception.
                                    </p>
                                </li>
                                <li>
                                    <a target="robots">
                                        <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'reading-room']/text(), '/robots.txt')"/>
                                        robots.txt
                                    </a>
                                    <p class="text-muted small">
                                        Check robots.txt definition for directing robots.
                                    </p>
                                </li>
                            </ul>
                            
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Tests :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Test utilities'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>