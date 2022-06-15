<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/text-overlay.xsl"/>
    
    <xsl:variable name="environment" select="/m:response/m:environment"/>
    <xsl:variable name="reading-room-path" select="$environment/m:url[@id eq 'reading-room']/text()" as="xs:string"/>
    <xsl:variable name="front-end-path" select="$environment/m:url[@id eq 'front-end']/text()" as="xs:string"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="title-band">
                <div class="container">
                    <div class="center-vertical full-width">
                        <span class="logo">
                            <img alt="84000 logo">
                                <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                            </img>
                        </span>
                        <span>
                            <h1 class="title">
                                <xsl:value-of select="'Translation Memory'"/>
                            </h1>
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="content-band" id="translation-memory">
                <div class="container">
                    <div class="row">
                        <div class="col-sm-9">
                            <form action="index.html" method="post" id="translation-memory-form" class="form-inline filter-form">
                                
                                <div class="form-group">
                                    <label for="translation-id" class="sr-only">Translation</label>
                                    <select name="translation-id" class="form-control" id="translation-id" title="Translation">
                                        <xsl:for-each select="m:translations/m:file">
                                            <xsl:sort select="@id"/>
                                            <option>
                                                <xsl:attribute name="value" select="@id"/>
                                                <xsl:if test="@id eq /m:response/m:request/@translation-id">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="concat(@id, ' / ', common:limit-str(data(.), 35))"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <label for="folio" class="sr-only">Folio</label>
                                    <select name="folio" class="form-control" id="folio" title="Folio">
                                        <xsl:for-each select="m:folios/m:folio">
                                            <xsl:sort select="xs:integer(@page-in-text)"/>
                                            <option>
                                                <xsl:attribute name="value" select="@tei-folio"/>
                                                <xsl:if test="@tei-folio eq /m:response/m:request/@folio">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="@tei-folio"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>
                                
                                <div class="form-group">
                                    <button class="btn btn-default" type="submit">
                                        <i class="fa fa-refresh"/>
                                    </button>
                                </div>
                                
                                <div class="form-group text text-muted italic">
                                    <xsl:value-of select="concat('eKangyur volume ', m:source/m:page/@volume, ', page ', m:source/m:page/@page-in-volume, '.')"/>
                                </div>
                            </form>
                        </div>
                        <div class="col-sm-3">
                            <a href="/tmx.zip" class="pull-right center-vertical">
                                <span>
                                    <i class="fa fa-cloud-download"/>
                                </span>
                                <span>Download All (.tmx)</span>
                            </a>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-8">
                            
                            <div id="source-text" class="text-overlay">
                                <div class="text divided text-bo">
                                    <xsl:call-template name="text-marked">
                                        <xsl:with-param name="data" select="m:source/m:page/m:language[@xml:lang eq 'bo']"/>
                                    </xsl:call-template>
                                </div>
                                <div class="text plain text-bo" data-mouseup-set-input="#tmx-form [name='source']">
                                    <xsl:call-template name="text-plain">
                                        <xsl:with-param name="data" select="m:source/m:page/m:language[@xml:lang eq 'bo']//tei:p"/>
                                    </xsl:call-template>
                                </div>
                            </div>
                            
                            <hr/>
                            
                            <div id="translation-text" class="text-overlay">
                                <div class="text divided">
                                    <xsl:call-template name="text-marked">
                                        <xsl:with-param name="data" select="m:folio-content"/>
                                    </xsl:call-template>
                                </div>
                                <div class="text plain" data-mouseup-set-input="#tmx-form [name='translation']">
                                    <xsl:call-template name="text-plain">
                                        <xsl:with-param name="data" select="m:folio-content"/>
                                    </xsl:call-template>
                                </div>
                            </div>
                            
                        </div>
                        <div class="col-sm-4">
                            <form action="index.html" method="post" id="tmx-form" class="form-update">
                                
                                <input type="hidden" name="action" value="remember-translation"/>
                                
                                <input type="hidden" name="translation-id">
                                    <xsl:attribute name="value" select="m:request/@translation-id"/>
                                </input>
                                
                                <input type="hidden" name="folio">
                                    <xsl:attribute name="value" select="m:request/@folio"/>
                                </input>
                                
                                <div class="form-group">
                                    <label for="source" class="sr-only">Source</label>
                                    <textarea name="source" class="form-control text-bo" rows="6" required="required"/>
                                </div>
                                
                                <div class="form-group">
                                    <label for="translation" class="sr-only">Translation</label>
                                    <textarea name="translation" class="form-control" rows="6" required="required"/>
                                </div>
                                
                                <div class="form-group">
                                    <button type="button" class="btn btn-danger pull-left" data-mouseup-clear-input="#tmx-form [name='translation']" data-mouseup-submit="#tmx-form">Delete</button>
                                </div>
                                
                                <div class="form-group">
                                    <button type="submit" class="btn btn-success pull-right">Add to memory</button>
                                </div>
                                
                            </form>
                            
                            <div id="translation-memory-units">
                                <xsl:for-each select="m:translation-memory/tmx:tu">
                                    <div class="unit">
                                        <xsl:attribute name="id" select="concat('unit-', @tuid)"/>
                                        <xsl:variable name="onclick-set">
                                            {
                                            <xsl:value-of select="concat('&#34;#tmx-form [name=\&#34;source\&#34;]&#34; : &#34;#unit-', @tuid, ' .source&#34;')"/>,
                                            <xsl:value-of select="concat('&#34;#tmx-form [name=\&#34;translation\&#34;]&#34; : &#34;#unit-', @tuid, ' .translation&#34;')"/>
                                            }
                                        </xsl:variable>
                                        <xsl:variable name="onload-replace">
                                            {
                                            <xsl:value-of select="concat('&#34;#source-text .text.plain&#34; : &#34;#unit-', @tuid, ' .source .mark&#34;')"/>,
                                            <xsl:value-of select="concat('&#34;#translation-text .text.plain&#34; : &#34;#unit-', @tuid, ' .translation .mark&#34;')"/>
                                            }
                                        </xsl:variable>
                                        <!-- 
                                                <xsl:variable name="onclick-mark">
                                                {
                                                    <xsl:value-of select="concat('"#translation-text .text.plain" : "#unit-', @tuid, ' .translation"')"/>
                                                }
                                                </xsl:variable> -->
                                        <xsl:variable name="onclick-bold">
                                            [
                                            <xsl:value-of select="concat('&#34;.unit-', @tuid, '&#34;')"/>
                                            ]
                                        </xsl:variable>
                                        <p class="source text-bo">
                                            <a>
                                                <xsl:attribute name="href" select="concat('#unit-', @tuid)"/>
                                                <xsl:attribute name="class" select="concat('mark unit-', @tuid)"/>
                                                <xsl:attribute name="data-onclick-set" select="normalize-space($onclick-set)"/>
                                                <xsl:attribute name="data-onload-replace" select="normalize-space($onload-replace)"/>
                                                <xsl:attribute name="data-onclick-bold" select="normalize-space($onclick-bold)"/>
                                                <xsl:value-of select="tmx:tuv[@xml:lang eq 'bo']/tmx:seg/text() ! normalize-space(.)"/>
                                            </a>
                                        </p>
                                        <p class="translation">
                                            <a>
                                                <xsl:attribute name="href" select="concat('#unit-', @tuid)"/>
                                                <xsl:attribute name="class" select="concat('mark unit-', @tuid)"/>
                                                <xsl:attribute name="data-onclick-set" select="normalize-space($onclick-set)"/>
                                                <xsl:attribute name="data-onclick-bold" select="normalize-space($onclick-bold)"/>
                                                <xsl:value-of select="tmx:tuv[@xml:lang eq 'en']/tmx:seg/text() ! normalize-space(.)"/>
                                            </a>
                                        </p>
                                    </div>
                                </xsl:for-each>
                            </div>
                            
                        </div>
                    </div>
                </div>
            </div>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'84000 | Translation Memory'"/>
            <xsl:with-param name="page-description" select="'84000 Translation Memory Generator.'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>