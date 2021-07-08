<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment" select="if(/m:response[m:environment]) then /m:response/m:environment else doc('/db/system/config/db/system/environment.xml')/m:environment"/>

    <xsl:template match="/">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        <nav role="navigation" aria-label="Breadcrumbs">
                            <ul class="breadcrumb">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', ((/m:response/@lang), '')[1])"/>
                                        <xsl:value-of select="'The Collection'"/>
                                    </a>
                                </li>
                                <li class="title">
                                    <xsl:value-of select="'Error'"/>
                                </li>
                            </ul>
                        </nav>
                        <div>
                            <div class="center-vertical pull-right">
                                <div>
                                    <a class="center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', ((/m:response/@lang), '')[1])"/>
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Published Translations'"/>
                                        </span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Include .client-error to do a client side error log -->
            <div class="content-band client-error">
                <div class="container">
                    <div class="row">
                        <main class="col-md-8 col-lg-9">
                            <h1>Sorry, there was an error</h1>
                            <p>Please select a navigation option above</p>
                            <xsl:if test="$environment/@debug eq '1'">
                                <hr/>
                                <h2>Debug information:</h2>
                                <p class="text-bold">
                                    <xsl:value-of select="exception/path"/>
                                </p>
                                <p>
                                    <xsl:value-of select="exception/message"/>
                                </p>
                            </xsl:if>
                        </main>
                        <aside class="col-md-4 col-lg-3">
                            <div id="project-progress">
                                <!-- Project Progress, get from ajax -->
                                <xsl:attribute name="data-onload-replace">
                                    <xsl:value-of select="concat('{&#34;#project-progress&#34;:&#34;', $environment/m:url[@id eq 'reading-room'],'/widget/progress-chart.html#eft-progress-chart-panel&#34;}')"/>
                                </xsl:attribute>                            
                                <div class="panel panel-default">
                                    <div class="panel-body loading"/>
                                </div>
                            </div>
                        </aside>
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'reading-room error'"/>
            <xsl:with-param name="page-title" select="'Error | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="'Sorry, there was an error.'"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="additional-links">
                <script src="https://code.highcharts.com/highcharts.js"/>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- suppress namespace warning -->
    <xsl:template match="dummy">
        <!-- nothing -->
    </xsl:template>
    
</xsl:stylesheet>