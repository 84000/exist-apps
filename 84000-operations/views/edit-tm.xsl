<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:bcrdb="http://www.bcrdb.org/ns/1.0" xmlns:m="http://read.84000.co/ns/1.0" xmlns:tmx="http://www.lisa.org/tmx14" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="text-id" select="m:response/m:request/@text-id" as="xs:string"/>
    <xsl:variable name="part-id" select="m:response/m:request/@part-id" as="xs:string"/>
    <xsl:variable name="translation" select="/m:response/m:translation[1]"/>
    <xsl:variable name="tm-units" select="/m:response/tmx:tmx/tmx:body/tmx:tu" as="element(tmx:tu)*"/>
    <xsl:variable name="tei-text" as="xs:string?">
        <xsl:variable name="tei-text-nodes" as="xs:string*">
            <xsl:call-template name="tei-text-nodes">
                <xsl:with-param name="elements" select="$translation/tei:div[@type eq 'translation']"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="string-join($tei-text-nodes, ' ')"/>
    </xsl:variable>
    <xsl:variable name="tm-units-aligned" as="element(m:tm-unit-aligned)*">
        <xsl:call-template name="tm-unit-aligned">
            <xsl:with-param name="tm-unit-index" select="1"/>
            <xsl:with-param name="tei-text-substr" select="$tei-text"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="first-mismatch-index" select="min($tm-units-aligned[m:unmatched or not(@tm-location-id eq @tei-location-id)]/@index ! xs:integer(.))"/>
    
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
                        
                        <a class="small underline" data-loading="Loading...">
                            <xsl:attribute name="target" select="'check-folios'"/>
                            <xsl:attribute name="href" select="concat($reading-room-path, '/source/', $translation/m:toh[1]/@key, '.html?page=1#ajax-source')"/>
                            <xsl:attribute name="data-ajax-target" select="'#popup-footer-source .ajax-target'"/>
                            <xsl:value-of select="'Tibetan source'"/>
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
                    
                    <xsl:if test="$tm-units[not(@id)]">
                        <div class="alert alert-danger" id="alert-ids-missing">
                            <p>
                                <xsl:value-of select="'Some IDs are missing from this TMX | '"/>
                                <a href="{concat('/edit-tm.html?text-id=', $text-id, '&amp;part-id=', $part-id, '&amp;form-action=fix-ids')}" class="alert-link">
                                    <xsl:value-of select="'Fix missing IDs'"/>
                                </a>
                            </p>
                        </div>
                    </xsl:if>
                    
                    <xsl:choose>
                        
                        <xsl:when test="$tm-units">
                            
                            <div class="div-list">
                                <xsl:for-each select="$tm-units-aligned">
                                    
                                    <xsl:variable name="tm-unit-aligned" select="."/>
                                    <xsl:variable name="row-id" select="concat('row-', ($tm-unit-aligned/@index, 'new')[1])"/>
                                    <xsl:variable name="active-record" select="if($tm-unit-aligned[@index ! xs:integer(.) eq $first-mismatch-index]) then true() else false()" as="xs:boolean"/>
                                    
                                    <div class="row item">
                                        
                                        <xsl:attribute name="id" select="$row-id"/>
                                        
                                        <div class="col-sm-1 text-muted">
                                            <xsl:value-of select="$tm-unit-aligned/@index"/>
                                        </div>
                                        
                                        <div class="col-sm-11">
                                            
                                            <xsl:variable name="update-form-id" select="concat('form-update-segment-', $row-id)"/>
                                            
                                            <form method="post" class="form form-update stealth" id="{ $update-form-id }">
                                                
                                                <xsl:attribute name="action" select="concat('/edit-tm.html?text-id=', $text-id, '&amp;part-id=', $part-id)"/>
                                                <xsl:attribute name="data-loading" select="'Updating translation memory...'"/>
                                                
                                                <xsl:if test="$active-record">
                                                    <xsl:attribute name="class" select="'form form-update onload-scroll-target'"/>
                                                </xsl:if>
                                                
                                                <xsl:choose>
                                                    
                                                    <!-- Existing unit -->
                                                    <xsl:when test="$tm-unit-aligned/m:tm-bo gt '' and $tm-unit-aligned/@id">
                                                        
                                                        <!-- Action -->
                                                        <input type="hidden" name="form-action" value="update-segment"/>
                                                        <input type="hidden" name="tu-id" value="{ $tm-unit-aligned/@id }"/>
                                                        
                                                        <!-- Tibetan -->
                                                        <div class="form-group">
                                                            
                                                            <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-muted small sml-margin bottom">
                                                                <xsl:value-of select="'Add a line break to split a segment'"/>
                                                            </label>
                                                            
                                                            <xsl:variable name="tm-bo" select="$tm-unit-aligned/m:tm-bo"/>
                                                            <textarea name="tm-bo" id="tm-bo-new" class="form-control text-bo onkeypress-ctrlreturn-submit" placeholder="Tibetan segment">
                                                                <xsl:attribute name="rows" select="ops:textarea-rows($tm-bo, 1, 170)"/>
                                                                <xsl:value-of select="$tm-bo"/>
                                                            </textarea>
                                                            
                                                        </div>
                                                        
                                                        <!-- Translation -->
                                                        <div class="form-group">
                                                            
                                                            <xsl:choose>
                                                                
                                                                <!-- Existing text, needs editing to match the TEI -->
                                                                <xsl:when test="$tm-unit-aligned/m:tm-en gt ''">
                                                                    
                                                                    <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-muted small sml-margin bottom">
                                                                        <xsl:value-of select="'Edit to match the TEI'"/>
                                                                    </label>
                                                                    
                                                                    <xsl:variable name="tm-en" select="$tm-unit-aligned/m:tm-en"/>
                                                                    <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }" class="form-control monospace onkeypress-ctrlreturn-submit">
                                                                        <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                        <xsl:if test="$active-record">
                                                                            <xsl:attribute name="data-onload-get-focus" select="string-length($tm-en)"/>
                                                                        </xsl:if>
                                                                        <xsl:value-of select="$tm-en"/>
                                                                    </textarea>
                                                                    
                                                                    <!-- Include un-matched text for reference -->
                                                                    <xsl:if test="$tm-unit-aligned[m:unmatched] and $active-record">
                                                                        
                                                                        <xsl:variable name="section-id" select="concat('unmatched-', $tm-unit-aligned/@id)"/>
                                                                        
                                                                        <aside class="preview" id="{ $section-id }">
                                                                            
                                                                            <label for="unmatched-{ $tm-unit-aligned/@id }" class="text-muted small sml-margin bottom top">
                                                                                <xsl:value-of select="'Next/unmatched text from the TEI'"/>
                                                                            </label>
                                                                            
                                                                            <p for="unmatched-{ $tm-unit-aligned/@id }" class="form-control monospace">
                                                                                <span class="text-warning">
                                                                                    <xsl:value-of select="$tm-unit-aligned/m:unmatched"/>
                                                                                </span>
                                                                            </p>
                                                                            
                                                                            <xsl:call-template name="preview-controls">
                                                                                <xsl:with-param name="section-id" select="$section-id"/>
                                                                            </xsl:call-template>
                                                                            
                                                                        </aside>
                                                                    </xsl:if>
                                                                    
                                                                </xsl:when>
                                                                
                                                                <!-- No existing text, insert break in existing TEI -->
                                                                <xsl:otherwise>
                                                                    
                                                                    <label for="tm-en-{ $tm-unit-aligned/@id }" class="text-muted small sml-margin bottom">
                                                                        <xsl:value-of select="'Add a line break to segment the passage to match the Tibetan'"/>
                                                                    </label>
                                                                    
                                                                    <xsl:choose>
                                                                        <xsl:when test="$active-record">
                                                                            
                                                                            <xsl:variable name="tm-en" select="$tm-unit-aligned/m:unmatched"/>
                                                                            <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }" class="form-control monospace onkeypress-ctrlreturn-submit">
                                                                                <xsl:attribute name="rows" select="ops:textarea-rows($tm-en, 1, 116)"/>
                                                                                <xsl:attribute name="data-onload-get-focus" select="string-length(tokenize($tm-en, '[\.!\?]”?\s+')[1]) + 2"/>
                                                                                <xsl:value-of select="$tm-en"/>
                                                                            </textarea>
                                                                            
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            
                                                                            <textarea name="tm-en" id="tm-en-{ $tm-unit-aligned/@id }" class="form-control monospace onkeypress-ctrlreturn-submit">
                                                                                <xsl:attribute name="rows" select="'1'"/>
                                                                            </textarea>
                                                                            
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                    
                                                                    
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                            
                                                        </div>
                                                        
                                                        <!-- Button -->
                                                        <div class="form-group">
                                                            
                                                            <label for="tei-location-id-{ $row-id }" class="text-muted small sml-margin bottom">
                                                                
                                                                <xsl:value-of select="'TEI location id '"/>
                                                                
                                                                <xsl:if test="$tm-unit-aligned[not(@tei-location-id eq @tm-location-id)]">
                                                                    <span>
                                                                        <xsl:value-of select="concat(' (previously ', ($tm-unit-aligned/@tm-location-id, 'empty')[. gt ''][1], ')')"/>
                                                                    </span>
                                                                </xsl:if>
                                                                
                                                            </label>
                                                            
                                                            <div class="row">
                                                                
                                                                <div class="col-sm-8">
                                                                    <div class="center-vertical align-left">
                                                                        
                                                                        <div>
                                                                            <input type="text" name="tei-location-id" value="{ $tm-unit-aligned/@tei-location-id }" id="tei-location-id-{ $row-id }" class="form-control"/>
                                                                        </div>
                                                                        
                                                                        <!-- Link to location -->
                                                                        <div>
                                                                            
                                                                            <a target="{ $translation/@id }.html">
                                                                                
                                                                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $translation/m:toh[1]/@key, '.html#', $tm-unit-aligned/@tei-location-id)"/>
                                                                                
                                                                                <span class="small">
                                                                                    <xsl:value-of select="'Test location'"/>
                                                                                </span>
                                                                                
                                                                            </a>
                                                                        </div>
                                                                        
                                                                        <xsl:if test="$tm-unit-aligned[not(@tei-location-id eq @tm-location-id)]">
                                                                            <div>
                                                                                <span class="label label-danger">
                                                                                    <xsl:value-of select="'Changed! Click update to apply'"/>
                                                                                </span>
                                                                            </div>
                                                                        </xsl:if>
                                                                        
                                                                    </div>
                                                                    
                                                                </div>
                                                                
                                                                <xsl:choose>
                                                                    <xsl:when test="$tm-unit-aligned/@id gt ''">
                                                                        
                                                                        <div class="col-sm-2 text-right">
                                                                            
                                                                            <xsl:if test="$tm-unit-aligned/@id gt ''">
                                                                                <a role="button" class="btn btn-danger btn-sm">
                                                                                    <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $text-id, '&amp;part-id=', $part-id, '&amp;remove-tu=', $tm-unit-aligned/@id)"/>
                                                                                    <xsl:value-of select="'Delete'"/>
                                                                                </a>
                                                                            </xsl:if>
                                                                            
                                                                        </div>
                                                                        
                                                                        <div class="col-sm-2 text-right">
                                                                            
                                                                            <button type="submit" class="btn btn-warning btn-sm">
                                                                                <xsl:value-of select="'Update'"/>
                                                                            </button>
                                                                            
                                                                        </div>
                                                                        
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        
                                                                        <div class="col-sm-4 text-right">
                                                                            
                                                                            <a href="#alert-ids-missing" class="scroll-to-anchor small text-danger">
                                                                                <i class="fa fa-exclamation-circle" aria-hidden="true"/>
                                                                                <xsl:value-of select="' This unit has no unique id value and therefore cannot be updated'"/>
                                                                            </a>
                                                                            
                                                                        </div>
                                                                        
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
                                                                
                                                            </div>
                                                            
                                                        </div>
                                                        
                                                    </xsl:when>
                                                    
                                                    <!-- New unit -->
                                                    <xsl:otherwise>
                                                        
                                                        <!-- Action -->
                                                        <input type="hidden" name="form-action" value="add-unit"/>
                                                        
                                                        <!-- Tibetan -->
                                                        <div class="form-group">
                                                            
                                                            <label for="tm-bo-new" class="text-muted small sml-margin bottom">
                                                                <xsl:value-of select="'Add a Tibetan segment:'"/>
                                                            </label>
                                                            
                                                            <textarea name="tm-bo" id="tm-bo-new" class="form-control text-bo" placeholder="Tibetan segment">
                                                                <xsl:attribute name="rows" select="1"/>
                                                            </textarea>
                                                            
                                                        </div>
                                                        
                                                        <!-- Translation -->
                                                        <div class="form-group">
                                                            
                                                            <label for="tm-en-new" class="text-muted small sml-margin bottom">
                                                                <xsl:value-of select="'Insert a line break to segment the passage:'"/>
                                                            </label>
                                                            
                                                            <xsl:variable name="tm-en" select="$tm-unit-aligned/m:unmatched"/>
                                                            <textarea name="tm-en" id="tm-en-new" class="form-control monospace onkeypress-ctrlreturn-submit">
                                                                <xsl:attribute name="rows" select="(ops:textarea-rows($tm-en, 1, 116))"/>
                                                                <xsl:attribute name="data-onload-get-focus" select="string-length(tokenize($tm-en, '[\.!\?]”?\s+')[1]) + 2"/>
                                                                <xsl:value-of select="common:limit-str($tm-en, 1000)"/>
                                                            </textarea>
                                                            
                                                        </div>
                                                        
                                                        
                                                        <!-- Button -->
                                                        <div class="form-group">
                                                            
                                                            <button type="submit" class="btn btn-warning btn-sm pull-right">
                                                                <xsl:value-of select="'Update'"/>
                                                            </button>
                                                            
                                                        </div>
                                                        
                                                    </xsl:otherwise>
                                                    
                                                </xsl:choose>
                                                
                                            </form>
                                            
                                        </div>
                                        
                                    </div>
                                    
                                </xsl:for-each>
                                
                            </div>
                            
                        </xsl:when>
                        
                        <xsl:otherwise>
                            
                            <hr/>
                            
                            <form method="post" class="form text-center">
                                    
                                <xsl:attribute name="action" select="concat('/edit-tm.html?text-id=', $text-id)"/>
                                <xsl:attribute name="data-loading" select="'Creating new TMX file...'"/>
                                
                                <div class="form-group">
                                    <p class="text-muted">
                                        <xsl:value-of select="'~ No Translation Memory for this text ~'"/>
                                    </p>
                                </div>
                                
                                <input type="hidden" name="form-action" value="new-tmx"/>
                                
                                <div class="row">
                                    <div class="col-sm-8 col-sm-offset-2">
                                        
                                        <div class="form-group">
                                            
                                            <label for="bcrd-resource">
                                                <xsl:value-of select="'Create a TMX file for this translation based on the selected BCRD resource'"/>
                                            </label>
                                            
                                            <select name="bcrd-resource" id="bcrd-resource" class="form-control">
                                                <xsl:for-each select="m:bcrd-resources/m:bcrd-resource[@document-name gt '']">
                                                    <option value="{ @document-name }">
                                                        <xsl:value-of select="bcrdb:head/bcrdb:sourceDesc/bcrdb:bibl/bcrdb:biblScope[@unit eq 'catNo']/text()"/>
                                                        <xsl:value-of select="' / '"/>
                                                        <xsl:value-of select="(bcrdb:head/bcrdb:sourceDesc/bcrdb:bibl/bcrdb:title)[1]/text()"/>
                                                    </option>
                                                </xsl:for-each>
                                            </select>
                                            
                                        </div>
                                        
                                        <div class="form-group">
                                            <button type="submit" class="btn btn-danger">
                                                <xsl:attribute name="href" select="concat('/edit-tm.html?text-id=', $text-id, '&amp;form-action=create-file')"/>
                                                <xsl:value-of select="'Create TMX file'"/>
                                            </button>
                                        </div>
                                        
                                    </div>    
                                </div>
                                
                            </form>
                            
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
    
    <xsl:template name="tei-text-nodes">
        
        <xsl:param name="elements" as="element()*"/>
        
        <xsl:for-each select="$elements">
            
            <xsl:variable name="element" select="." as="element()"/>
            
            <xsl:if test="$element[self::tei:div | self::tei:milestone] and $element/@xml:id">
                <xsl:value-of select="concat('{{milestone:', $element/@xml:id, '}}')"/>
            </xsl:if>
            
            <xsl:choose>
                
                <!-- Elements to ignore -->
                <xsl:when test="$element[self::tei:head] and $element/@type = ('translation', 'titleHon', 'colophon')">
                    <!-- Return nothing -->
                </xsl:when>
                
                <xsl:when test="$element[self::tei:head] and $element/@type = ('titleMain')">
                    <xsl:value-of select="string-join(($elements[self::tei:head][@type eq 'titleHon'], $element)/descendant::text()[not(ancestor::tei:note)], ' ') ! normalize-space(.) ! normalize-unicode(.)"/>
                </xsl:when>
                
                <!-- Return text content -->
                <xsl:when test="$element/@tid">
                    <xsl:value-of select="string-join($element/descendant::text()[not(ancestor::tei:note)], '') ! normalize-space(.) ! normalize-unicode(.)"/>
                </xsl:when>
                
                <!-- Recurse -->
                <xsl:otherwise>
                    <xsl:call-template name="tei-text-nodes">
                        <xsl:with-param name="elements" select="$element/*"/>
                    </xsl:call-template>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="tm-unit-aligned" as="element(m:tm-unit-aligned)*">
        
        <xsl:param name="tm-unit-index" as="xs:integer"/>
        <xsl:param name="tei-text-substr" as="xs:string?"/>
        <xsl:param name="tei-location-id" as="xs:string?"/>
        
        <xsl:variable name="tm-unit" select="if($tm-unit-index le count($tm-units)) then $tm-units[$tm-unit-index] else ()" as="element(tmx:tu)?"/>
        <xsl:variable name="tm-bo" select="($tm-unit/tmx:tuv[@xml:lang eq 'bo']/tmx:seg ! normalize-space(.), '')[1]" as="xs:string"/>
        <xsl:variable name="tm-en" select="($tm-unit/tmx:tuv[@xml:lang eq 'en']/tmx:seg ! normalize-space(.), '')[1]" as="xs:string"/>
        <xsl:variable name="tm-location-id" select="$tm-unit/tmx:prop[@name eq 'location-id']" as="xs:string?"/>
        
        <!-- Look for the next instance of the string in the text -->
        <!-- Strip [[notes]] from the TM string -->
        <xsl:variable name="tm-en-notes-removed" select="replace($tm-en, '\[{2}.+\]{2}\s*', '')" as="xs:string"/>
        <!-- If there's no test string then force negative result -->
        <xsl:variable name="tm-en-notes-regex" select="if($tm-en-notes-removed) then concat('(^|\s+)[“|‘]?', common:escape-for-regex(normalize-space($tm-en-notes-removed))) else '--force-no-match--'" as="xs:string"/>
        
        <!-- Look for the first instance of the TM segment -->
        <xsl:variable name="tei-text-substr-analyzed" select="analyze-string($tei-text-substr, $tm-en-notes-regex)" as="element()?"/>
        <xsl:variable name="tei-text-substr-match" select="$tei-text-substr-analyzed//fn:match[1]" as="element()?"/>
        <xsl:variable name="tei-text-substr-preceding" select="$tei-text-substr-match/preceding-sibling::fn:non-match" as="element()*"/>
        <xsl:variable name="tei-text-substr-trailing" select="$tei-text-substr-match/following-sibling::*" as="element()*"/>
        
        <!-- Find the id in the preceding chunk -->
        <xsl:variable name="tei-text-preceding-analyzed" select="analyze-string($tei-text-substr-preceding, '\{{2}milestone:[^\{\}]+\}{2}')" as="element()"/>
        <xsl:variable name="tei-text-preceding-location-match" select="$tei-text-preceding-analyzed//fn:match[last()]" as="element()?"/>
        <xsl:variable name="tei-location-id" select="if($tei-text-preceding-location-match) then replace($tei-text-preceding-location-match, '\{{2}milestone:|\}{2}', '') else $tei-location-id" as="xs:string?"/>
        
        <!-- Find the id in the matched chunk so we can add them to remainder -->
        <xsl:variable name="tei-text-match-analyzed" select="analyze-string($tei-text-substr-match, '\{{2}milestone:[^\{\}]+\}{2}')" as="element()"/>
        
        <xsl:variable name="tei-text-substr-remainder" select="string-join(($tei-text-preceding-analyzed//fn:no-match/text(), $tei-text-match-analyzed//fn:match, $tei-text-substr-trailing//text()))" as="xs:string?"/>
            
        <xsl:element name="tm-unit-aligned" namespace="http://read.84000.co/ns/1.0">
            
            <xsl:attribute name="id" select="$tm-unit/@id"/>
            <xsl:attribute name="index" select="$tm-unit-index"/>
            <xsl:attribute name="tm-location-id" select="$tm-location-id"/>
            <xsl:attribute name="tei-location-id" select="($tei-location-id, $tm-location-id)[. gt ''][1]"/>
            
            <!-- Return the TM data -->
            <xsl:element name="tm-bo" namespace="http://read.84000.co/ns/1.0">
                <xsl:value-of select="$tm-bo"/>
            </xsl:element>
            <xsl:element name="tm-en" namespace="http://read.84000.co/ns/1.0">
                <xsl:value-of select="$tm-en"/>
            </xsl:element>
            
            <!-- If there was no change then it was unmatched -->
            <xsl:if test="not($tei-text-substr-match)">
                <xsl:element name="unmatched" namespace="http://read.84000.co/ns/1.0">
                    <xsl:choose>
                        <!-- If there's no existing English then offer the next chunk (1,000 chars) -->
                        <xsl:when test="$tm-bo gt '' and not($tm-en gt '')">
                            <xsl:value-of select="common:limit-str($tei-text-substr, 1000)"/>
                        </xsl:when>
                        <!-- If there is English then try to estimate the match -->
                        <xsl:otherwise>
                            <xsl:value-of select="$tei-text-substr"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:if>
            
        </xsl:element>
        
        <xsl:if test="$tm-unit-index lt count($tm-units) or ($tm-unit-index eq count($tm-units) and $tei-text-substr-match and normalize-space($tei-text-substr-remainder) gt '')">
            
            <!-- Recurr with the next tm unit and the remaining tei string -->
            <xsl:call-template name="tm-unit-aligned">
                <xsl:with-param name="tm-unit-index" select="$tm-unit-index + 1"/>
                <xsl:with-param name="tei-text-substr" select="normalize-space($tei-text-substr-remainder)"/>
                <xsl:with-param name="tei-location-id" select="$tei-location-id"/>
            </xsl:call-template>
            
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>