<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    
    <xsl:template name="search">
        
        <div id="search-form-container" class="row">
            <div class="col-sm-9">
                
                <form action="index.html" method="post" class="form-horizontal">
                    <input type="hidden" name="tab" value="search"/>
                    <div class="input-group">
                        <input type="text" name="search" id="search" class="form-control" placeholder="Search" required="required">
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
                                    
                                    <div class="col-sm-9">
                                        <a>
                                            <xsl:attribute name="href" select="m:source/@url"/>
                                            <xsl:choose>
                                                <xsl:when test="compare(data(m:source), data(m:text)) eq 0">
                                                    <xsl:copy-of select="m:text/node()"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="m:source/text()"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </a>
                                    </div>
                                    
                                    <div class="col-sm-2 text-right">
                                        
                                        <span class="label label-info">
                                            <xsl:choose>
                                                <xsl:when test="m:source[@tei-type eq 'section']">
                                                    Section
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    Text
                                                </xsl:otherwise>
                                            </xsl:choose>
                                             / 
                                            <xsl:choose>
                                                <xsl:when test="m:source[@node-type eq 'title']">
                                                    Title
                                                </xsl:when>
                                                <xsl:when test="m:source[@node-type eq 'author']">
                                                    Author
                                                </xsl:when>
                                                <xsl:when test="m:source[@node-type eq 'edition']">
                                                    Edition
                                                </xsl:when>
                                                <xsl:when test="m:source[@node-type eq 'expan']">
                                                    Abbreviation
                                                </xsl:when>
                                                <xsl:when test="m:source[@node-type eq 'bibl']">
                                                    Bibliography
                                                </xsl:when>
                                                <xsl:when test="m:source[@node-type eq 'gloss']">
                                                    Glossary
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    Text
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </span>
                                    </div>
                                    
                                </div>
                                
                                <xsl:if test="compare(data(m:source), data(m:text)) ne 0">
                                    <div class="row">
                                        <div class="col-sm-9 col-sm-offset-1">
                                            <xsl:copy-of select="m:text/node()"/>
                                        </div>
                                    </div>
                                </xsl:if>
                                
                            </div>
                        </xsl:for-each>
                        
                        <!-- Pagination -->
                        <xsl:copy-of select="common:pagination(m:search/m:results/@first-record, m:search/m:results/@max-records, m:search/m:results/@count-records, concat('&amp;tab=search&amp;search=', m:search/m:request/text()))"/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <br/>
                        <p>
                            No search results
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
            <div class="col-sm-3">
                <div class="well">
                    <p class="small">
                        This is rudimentary, proof-of-concept search functionality. Improvements coming soon!
                    </p>
                </div>
            </div>
        </div>
            
    </xsl:template>
    
</xsl:stylesheet>