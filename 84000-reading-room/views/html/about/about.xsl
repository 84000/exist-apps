<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../website-page.xsl"/>
    
    <!-- Template -->
    <xsl:template name="about">
        
        <xsl:param name="sub-content"/>
        
        <!-- Content variable -->
        <xsl:variable name="content">
            <div class="container">
                <div class="row">
                    <div class="col-md-9 col-md-merge-right">
                        <div class="panel panel-default panel-about main-panel foreground">
                            
                            <div class="panel-img-header has-img thumbnail">
                                <img data-max-horizontal-crop="50">
                                    <xsl:attribute name="src" select="concat($front-end-path, /m:response/m:app-text[ends-with(@key, 'header-img-src')])"/>
                                </img>
                                <h1>
                                    <xsl:value-of select="/m:response/m:app-text[ends-with(@key, 'title')]"/>
                                </h1>
                            </div>
                            
                            <div class="panel-body">
                                
                                <blockquote>
                                    <xsl:value-of select="/m:response/m:app-text[ends-with(@key, 'quote')]"/>
                                    <footer>
                                        <xsl:value-of select="/m:response/m:app-text[ends-with(@key, 'author')]"/>
                                    </footer>
                                </blockquote>
                                
                                <!-- Passed content -->
                                <xsl:copy-of select="$sub-content"/>
                                
                            </div>
                            
                            <!-- Social sharing -->
                            <div class="panel-footer sharing">
                                <xsl:value-of select="'Share this page: '"/>
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
                                <h3 class="panel-title">Join Us</h3>
                            </div>
                            <div class="panel-body">
                                <p>With the help of our 108 <a href="http://84000.co/about/sponsors/">founding sponsors</a> and thousands of individual donors,
                                    we provide funding to the translators who are working to safeguard these important teachings
                                    for future generations.</p>
                                <table id="translation-stats">
                                    <tbody>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@count, '#,###')"/>
                                            </td>
                                            <th>Total Kangyur Pages</th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@in-translation, '#,###')"/>
                                            </td>
                                            <th>Pages in Translation</th>
                                        </tr>
                                        <tr>
                                            <td>
                                                <xsl:value-of select="format-number(/m:response/m:outline-summary/m:tohs/m:pages/@published, '#,###')"/>
                                            </td>
                                            <th>Pages Published</th>
                                        </tr>
                                    </tbody>
                                </table>
                                <div class="text-center">
                                    <a href="http://84000.co/page-onetime" class="btn btn-primary">Sponsor a page now</a>
                                </div>
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="website-page">
            <xsl:with-param name="page-url" select="concat('http://read.84000.co/', /m:response/@model-type, '.html')"/>
            <xsl:with-param name="page-class" select="'about'"/>
            <xsl:with-param name="page-title" select="concat('84000 | ', /m:response/m:app-text[ends-with(@key, 'title')])"/>
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
                    · 
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
            <span class="text-zh">
                <xsl:value-of select="$text/m:title-variants/m:title[@xml:lang='zh']/text()"/> 
            </span>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>