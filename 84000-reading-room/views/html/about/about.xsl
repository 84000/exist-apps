<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:i18n="http://exist-db.org/xquery/i18n" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../website-page.xsl"/>
    <xsl:import href="../../../xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="../../../xslt/lang.xsl"/>
    
    <!-- Template -->
    <xsl:template name="about">
        
        <xsl:param name="sub-content"/>
        
        <!-- Content variable -->
        <xsl:variable name="content">
            <div class="container">
                <div class="row">
                    <div class="col-md-9 col-md-merge-right">
                        <div class="panel panel-default panel-about main-panel foreground">
                            
                            <div class="panel-img-header thumbnail">
                                
                                <xsl:variable name="page-title">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'page-title'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <xsl:variable name="header-img-src">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'header-img-src'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <xsl:if test="$header-img-src">
                                    <xsl:attribute name="class" select="'panel-img-header has-img thumbnail'"/>
                                    <img class="stretch">
                                        <xsl:attribute name="src" select="concat($front-end-path, $header-img-src)"/>
                                        <xsl:attribute name="alt" select="concat($page-title, ' page header image')"/>
                                    </img>
                                </xsl:if>
                                
                                <h1>
                                    <xsl:choose>
                                        <xsl:when test="$page-title">
                                            <xsl:value-of select="$page-title"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'[Error: missing title]'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </h1>
                            </div>
                            
                            <div class="panel-body">
                                
                                <xsl:variable name="page-quote">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'page-quote'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:variable name="page-quote-author">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'page-quote-author'"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                
                                <xsl:if test="$page-quote">
                                    <blockquote>
                                        <xsl:value-of select="$page-quote"/>
                                        <xsl:if test="$page-quote-author">
                                            <footer>
                                                <xsl:value-of select="$page-quote-author"/>
                                            </footer>
                                        </xsl:if>
                                    </blockquote>
                                </xsl:if>
                                
                                <!-- Passed content -->
                                <xsl:copy-of select="$sub-content"/>
                                
                            </div>
                            
                            <!-- Social sharing -->
                            <!-- TO DO: add these urls! -->
                            <div class="panel-footer sharing">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'sharing-label'"/>
                                </xsl:call-template>
                                <a href="#" target="_blank">
                                    <i class="fa fa-facebook-square" aria-hidden="true"/>
                                </a>
                                <a href="#" target="_blank">
                                    <i class="fa fa-twitter-square" aria-hidden="true"/>
                                </a>
                                <a href="#" target="_blank">
                                    <i class="fa fa-google-plus-square" aria-hidden="true"/>
                                </a>
                            </div>
                            
                        </div>
                    </div>
                    <div class="col-md-3 col-md-merge-left col-md-pad-top">
                        
                        <!-- Summary -->
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title">
                                    <xsl:call-template name="local-text">
                                        <xsl:with-param name="local-key" select="'support-label'"/>
                                    </xsl:call-template>
                                </h3>
                            </div>
                            <div class="panel-body">
                                <xsl:call-template name="local-text">
                                    <xsl:with-param name="local-key" select="'support-description'"/>
                                </xsl:call-template>
                                <table id="translation-stats">
                                    <tbody>
                                        <tr>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'kangyur-count-before-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@count, '#,###')"/>
                                            </td>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'kangyur-count-after-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                        </tr>
                                        <tr>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'translation-count-before-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@in-translation, '#,###')"/>
                                            </td>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'translation-count-after-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                        </tr>
                                        <tr>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'published-count-before-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@published, '#,###')"/>
                                            </td>
                                            <xsl:call-template name="local-text-if-exists">
                                                <xsl:with-param name="local-key" select="'published-count-after-label'"/>
                                                <xsl:with-param name="node-name" select="'th'"/>
                                            </xsl:call-template>
                                        </tr>
                                    </tbody>
                                </table>
                                <div class="text-center">
                                    <div>
                                        <a href="http://84000.co/page-onetime" class="btn btn-primary">
                                            <xsl:attribute name="href">
                                                <xsl:call-template name="local-text">
                                                    <xsl:with-param name="local-key" select="'sponsor-button-link'"/>
                                                </xsl:call-template>
                                            </xsl:attribute>
                                            <xsl:call-template name="local-text">
                                                <xsl:with-param name="local-key" select="'sponsor-button-label'"/>
                                            </xsl:call-template>
                                        </a>
                                    </div>
                                    <xsl:variable name="donate-instructions-link">
                                        <xsl:call-template name="local-text">
                                            <xsl:with-param name="local-key" select="'donate-instructions-link'"/>
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:if test="$donate-instructions-link">
                                        <div class="sml-margin top">
                                            <a target="_blank">
                                                <xsl:attribute name="href" select="$donate-instructions-link"/>
                                                <xsl:attribute name="title">
                                                    <xsl:call-template name="local-text">
                                                        <xsl:with-param name="local-key" select="'donate-instructions-link-title'"/>
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                                <xsl:call-template name="local-text">
                                                    <xsl:with-param name="local-key" select="'donate-instructions-label'"/>
                                                </xsl:call-template>
                                            </a>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:variable name="page-title" as="xs:string">
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="'page-title'"/>
            </xsl:call-template>
        </xsl:variable>
        
        
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/', /m:response/@model-type, '.html')"/>
            <xsl:with-param name="page-class" select="'about'"/>
            <xsl:with-param name="page-title" select="concat('84000 | ', $page-title)"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
            <xsl:with-param name="nav-tab" select="'#about'"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="text-list-title">
        
        <xsl:param name="text"/>
        
        <h4 class="title-en">
            <xsl:choose>
                <xsl:when test="$text/@status eq '1'">
                    <a>
                        <xsl:attribute name="href" select="concat('/translation/', $text/m:toh/@key, '.html')"/>
                        <xsl:if test="$text/m:titles/m:parent">
                            <xsl:value-of select="concat($text/m:titles/m:parent/m:title, ', ')"/>
                        </xsl:if>
                        <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$text/m:titles/m:parent">
                        <xsl:value-of select="$text/m:titles/m:parent/m:title"/>, 
                    </xsl:if>
                    <xsl:value-of select="$text/m:titles/m:title[@xml:lang eq 'en']"/>
                </xsl:otherwise>
            </xsl:choose>
        </h4>
    </xsl:template>
    
    <xsl:template name="text-list-subtitles">
        
        <xsl:param name="text"/>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang='bo']/text()">
            <hr/>
            <span class="text-bo">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang='bo']/text()"/>
            </span>
        </xsl:if>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang='bo-ltn']/text()">
            <xsl:choose>
                <xsl:when test="$text/m:titles/m:title[@xml:lang='bo']/text()">
                    <xsl:value-of select="' · '"/>
                </xsl:when>
                <xsl:otherwise>
                    <hr/>
                </xsl:otherwise>
            </xsl:choose>
            <span class="text-wy">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang='bo-ltn']/text()"/>
            </span>
        </xsl:if>
        
        <xsl:if test="$text/m:titles/m:title[@xml:lang='sa-ltn']/text()">
            <hr/>
            <span class="text-sa">
                <xsl:value-of select="$text/m:titles/m:title[@xml:lang='sa-ltn']/text()"/> 
            </span>
        </xsl:if>
        
        <xsl:if test="$text/m:title-variants/m:title[@xml:lang='zh']/text()">
            <hr/>
            <xsl:for-each select="$text/m:title-variants/m:title[@xml:lang='zh']">
                <xsl:if test="position() gt 1">
                    <xsl:value-of select="' · '"/>
                </xsl:if>
                <span class="text-zh">
                    <xsl:value-of select="text()"/> 
                </span>
            </xsl:for-each>
            
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="status-label">
        <xsl:param name="status-group" as="xs:string" required="yes"/>
        <xsl:choose>
            <xsl:when test="$status-group eq 'published'">
                <br/>
                <label class="label label-success">
                    <xsl:value-of select="'Published'"/>
                </label>
            </xsl:when>
            <xsl:when test="$status-group = ('translated', 'in-translation')">
                <br/>
                <label class="label label-warning">
                    <xsl:value-of select="'In-progress'"/>
                </label>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="expandable-summary">
        
        <xsl:param name="text"/>
        
        <xsl:if test="$text/m:summary/tei:p">
            <hr/>
            <a class="summary-link collapsed" role="button" data-toggle="collapse" aria-expanded="false" aria-controls="collapseExample">
                <xsl:attribute name="href" select="concat('#summary-detail-', $text/m:toh/@key)"/>
                <i class="fa fa-chevron-down"/>
                <xsl:value-of select="' '"/>
                <xsl:call-template name="local-text">
                    <xsl:with-param name="local-key" select="'summary-label'"/>
                </xsl:call-template>
            </a>
            
            <div class="collapse summary-detail">
                
                <xsl:attribute name="id" select="concat('summary-detail-', $text/m:toh/@key)"/>
                
                <div class="well well-sm">
                    
                    <xsl:if test="$text/m:summary/tei:p">
                        <xsl:apply-templates select="$text/m:summary/tei:p"/>
                    </xsl:if>
                    
                </div>
            </div>
            
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>