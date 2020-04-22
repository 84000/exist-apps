<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:util="http://exist-db.org/xquery/util" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="website-page.xsl"/>
    
    <!-- Look up environment variables -->
    <xsl:variable name="environment-path" select="if(/m:response/@environment-path)then /m:response/@environment-path else '/db/system/config/db/system/environment.xml'"/>
    <xsl:variable name="environment" select="doc($environment-path)/m:environment"/>
    
    <xsl:template match="/">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        <div>
                            <ul class="breadcrumb">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', ((/m:response/@lang), '')[1])"/>
                                        <xsl:value-of select="'The Collection'"/>
                                    </a>
                                </li>
                                <li>
                                    <h1>
                                        <xsl:value-of select="'Error'"/>
                                    </h1>
                                </li>
                            </ul>
                        </div>
                        <div>
                            <div class="center-vertical pull-right-md">
                                <div>
                                    <a class="center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', ((/m:response/@lang), '')[1])"/>
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-list"/>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'View Published Translations'"/>
                                        </span>
                                    </a>
                                </div>
                                <div>
                                    <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical" role="button" aria-haspopup="true" aria-expanded="false">
                                        <span>
                                            <span class="btn-round sml">
                                                <i class="fa fa-bookmark"/>
                                                <span class="badge badge-notification">0</span>
                                            </span>
                                        </span>
                                        <span class="btn-round-text">
                                            <xsl:value-of select="'Bookmarks'"/>
                                        </span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="content-band">
                <div class="container">
                    <div class="row">
                        <div class="col-md-8 col-lg-9">
                            <h2>Sorry, there was an error</h2>
                            <p>Please select a navigation option above</p>
                            <xsl:if test="$environment/@debug eq '1'">
                                <hr/>
                                <h3>Debug information:</h3>
                                <p class="text-bold">
                                    <xsl:value-of select="exception/path"/>
                                </p>
                                <p>
                                    <xsl:value-of select="exception/message"/>
                                </p>
                            </xsl:if>
                        </div>
                        <div class="col-md-4 col-lg-3">
                            <div id="project-progress">
                                <!-- Project Progress, get from ajax -->
                                <xsl:attribute name="data-onload-replace" select="concat('{&#34;#project-progress&#34;:&#34;', $reading-room-path,'/widget/progress-panel.html#eft-progress-panel&#34;}')"/>                            
                                <div class="panel panel-default">
                                    <div class="panel-body loading"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <xsl:call-template name="bookmarks-sidebar"/>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'reading-room error'"/>
            <xsl:with-param name="page-title" select="'Error | 84000 Translating the Words of the Buddha'"/>
            <xsl:with-param name="page-description" select="'Sorry, there was an error.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- suppress namespace warning -->
    <xsl:template match="dummy">
        <!-- nothing -->
    </xsl:template>
    
</xsl:stylesheet>