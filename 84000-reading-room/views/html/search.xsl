<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../xslt/tei-to-xhtml.xsl"/>
    <xsl:include href="website-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <!-- PAGE CONTENT -->
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold center-vertical">
                        <span>
                            <ul class="breadcrumb">
                                <li>
                                    <a href="/section/lobby.html">
                                        The Lobby
                                    </a>
                                </li>
                            </ul>
                        </span>
                        <span>
                            <div class="pull-right center-vertical">
                                <a href="/section/all-translated.html" class="center-vertical together">
                                    <span>
                                        <span class="btn-round white-red sml">
                                            <i class="fa fa-list"/>
                                        </span>
                                    </span>
                                    <span class="btn-round-text">
                                        View Translated Texts
                                    </span>
                                </a>
                                <span>
                                    <div aria-haspopup="true" aria-expanded="false">
                                        <a href="#bookmarks-sidebar" id="bookmarks-btn" class="show-sidebar center-vertical together">
                                            <span>
                                                <span class="btn-round white-red sml">
                                                    <i class="fa fa-bookmark"/>
                                                    <span class="badge badge-notification">0</span>
                                                </span>
                                            </span>
                                            <span class="btn-round-text">
                                                Bookmarks
                                            </span>
                                        </a>
                                    </div>
                                </span>
                            </div>
                        </span>
                    </div>
                    
                    <div class="panel-body">
                        <div id="title text-center">
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
                        <div id="search-form-container" class="row">
                            
                            <div class="col-md-10 col-md-offset-1 col-lg-8 col-lg-offset-2">
                                
                                <form action="search.html" method="post" class="form-horizontal">
                                    <input type="hidden" name="tab" value="search"/>
                                    <div class="input-group">
                                        <input type="text" name="s" id="search" class="form-control" placeholder="Search" required="required">
                                            <xsl:attribute name="value" select="m:search/m:request/text()"/>
                                        </input>
                                        <span class="input-group-btn">
                                            <button type="submit" class="btn btn-primary">
                                                Search
                                            </button>
                                        </span>
                                    </div>
                                </form>
                                
                                <xsl:choose>
                                    <xsl:when test="m:search/m:results/m:item">
                                        <xsl:variable name="first-record" select="m:search/m:results/@first-record"/>
                                        <xsl:for-each select="m:search/m:results/m:item">
                                            <div class="search-result">
                                                <div class="row">
                                                    
                                                    <div class="col-sm-1 text-muted">
                                                        <xsl:value-of select="$first-record + (position() - 1)"/>.
                                                    </div>
                                                    
                                                    <div class="col-sm-11 col-md-9">
                                                        <a class="title">
                                                            <xsl:attribute name="href" select="m:source/@url"/>
                                                            <xsl:choose>
                                                                <xsl:when test="compare(data(m:source/m:title), data(m:text)) eq 0">
                                                                    <xsl:copy-of select="m:text/node()"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="m:source/m:title/text()"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </a>
                                                    </div>
                                                    
                                                    <div class="col-sm-11 col-sm-offset-1 col-md-2 col-md-offset-0 text-md-right">
                                                        
                                                        <xsl:choose>
                                                            <xsl:when test="m:source[@tei-type eq 'section']">
                                                                <span class="label label-success">
                                                                    Section
                                                                </span>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:call-template name="translation-status">
                                                                    <xsl:with-param name="status" select="m:source/@translation-status"/>
                                                                </xsl:call-template>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </div>
                                                    
                                                </div>
                                                
                                                <div class="row">
                                                    <div class="col-sm-11 col-sm-offset-1 small text-muted">
                                                        in
                                                        <ul class="breadcrumb">
                                                            <xsl:for-each select="m:source/m:parent | m:source/m:parent//m:parent">
                                                                <xsl:sort select="@nesting" order="descending"/>
                                                                <li class="">
                                                                    <xsl:value-of select="m:title[@xml:lang='en']/text()"/>
                                                                </li>
                                                            </xsl:for-each>
                                                        </ul>
                                                    </div>
                                                </div>
                                                
                                                <div class="row">
                                                    <div class="col-sm-11 col-sm-offset-1">
                                                        <xsl:if test="compare(data(m:source/m:title), data(m:text)) ne 0">
                                                            <xsl:copy-of select="m:text/node()"/>
                                                        </xsl:if>
                                                    </div>
                                                </div>
                                                
                                            </div>
                                        </xsl:for-each>
                                        
                                        <!-- Pagination -->
                                        <xsl:copy-of select="common:pagination(m:search/m:results/@first-record, m:search/m:results/@max-records, m:search/m:results/@count-records, concat('&amp;s=', m:search/m:request/text()))"/>
                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <br/>
                                        <p>
                                            No search results
                                        </p>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </div>
                        </div>
                    </div>
                    
                    <div id="bookmarks-sidebar" class="fixed-sidebar collapse width hidden-print">
                        
                        <div class="container">
                            <div class="fix-width">
                                <h4>Bookmarks</h4>
                                <table id="bookmarks-list" class="contents-table">
                                    <tbody/>
                                    <tfoot/>
                                </table>
                            </div>
                        </div>
                        
                        <div class="fixed-btn-container close-btn-container right">
                            <button type="button" class="btn-round close" aria-label="Close">
                                <span aria-hidden="true">
                                    <i class="fa fa-times"/>
                                </span>
                            </button>
                        </div>
                        
                    </div>
                    
                </div>
            </div>
            
        </xsl:variable>
        
        <!-- Compile with page template -->
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/search.html?s=', m:search/m:request/text())"/>
            <xsl:with-param name="page-class" select="'section'"/>
            <xsl:with-param name="page-title" select="concat('Search results for ', m:search/m:request/text())"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="nav-tab" select="'reading-room'"/>
        </xsl:call-template>
            
    </xsl:template>
    
</xsl:stylesheet>