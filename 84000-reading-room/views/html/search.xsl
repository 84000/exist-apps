<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-search.xsl"/>
    <xsl:import href="website-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical-sm full-width">
                        
                        <div>
                            <ul class="breadcrumb">
                                <li>
                                    <a>
                                        <xsl:attribute name="href" select="common:internal-link('/section/lobby.html', (), '', /m:response/@lang)"/>
                                        <xsl:value-of select="'The Collection'"/>
                                    </a>
                                </li>
                                <li>
                                    <h1>
                                        <xsl:value-of select="'Search'"/>
                                    </h1>
                                </li>
                            </ul>
                        </div>
                        
                        <div>
                            <div class="center-vertical pull-right-md">
                                
                                <div>
                                    <a class="center-vertical">
                                        <xsl:attribute name="href" select="common:internal-link('/section/all-translated.html', (), '', /m:response/@lang)"/>
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
                    
                    <div id="title" class="text-center">
                        <div class="row">
                            <div class="col-sm-offset-2 col-sm-8">
                                <div class="title">
                                    <h1>Search The Reading Room</h1>
                                    <hr/>
                                    <p>Our database contains both the translated texts and titles and summaries for other works within the Kangyur and Tengyur where available.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <xsl:call-template name="search">
                        <xsl:with-param name="action" select="'search.html'"/>
                        <xsl:with-param name="lang" select="/m:response/@lang"/>
                    </xsl:call-template>
                    
                </div>
            </div>
            
            <xsl:call-template name="bookmarks-sidebar"/>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/search.html?s=', m:search/m:request/text())"/>
            <xsl:with-param name="page-class" select="'reading-room section'"/>
            <xsl:with-param name="page-title" select="concat('84000 Reading Room | Search results for ', m:search/m:request/text())"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>