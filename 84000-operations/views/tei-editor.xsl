<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="section" select="m:knowledgebase//*[(@xml:id, @id) = /m:response/m:request/@section-id][not(m:part)][not(tei:div)]"/>
        <xsl:variable name="sibling" select="m:knowledgebase//*[(@xml:id, @id) = /m:response/m:request/@sibling-id][not(m:part)][not(tei:div)]"/>
        <xsl:variable name="section-part" select="($section/ancestor-or-self::m:part[@type], $sibling/ancestor-or-self::m:part[@type])[1]"/>
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model-type"/>
                <xsl:with-param name="page-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <xsl:if test="m:validation//*:status[text() eq 'invalid']">
                        <div class="alert alert-danger" role="alert">
                            <h3>
                                <xsl:value-of select="'Validation errors in TEI file'"/>
                            </h3>
                            <p class="monospace small">
                                <xsl:value-of select="m:knowledgebase/m:page/@uri"/>
                            </p>
                            <ul class=" sml-margin top bottom">
                                <xsl:for-each select="m:validation//*:message">
                                    <li>
                                        <xsl:value-of select="data()"/>
                                        <small>
                                            <xsl:value-of select="' / '"/>
                                            <xsl:value-of select="string-join(@* ! concat(local-name(.), ':', string()), ' ')"/>
                                        </small>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </xsl:if>
                    
                    <!-- Page title -->
                    <h2 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'TEI Editor'"/>
                    </h2>
                    
                    <h3 class="bottom-margin">
                        <xsl:choose>
                            <xsl:when test="m:request/@type eq 'knowledgebase'">
                                
                                <xsl:value-of select="'Knowledge Base: '"/>
                                <xsl:value-of select="m:knowledgebase/m:page/m:titles/m:title[@type eq 'mainTitle'][@xml:lang eq 'en']"/>
                                
                                <xsl:choose>
                                    <xsl:when test="$section">
                                        <xsl:value-of select="' / '"/>
                                        <a class="small">
                                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', m:request/@resource-id, '.html#', m:request/@section-id)"/>
                                            <xsl:attribute name="target" select="m:request/@resource-id"/>
                                            <xsl:value-of select="m:request/@section-id"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$sibling">
                                        <xsl:value-of select="' / '"/>
                                        <a class="small">
                                            <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', m:request/@resource-id, '.html#', m:request/@sibling-id)"/>
                                            <xsl:attribute name="target" select="m:request/@resource-id"/>
                                            <xsl:value-of select="m:request/@sibling-id"/>
                                        </a>
                                        <xsl:value-of select="' / '"/>
                                        <small>
                                            <xsl:value-of select="'Add section after'"/>
                                        </small>
                                    </xsl:when>
                                </xsl:choose>
                                
                            </xsl:when>
                        </xsl:choose>
                    </h3>
                    
                    <!--<hr class="sml-margin"/>-->
                    
                    <xsl:choose>
                        
                        <xsl:when test="$section | $sibling">
                            <form method="post" action="/tei-editor.html" id="ajax-source">
                                
                                <input type="hidden" name="type" value="{ m:request/@type }"/>
                                <input type="hidden" name="resource-id" value="{ m:request/@resource-id }"/>
                                <input type="hidden" name="section-id" value="{ m:request/@section-id }"/>
                                <input type="hidden" name="sibling-id" value="{ m:request/@sibling-id }"/>
                                <input type="hidden" name="form-action" value="update-tei"/>
                                
                                <div class="row">
                                    
                                    <!-- Form controls -->
                                    <div class="col-sm-8">
                                        
                                        <!-- Text area -->
                                        <div class="form-group">
                                            <textarea name="markdown" class="form-control">
                                                
                                                <xsl:variable name="section">
                                                    <div xmlns="http://www.tei-c.org/ns/1.0" type="markup">
                                                        <xsl:attribute name="newline-element">
                                                            <xsl:choose>
                                                                <xsl:when test="$section-part[@type eq 'bibliography']">
                                                                    <xsl:value-of select="'bibl'"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="'p'"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:attribute>
                                                        <xsl:choose>
                                                            <xsl:when test="$section">
                                                                <xsl:sequence select="$section/node()"/>
                                                            </xsl:when>
                                                            <xsl:when test="$sibling">
                                                                <xsl:sequence select="m:default-markup/node()"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                    </div>
                                                </xsl:variable>
                                                
                                                <xsl:variable name="section-markdown">
                                                    <xsl:apply-templates select="$section"/>
                                                </xsl:variable>
                                                
                                                <xsl:attribute name="rows" select="ops:textarea-rows($section-markdown, 20, 105)"/>
                                                
                                                <xsl:sequence select="$section-markdown/m:markdown/data()"/>
                                                
                                            </textarea>
                                        </div>
                                        
                                        <!-- Submit button -->
                                        <div class="form-group">
                                            
                                            <button type="submit" class="btn btn-primary pull-right" data-loading="Applying changes...">
                                                <xsl:value-of select="'Apply changes'"/>
                                            </button>
                                            
                                        </div>
                                        
                                    </div>
                                    
                                    <!-- Help text -->
                                    <div class="col-sm-4">
                                        
                                        <xsl:call-template name="markdown:guide"/>
                                        
                                    </div>
                                    
                                </div>
                                
                            </form>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <p class="text-danger">
                                <xsl:value-of select="'This is not an editable region'"/>
                            </p>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </xsl:with-param>
            </xsl:call-template>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'TEI Editor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 TEI Editor'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>