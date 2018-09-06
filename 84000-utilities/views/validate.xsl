<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        
                        <span class="title">
                            TEI File Validation
                        </span>
                        
                    </div>
                    
                    <div class="panel-body">
                        
                        <h4>
                            Schema: <xsl:value-of select="m:results/@schema"/>
                            <xsl:if test="m:results/@type eq 'placeholders'">
                                / Section: <xsl:value-of select="m:results/@section"/>
                            </xsl:if>
                        </h4>
                        
                        <table class="table table-responsive table-icons">
                            <tbody>
                                <xsl:for-each select="//m:results/m:tei-validation">
                                    <xsl:sort select="m:result/@status eq 'valid'"/>
                                    <xsl:sort select="@id"/>
                                    <tr class="heading">
                                        <td rowspan="2">
                                            <xsl:choose>
                                                <xsl:when test="m:result/@status eq 'valid'">
                                                    <i class="fa fa-check-circle"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <i class="fa fa-times-circle"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </td>
                                        <td>
                                            <xsl:value-of select="concat(position(), '. ', m:title/text())"/>
                                        </td>
                                    </tr>
                                    <tr class="sub">
                                        <td>
                                            <a class="small">
                                                <xsl:attribute name="href" select="@url"/>
                                                <xsl:attribute name="target" select="@id"/>
                                                <xsl:value-of select="@file-name"/> 
                                            </a>
                                        </td>
                                    </tr>
                                    <xsl:for-each select="m:result/m:error">
                                        <tr class="sub">
                                            <td/>
                                            <td>
                                                <small>
                                                    <strong>Line <xsl:value-of select="@line"/>
                                                    </strong> : <xsl:value-of select="text()"/>
                                                </small>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <div id="popup-footer" class="fixed-footer collapse hidden-print">
                
                <div class="container">
                    <div class="panel">
                        <div class="panel-body">
                            <div class="fix-height data-container">
                                
                            </div>
                        </div>
                    </div>
                </div>
                
                <div id="fixed-footer-close-container" class="fixed-btn-container">
                    <button type="button" class="btn-round close" aria-label="Close">
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
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities tests'"/>
            <xsl:with-param name="page-title" select="'Validation :: 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Validation for TEI Files'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    
    
</xsl:stylesheet>