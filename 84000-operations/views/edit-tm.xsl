<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="text-id" select="m:response/m:request/@text-id" as="xs:string"/>
    <xsl:variable name="part-id" select="m:response/m:request/@part-id" as="xs:string"/>
    <xsl:variable name="translation" select="/m:response/m:translation[1]"/>
    <xsl:variable name="tm-units" select="/m:response/tmx:tmx/tmx:body/tmx:tu" as="element(tmx:tu)*"/>
    <xsl:variable name="tei-text" as="xs:string?">
        <xsl:variable name="tei-texts">
            <xsl:call-template name="tei-text">
                <xsl:with-param name="elements" select="$translation/tei:div[@type eq 'translation']"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="replace(string-join($tei-texts, ''), '↳', '')"/>
    </xsl:variable>
    <xsl:variable name="tm-units-aligned" as="element(m:tm-unit-aligned)*">
        <xsl:call-template name="tm-unit-aligned">
            <xsl:with-param name="tm-unit-index" select="1"/>
            <xsl:with-param name="tei-text-substr" select="$tei-text"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="first-mismatch-index" select="min($tm-units-aligned[not(@aligned eq 'true')]/@index ! xs:integer(.))"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="page-content">
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Translation Memory Editor'"/>
                    </h3>
                    
                    <!-- Text title -->
                    <div class="h4">
                        
                        <a>
                            <xsl:if test="$translation[m:toh]">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html?view-mode=editor')"/>
                                <xsl:attribute name="target" select="$translation/@id"/>
                                <xsl:value-of select="$translation/m:toh[1]/m:full/data()"/>
                                <xsl:value-of select="' / '"/>
                            </xsl:if>
                            <xsl:value-of select="common:limit-str($translation/m:titles/m:title[@xml:lang eq 'en'][1], 80)"/>
                        </a>
                        
                        <small>
                            <xsl:value-of select="' / '"/>
                        </small>
                        
                        <a target="_self" class="small underline" data-loading="Loading...">
                            <xsl:attribute name="href" select="concat('edit-text-header.html?id=', $translation/@id)"/>
                            <xsl:value-of select="'Edit headers'"/>
                        </a>
                        
                        <div class="pull-right">
                            <xsl:sequence select="ops:translation-status($translation/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <xsl:if test="not($first-mismatch-index)">
                        <div class="alert alert-success onload-scroll-target">
                            <p>
                                <xsl:value-of select="'All done! TM matches TEI'"/>
                            </p>
                        </div>
                    </xsl:if>
                    
                    <xsl:choose>
                        
                        <xsl:when test="$tm-units">
                            
                            <table class="table">
                                <xsl:for-each select="$tm-units-aligned">
                                    
                                    <xsl:variable name="tm-unit-aligned" select="."/>
                                    <xsl:variable name="row-id" select="concat('row-', $tm-unit-aligned/@index)"/>
                                    
                                    <tr>
                                        
                                        <xsl:if test="$tm-unit-aligned/@index ! xs:integer(.) eq $first-mismatch-index">
                                            <xsl:attribute name="class" select="'vertical-middle onload-scroll-target'"/>
                                        </xsl:if>
                                        
                                        <xsl:attribute name="id" select="$row-id"/>
                                        
                                        <td class="text-bo text-muted">
                                            <xsl:value-of select="$tm-unit-aligned/@index"/>
                                        </td>
                                        <td class="text-bo">
                                            <xsl:value-of select="$tm-unit-aligned/m:tm-bo"/>
                                        </td>
                                        
                                    </tr>
                                    
                                    <tr class="sub">
                                        <td/>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="$tm-unit-aligned[not(@aligned eq 'true')]">
                                                    <form method="post" class="form">
                                                        
                                                        <xsl:attribute name="action" select="concat('edit-tm.html?text-id=', $text-id, '&amp;part-id=', $part-id)"/>
                                                        <xsl:attribute name="data-loading" select="'Loading...'"/>
                                                        
                                                        <input type="hidden" name="form-action" value="update-tm"/>
                                                        <input type="hidden" name="tu-id" value="{ $tm-unit-aligned/@id }"/>
                                                        
                                                        <div class="form-group">
                                                            <xsl:variable name="tm-en" select="($tm-unit-aligned/m:tm-en, $tm-unit-aligned/m:tei-en)[normalize-space(.) gt ''][1]"/>
                                                            <textarea name="tm-en" class="form-control monospace">
                                                                <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                <xsl:value-of select="$tm-en"/>
                                                            </textarea>
                                                        </div>
                                                        
                                                        <xsl:if test="$tm-unit-aligned[not(@aligned eq 'true')][m:tei-en/normalize-space(.) gt ''][m:tm-en/normalize-space(.) gt '']">
                                                            <p class="form-control monospace">
                                                                <span class="text-warning">
                                                                    <xsl:value-of select="$tm-unit-aligned/m:tei-en"/>
                                                                </span>
                                                            </p>
                                                        </xsl:if>
                                                        
                                                        <xsl:if test="$tm-unit-aligned[not(@aligned eq 'true')][@index ! xs:integer(.) eq $first-mismatch-index]">
                                                            <div class="form-group">
                                                                
                                                                <xsl:choose>
                                                                    <xsl:when test="$tm-unit-aligned/@id gt ''">
                                                                        
                                                                        <button type="submit" class="btn btn-warning btn-sm">
                                                                            <xsl:value-of select="'Update'"/>
                                                                        </button>
                                                                        
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        
                                                                        <span class="small text-danger">
                                                                            <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                                            <xsl:value-of select="' This unit has no unique id value and therefore cannot be updated'"/>
                                                                        </span>
                                                                        
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                                
                                                            </div>
                                                        </xsl:if>
                                                        
                                                    </form>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <span class="text-muted">
                                                        <xsl:value-of select="$tm-unit-aligned/m:tm-en"/>
                                                    </span>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </td>
                                    </tr>
                                    
                                </xsl:for-each>
                            </table>
                            
                        </xsl:when>
                        
                        <xsl:otherwise>
                            
                            <div class="text-center">
                                
                                <hr/>
                                
                                <p class="text-muted">
                                    <xsl:value-of select="'~ No Translation Memory for this text ~'"/>
                                </p>
                                
                                <a class="btn btn-danger">
                                    <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $text-id, '&amp;form-action=create-file')"/>
                                    <xsl:value-of select="'Create a TM file for this translation'"/>
                                </a>
                                
                            </div>
                            
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'Translation Memory Editor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Create Translation Memory pairs from 84000 TEI files'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="tei-text" as="xs:string*">
        
        <xsl:param name="elements" as="element()*"/>
        
        <xsl:for-each select="$elements">
            
            <xsl:variable name="element" select="." as="element()"/>
            
            <xsl:choose>
                
                <!-- Elements to ignore -->
                <xsl:when test="$element/self::tei:head and @type = ('translation', 'titleHon', 'colophon')">
                    <!-- Return nothing -->
                </xsl:when>
                
                <xsl:when test="$element/self::tei:head and @type = ('titleMain')">
                    <xsl:value-of select="string-join(($elements[self::tei:head][@type eq 'titleHon'], $element)/descendant::text()[not(ancestor::tei:note)], ' ') ! normalize-space(.)"/>
                </xsl:when>
                
                <!-- Return text content -->
                <xsl:when test="$element/@tid">
                    <xsl:value-of select="string-join($element/descendant::text()[not(ancestor::tei:note)], '') ! normalize-space(.)"/>
                </xsl:when>
                
                <!-- Recurse -->
                <xsl:otherwise>
                    <xsl:call-template name="tei-text">
                        <xsl:with-param name="elements" select="./*"/>
                    </xsl:call-template>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="tm-unit-aligned" as="element(m:tm-unit-aligned)*">
        
        <xsl:param name="tm-unit-index" as="xs:integer"/>
        <xsl:param name="tei-text-substr" as="xs:string?"/>
        
        <xsl:variable name="tm-unit" select="$tm-units[$tm-unit-index]" as="element(tmx:tu)?"/>
        <xsl:variable name="tm-en" select="($tm-unit/tmx:tuv[@xml:lang eq 'en']/tmx:seg ! normalize-space(.), '')[1]" as="xs:string"/>
        <xsl:variable name="tm-en-edited" select="replace($tm-en, '\[.+\]', '')" as="xs:string"/>
        <xsl:variable name="tei-segment-match" select="if($tm-en-edited gt '') then replace($tei-text-substr, concat('^\s*(', common:escape-for-regex($tm-en-edited), ')'), '$1↳', 'i') else $tei-text-substr ! normalize-space(.)" as="xs:string"/>
        <xsl:variable name="tei-segment-split" select="tokenize($tei-segment-match, '↳')" as="xs:string*"/>
        
        <xsl:element name="tm-unit-aligned" namespace="http://read.84000.co/ns/1.0">
            <xsl:attribute name="id" select="$tm-unit/@id"/>
            <xsl:attribute name="index" select="$tm-unit-index"/>
            <xsl:attribute name="aligned" select="count($tei-segment-split) gt 1"/>
            <xsl:element name="tm-bo" namespace="http://read.84000.co/ns/1.0">
                <xsl:value-of select="$tm-unit/tmx:tuv[@xml:lang eq 'bo']/tmx:seg ! normalize-space(.)"/>
            </xsl:element>
            <xsl:element name="tm-en" namespace="http://read.84000.co/ns/1.0">
                <xsl:value-of select="$tm-en"/>
            </xsl:element>
            <xsl:element name="tei-en" namespace="http://read.84000.co/ns/1.0">
                <xsl:value-of select="common:limit-str($tei-segment-split[1], 600)"/>
            </xsl:element>
        </xsl:element>
        
        <xsl:if test="$tm-unit-index lt count($tm-units)">
            <xsl:call-template name="tm-unit-aligned">
                <xsl:with-param name="tm-unit-index" select="$tm-unit-index + 1"/>
                <xsl:with-param name="tei-text-substr" select="string-join($tei-segment-split[2 to last()])"/>
            </xsl:call-template>
        </xsl:if>
        
    </xsl:template>
    
    
</xsl:stylesheet>