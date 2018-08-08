<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:template name="search">
            
        <div id="search-form-container" class="row">
            <div class="col-sm-8">
                <br/>
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
                <br/>
                <xsl:choose>
                    <xsl:when test="m:search/m:results/m:item">
                        
                        <xsl:for-each select="m:search/m:results/m:item">
                            <div class="search-result">
                                <p class="title">
                                    <a>
                                        <xsl:attribute name="href" select="m:source/@url"/>
                                        <xsl:value-of select="m:source/text()"/>
                                    </a>
                                     
                                    <xsl:choose>
                                        <xsl:when test="m:source[@type eq 'title']">
                                            <span class="label label-default">Title</span>
                                        </xsl:when>
                                        <xsl:when test="m:source[@type eq 'author']">
                                            <span class="label label-default">Author</span>
                                        </xsl:when>
                                        <xsl:when test="m:source[@type eq 'edition']">
                                            <span class="label label-default">Edition</span>
                                        </xsl:when>
                                        <xsl:when test="m:source[@type eq 'expan']">
                                            <span class="label label-default">Abbreviation</span>
                                        </xsl:when>
                                        <xsl:when test="m:source[@type eq 'bibl']">
                                            <span class="label label-default">Bibliography</span>
                                        </xsl:when>
                                        <xsl:when test="m:source[@type eq 'gloss']">
                                            <span class="label label-default">Glossary</span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="label label-default">Text</span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </p>
                                <p>
                                    <xsl:copy-of select="m:text/node()"/>
                                </p>
                            </div>
                        </xsl:for-each>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            No search results
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
            <div class="col-sm-offset-1 col-sm-3">
                <div class="well">
                    <p class="small">
                        This is rudimentary, proof-of-concept search functionality. Improvements coming soon!
                    </p>
                </div>
            </div>
        </div>
            
    </xsl:template>
    
</xsl:stylesheet>