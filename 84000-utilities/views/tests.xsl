<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="tabs.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="environment" select="doc(/m:response/@environment-path)/m:environment"/>
        <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()"/>
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <xsl:call-template name="header"/>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:call-template name="tabs">
                            <xsl:with-param name="active-tab" select="@model-type"/>
                        </xsl:call-template>
                        
                        <div class="tab-content">
                            <div class="row">
                                <div class="col-sm-6 col-sm-offset-3">
                                    <div class="alert alert-info small text-center">
                                        <p>
                                            <xsl:value-of select="'Each new release of the software should be validated against these tests.'"/>
                                        </p>
                                    </div>
                                    <ul>
                                        <li>
                                            <xsl:value-of select="'Run TEI Validation'"/>
                                            <br/>
                                            <span class="text-muted small">
                                                <xsl:value-of select="'These pages validate each TEI file against the XML Schema.'"/>
                                            </span>
                                            <ul>
                                                <li>
                                                    <a href="/validate.html?type=translations" target="validate-translations">
                                                        <xsl:value-of select="'Translations'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="/validate.html?type=sections" target="validate-sections">
                                                        <xsl:value-of select="'Sections'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="/validate.html?type=placeholders&amp;section=O1JC11494" target="validate-kangyur-placeholders">
                                                        <xsl:value-of select="'Kangyur placeholders'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="/validate.html?type=placeholders&amp;section=O1JC7630" target="validate-tengyur-placeholders">
                                                        <xsl:value-of select="'Tengyur placeholders'"/>
                                                    </a>
                                                </li>
                                            </ul>
                                        </li>
                                        <li>
                                            <xsl:value-of select="'Run Automated Tests'"/>
                                            
                                            <div class="text-muted small">
                                                <xsl:value-of select="'These pages runs automated tests on the reading room app and shows the results.'"/>
                                                <br/>
                                                <xsl:value-of select="'All texts should pass all tests before a new version is relased.'"/>
                                                <br/>
                                                <span class="text-danger">
                                                    <xsl:value-of select="'Please use these page sparingly as they use lots of server resources.'"/>
                                                </span>
                                            </div>
                                            <ul>
                                                <li>
                                                    <a href="/test-translations.html" target="test-translations">
                                                        <xsl:value-of select="'Translations'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="/test-sections.html" target="test-sections">
                                                        <xsl:value-of select="'Sections'"/>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="/test-searches.html" target="test-searches">
                                                        <xsl:value-of select="'Searches'"/>
                                                    </a>
                                                </li>
                                            </ul>
                                        </li>
                                        <li>
                                            <a target="resources">  
                                                <xsl:attribute name="href" select="$environment/m:url[@id eq 'resources']/text()"/>
                                                <xsl:value-of select="'84000 Resources'"/>
                                            </a>
                                            <p class="text-muted small">
                                                <xsl:value-of select="'Check the resources browser.'"/>
                                            </p>
                                        </li>
                                        <li>
                                            <a target="server-error">
                                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'reading-room']/text(), '/invalid-route.html')"/>
                                                <xsl:value-of select="'Server Error Page'"/>
                                            </a>
                                            <p class="text-muted small">
                                                <xsl:value-of select="'This is the page returned by a server error.'"/>
                                            </p>
                                        </li>
                                        <li>
                                            <a target="exist-error">
                                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'reading-room']/text(), '/translation/invalid-translation.html')"/>
                                                <xsl:value-of select="'eXist Error Page'"/>
                                            </a>
                                            <p class="text-muted small">
                                                <xsl:value-of select="'This is the page returned by an eXist-db exception.'"/>
                                            </p>
                                        </li>
                                        <li>
                                            <a target="robots">
                                                <xsl:attribute name="href" select="concat($environment/m:url[@id eq 'reading-room']/text(), '/robots.txt')"/>
                                                <xsl:value-of select="'robots.txt'"/>
                                            </a>
                                            <p class="text-muted small">
                                                <xsl:value-of select="'Check robots.txt definition for directing robots.'"/>
                                            </p>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Tests | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Test utilities'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
</xsl:stylesheet>