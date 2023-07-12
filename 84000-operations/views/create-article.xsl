<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="'operations/knowledgebase'"/>
                
                <xsl:with-param name="tab-content">
                    <div id="ajax-source" class="row data-container">
                        <div class="col-sm-8 col-sm-offset-2">
                            
                            <form action="/create-article.html" method="post" id="new-article-form" class="text-center top-margin bottom-margin" data-loading="Creating a file for this article...">
                                <xsl:attribute name="data-ajax-target" select="'#new-article-form'"/>
                                
                                <input type="hidden" name="form-action" value="create-article"/>
                                
                                <div class="input-group">
                                    <label for="title" class="input-group-addon control-label">Title: </label>
                                    <input type="text" name="title" id="title" class="form-control" size="70"/>
                                    <div class="input-group-btn">
                                        <button type="submit" class="btn btn-primary">Create an article</button>
                                    </div>
                                </div>
                                
                            </form>
                            
                            <p class="text-warning small text-center top-margin bottom-margin">
                                <xsl:value-of select="'Think carefully about the title of the article now as the file will be created with this name.'"/>
                                <br/>
                                <xsl:value-of select="'Consider what other, similar articles may be added, being as specific and brief as possible with this one.'"/>
                            </p>
                
                        </div>
                    </div>
                </xsl:with-param>
                
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Start a knowledege base article'"/>
            <xsl:with-param name="page-description" select="'84000 Knowledege Base'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>