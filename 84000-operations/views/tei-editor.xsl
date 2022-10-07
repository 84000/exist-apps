<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="passage-id" select="/m:response/m:request/@passage-id"/>
    <xsl:variable name="passage-id-parsed" select="replace($passage-id, '^node\-', '')"/>
    <xsl:variable name="passage" select="/m:response/m:knowledgebase//tei:*[(@xml:id, @tid) = $passage-id-parsed][not(m:part)][not(tei:div)]"/>
    <xsl:variable name="passage-section" select="/m:response/m:knowledgebase//tei:div[@type eq 'section'][@xml:id eq $passage-id-parsed]"/>
    <xsl:variable name="passage-part" select="/m:response/m:knowledgebase//m:part[@id eq $passage-id-parsed]"/>
    <xsl:variable name="passage-config">
        <passage-config xmlns="http://read.84000.co/ns/1.0">
            <xsl:choose>
                <xsl:when test="$passage[self::tei:p[parent::tei:item[parent::tei:list]]]">
                    <xsl:variable name="first-item" select="(common:index-of-node($passage/parent::tei:item/parent::tei:list/tei:item, $passage/parent::tei:item) eq 1)"/>
                    <xsl:variable name="last-item" select="(common:index-of-node($passage/parent::tei:item/parent::tei:list/tei:item, $passage/parent::tei:item) eq count($passage/parent::tei:item/parent::tei:list/tei:item))"/>
                    <xsl:variable name="has-sublist" select="$passage[tei:list]"/>
                    <xsl:variable name="root-list" select="count($passage/ancestor::tei:list) eq 1"/>
                    <xsl:variable name="list-has-label" select="$passage/parent::tei:item/parent::tei:list/preceding-sibling::tei:*[1][self::tei:label]"/>
                    <xsl:choose>
                        <xsl:when test="$first-item">
                            <label>Paragraph (in the first list item)</label>
                        </xsl:when>
                        <xsl:when test="$last-item">
                            <label>Paragraph (in the last list item)</label>
                        </xsl:when>
                        <xsl:otherwise>
                            <label>Paragraph (in a list item)</label>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="$first-item and not($list-has-label)">
                        <sibling-option element-name="itemPara-listLabel-before">Add a label for the list</sibling-option>
                    </xsl:if>
                    <sibling-option element-name="itemPara-item-before">Insert a list item before</sibling-option>
                    <sibling-option element-name="itemPara-item-after">Insert a list item after</sibling-option>
                    <sibling-option element-name="itemPara-itemPara-after">Insert a paragraph before (in this list item)</sibling-option>
                    <sibling-option element-name="itemPara-itemPara-after">Insert a paragraph after (in this list item)</sibling-option>
                    <xsl:if test="not($has-sublist)">
                        <sibling-option element-name="itemPara-itemListDots-after">Start a new sub-list - dots (in this list item)</sibling-option>
                        <sibling-option element-name="itemPara-itemListNumbers-after">Start a new sub-list - numbers (in this list item)</sibling-option>
                        <sibling-option element-name="itemPara-itemListLetters-after">Start a new sub-list - letters (in this list item)</sibling-option>
                    </xsl:if>
                    <xsl:if test="$last-item">
                        <sibling-option element-name="itemPara-para-after">Add a paragraph (after the list)</sibling-option>
                        <xsl:if test="$root-list">
                            <sibling-option element-name="itemPara-listDots-after">Start a new list - dots (after the list)</sibling-option>
                            <sibling-option element-name="itemPara-listNumbers-after">Start a new list - numbers (after the list)</sibling-option>
                            <sibling-option element-name="itemPara-listLetters-after">Start a new list - letters (after the list)</sibling-option>
                        </xsl:if>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$passage[self::tei:head]">
                    <label>Heading</label>
                    <sibling-option element-name="head-para-after">Add a paragraph after</sibling-option>
                    <sibling-option element-name="head-listDots-after">Start a list after - dots</sibling-option>
                    <sibling-option element-name="head-listNumbers-after">Start a list after - numbers</sibling-option>
                    <sibling-option element-name="head-listLetters-after">Start a list after - letters</sibling-option>
                </xsl:when>
                <xsl:when test="$passage[self::tei:p]">
                    <label>Paragraph</label>
                    <sibling-option element-name="para-para-after">Add a paragraph after</sibling-option>
                    <sibling-option element-name="para-listDots-after">Start a list after - dots</sibling-option>
                    <sibling-option element-name="para-listNumbers-after">Start a list after - numbers</sibling-option>
                    <sibling-option element-name="para-listLetters-after">Start a list after - letters</sibling-option>
                </xsl:when>
                <xsl:when test="$passage[self::tei:bibl]">
                    <label>Bibliographic reference</label>
                    <sibling-option element-name="bibl-bibl-after">Add a bibliographic reference after</sibling-option>
                </xsl:when>
                <xsl:when test="$passage-section">
                    <label>Section</label>
                    <sibling-option element-name="section-section-after">Start a new section after</sibling-option>
                </xsl:when>
                <xsl:when test="$passage-part">
                    <label>Part</label>
                    <sibling-option element-name="part-section-after">Start a new section after</sibling-option>
                </xsl:when>
                <xsl:otherwise>
                    <label>
                        <xsl:value-of select="local-name($passage)"/>
                    </label>
                </xsl:otherwise>
            </xsl:choose>
        </passage-config>
    </xsl:variable>
    <xsl:variable name="tabs-config">
        <tabs-config xmlns="http://read.84000.co/ns/1.0">
            <xsl:if test="$passage[not(tei:div | m:part) and not(self::tei:div | self::m:part)]">
                <tab target-id="edit-form">Edit content</tab>
            </xsl:if>
            <xsl:if test="$passage[text()] and $passage[@tid]">
                <tab target-id="comment-form">Comment</tab>
            </xsl:if>
            <xsl:if test="$passage-config/m:passage-config[m:sibling-option]">
                <tab target-id="add-form">Add an element</tab>
            </xsl:if>
        </tabs-config>
    </xsl:variable>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="alert-translation-locked"/>
            
            <!-- Schema validation alert -->
            <xsl:if test="m:validation//*:status[text() eq 'invalid']">
                <div class="alert alert-danger" role="alert">
                    <h4 class="no-bottom-margin">
                        <xsl:value-of select="'Validation errors in TEI file'"/>
                    </h4>
                    <xsl:if test="m:knowledgebase[m:page]">
                        <p class="monospace small">
                            <xsl:value-of select="m:knowledgebase/m:page/@document-url"/>
                        </p>
                    </xsl:if>
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
            
            <!-- Title -->
            <h2 class="sml-margin bottom">
                
                <xsl:choose>
                    <xsl:when test="m:request/@resource-type eq 'knowledgebase' and m:knowledgebase[m:page]">
                        
                        <xsl:value-of select="m:knowledgebase/m:page/m:titles/m:title[@resource-type eq 'mainTitle'][@xml:lang eq 'en']"/>
                        
                        <small>
                        
                            <xsl:value-of select="' (84000 Knowledge Base)'"/>
                            
                            <xsl:if test="$passage-id gt ''">
                                    
                                <xsl:value-of select="' / '"/>
                                <a>
                                    <xsl:attribute name="href" select="concat($reading-room-path, '/knowledgebase/', m:request/@resource-id, '.html#', $passage-id)"/>
                                    <xsl:attribute name="target" select="m:request/@resource-id"/>
                                    <xsl:value-of select="$passage-id"/>
                                </a>
                                
                            </xsl:if>
                            
                            <xsl:if test="$passage-config[m:passage-config[m:label/text() gt '']]">
                                
                                <xsl:value-of select="' / '"/>
                                <xsl:value-of select="$passage-config/m:passage-config/m:label[1]"/>
                                
                            </xsl:if>
                        
                        </small>
                    </xsl:when>
                </xsl:choose>
                
            </h2>
            
            <!-- Ajax content -->
            <div id="ajax-source" class="data-container replace">
                
                <!-- Forms -->
                <xsl:choose>
                    
                    <!-- Edit content -->
                    <xsl:when test="$tabs-config/m:tabs-config[m:tab]">
                        
                        <!-- Tabs -->
                        <ul class="nav nav-tabs top-margin" role="tabslist">
                            
                            <xsl:for-each select="$tabs-config/m:tabs-config/m:tab">
                                <li role="presentation">
                                    
                                    <xsl:if test="@target-id eq 'edit-form'">
                                        <xsl:attribute name="class" select="'active'"/>
                                    </xsl:if>
                                    
                                    <a role="tab" data-toggle="tab">
                                        <xsl:attribute name="href" select="'#' || @target-id"/>
                                        <xsl:attribute name="aria-controls" select="@target-id"/>
                                        <xsl:if test="@target-id eq 'comment-form' and $passage[comment()]">
                                            <xsl:attribute name="class" select="'sticky-note'"/>
                                        </xsl:if>
                                        <xsl:value-of select="data()"/>
                                    </a>
                                    
                                </li>
                            </xsl:for-each>
                            
                        </ul>
                        
                        <div class="tab-content">
                            
                            <!-- Callback url -->
                            <xsl:variable name="callbackurl">
                                <xsl:if test="m:request/@resource-type eq 'knowledgebase' and m:knowledgebase[m:page]">
                                    <xsl:value-of select="concat($reading-room-path, '/knowledgebase/', m:knowledgebase/m:page/@kb-id, '.html?view-mode=editor#article')"/>
                                </xsl:if>
                            </xsl:variable>
                            
                            <!-- Edit content -->
                            <div id="edit-form" role="tabpanel" class="tab-pane fade">
                                
                                <xsl:if test="$tabs-config/m:tabs-config/m:tab[@target-id eq 'edit-form']">
                                    <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                </xsl:if>
                                
                                <xsl:call-template name="form">
                                    
                                    <xsl:with-param name="content">
                                        
                                        <!-- Form action -->
                                        <input type="hidden" name="form-action" value="update-tei"/>
                                        
                                        <!-- Text area -->
                                        <div class="form-group">
                                            <textarea name="markdown" class="form-control monospace">
                                                
                                                <xsl:variable name="passage-tei">
                                                    <!--<unescaped xmlns="http://read.84000.co/ns/1.0">
                                                            <xsl:sequence select="$passage/node()"/>
                                                        </unescaped>-->
                                                    <div xmlns="http://www.tei-c.org/ns/1.0" type="markup" newline-element="p">
                                                        <xsl:sequence select="$passage/node()"/>
                                                    </div>
                                                </xsl:variable>
                                                
                                                <xsl:variable name="passage-editable">
                                                    <xsl:apply-templates select="$passage-tei"/>
                                                </xsl:variable>
                                                
                                                <xsl:attribute name="rows" select="common:textarea-rows($passage-editable, 5, 80)"/>
                                                
                                                <!--<xsl:sequence select="$passage-editable/m:escaped/data()"/>-->
                                                <xsl:sequence select="$passage-editable/m:markdown/data()"/>
                                                
                                            </textarea>
                                        </div>
                                        
                                        <!-- Submit button -->
                                        <div class="form-group center-vertical full-width">
                                            <div class="text-danger small">
                                                <xsl:value-of select="'To delete the element remove all content and update.'"/>
                                                <br/>
                                                <xsl:value-of select="'This will also delete associated comments!'"/>
                                            </div>
                                            <div>
                                                <button type="submit" class="btn btn-primary pull-right" data-loading="Updating content...">
                                                    <xsl:if test="(m:translation, m:knowledgebase/m:page)[1][@locked-by-user gt '']">
                                                        <xsl:attribute name="disabled" select="'disabled'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Update Content'"/>
                                                </button>
                                            </div>
                                        </div>
                                        
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="callbackurl" select="$callbackurl"/>
                                    
                                </xsl:call-template>
                                
                            </div>
                            
                            <!-- Add an element -->
                            <div id="add-form" role="tabpanel" class="tab-pane fade">
                                
                                <xsl:if test="$tabs-config/m:tabs-config/m:tab[1][@target-id eq 'add-form']">
                                    <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                </xsl:if>
                                
                                <xsl:call-template name="form">
                                    
                                    <xsl:with-param name="content">
                                        
                                        <!-- Form action -->
                                        <input type="hidden" name="form-action" value="add-element"/>
                                        
                                        <!-- New element options -->
                                        <div class="form-group">
                                            
                                            <xsl:choose>
                                                <xsl:when test="$passage-config/m:passage-config[m:sibling-option]">
                                                    
                                                    <label>
                                                        <xsl:value-of select="'Elements you can add here:'"/>
                                                    </label>
                                                    
                                                    
                                                    <hr class="sml-margin"/>
                                                    
                                                    <xsl:for-each select="$passage-config/m:passage-config/m:sibling-option">
                                                        
                                                        <div class="radio">
                                                            <label>
                                                                <input type="radio" name="new-element-name">
                                                                    <xsl:attribute name="value" select="@element-name"/>
                                                                </input>
                                                                <xsl:value-of select="text()"/>
                                                            </label>
                                                        </div>
                                                        
                                                    </xsl:for-each>
                                                    
                                                    <hr class="sml-margin"/>
                                                    
                                                    <!-- Submit button -->
                                                    <div class="form-group center-vertical full-width">
                                                        <div class="text-muted small">
                                                            <xsl:value-of select="'Add an element, it will be added with default text, then select to edit it.'"/>
                                                        </div>
                                                        <div>
                                                            <button type="submit" class="btn btn-primary pull-right" data-loading="Adding element...">
                                                                <xsl:if test="(m:translation, m:knowledgebase/m:page)[1][@locked-by-user gt '']">
                                                                    <xsl:attribute name="disabled" select="'disabled'"/>
                                                                </xsl:if>
                                                                <xsl:value-of select="'Add element'"/>
                                                            </button>
                                                        </div>
                                                    </div>
                                                    
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    
                                                    <p class="italic">
                                                        <xsl:value-of select="'Sorry, no options to add nodes here'"/>
                                                    </p>
                                                    
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            
                                        </div>
                                        
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="callbackurl" select="$callbackurl"/>
                                    
                                </xsl:call-template>
                                
                            </div>
                            
                            <!-- Add a comment -->
                            <div id="comment-form" role="tabpanel" class="tab-pane fade">
                                
                                <xsl:if test="$tabs-config/m:tabs-config/m:tab[1][@target-id eq 'comment-form']">
                                    <xsl:attribute name="class" select="'tab-pane fade in active'"/>
                                </xsl:if>
                                
                                <xsl:call-template name="form">
                                    
                                    <xsl:with-param name="content">
                                        
                                        <!-- Form action -->
                                        <input type="hidden" name="form-action" value="comment-tei"/>
                                        
                                        <!-- Text area -->
                                        <div class="form-group">
                                            <textarea name="comment" class="form-control sticky-note">
                                                
                                                <xsl:variable name="passage-comment">
                                                    <xsl:sequence select="$passage/comment()[1]/data() ! normalize-space()"/>
                                                </xsl:variable>
                                                
                                                <xsl:attribute name="rows" select="common:textarea-rows($passage-comment, 5, 105)"/>
                                                
                                                <xsl:value-of select="$passage-comment"/>
                                                
                                            </textarea>
                                        </div>
                                        
                                        <!-- Submit button -->
                                        <div class="form-group center-vertical full-width">
                                            <div class="text-danger small">
                                                <xsl:value-of select="'Note: although hidden in the Reading Room, comments are visible in the public source file!'"/>
                                            </div>
                                            <div>
                                                <button type="submit" class="btn btn-primary pull-right" data-loading="Submitting comment...">
                                                    <xsl:if test="(m:translation, m:knowledgebase/m:page)[1][@locked-by-user gt '']">
                                                        <xsl:attribute name="disabled" select="'disabled'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="'Submit Comment'"/>
                                                </button>
                                            </div>
                                        </div>
                                        
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="callbackurl" select="$callbackurl"/>
                                    
                                </xsl:call-template>
                                
                            </div>
                            
                        </div>
                        
                        <div class="list-group" id="markdown-help-list">
                            <xsl:call-template name="expand-item">
                                <xsl:with-param name="id" select="'markdown-help'"/>
                                <xsl:with-param name="accordion-selector" select="'markdown-help-list'"/>
                                <xsl:with-param name="persist" select="true()"/>
                                <xsl:with-param name="title">
                                    <h3 class="no-top-margin no-bottom-margin">
                                        <xsl:value-of select="'Using 84000 Markdown'"/>
                                    </h3>
                                </xsl:with-param>
                                <xsl:with-param name="content">
                                    <div class="top-margin">
                                        
                                        <p class="small">
                                            <xsl:value-of select="'All TEI tags are supported by specifying the text in square brackets [text] followed by the tag definition in round brackets (tag).'"/>
                                        </p>
                                        
                                        <pre class="wrap small">
                                            <xsl:value-of select="'The language of a term can be specified [Maitrāyanī](Sa-Ltn), '"/>
                                            <xsl:value-of select="'and links can be added [84000.co](https://84000.co).'"/>
                                            <br/>
                                            <xsl:value-of select="'Specific tags with multiple attributes [Karmaśataka](title lang:Sa-Ltn ref:entity-123) can also be defined.'"/>
                                            <br/>
                                        </pre>
                                        
                                        <pre class="wrap small">
                                            <xsl:value-of select="'You can add a notes using the syntax [1](note) and another [2](note).'"/>
                                            <br/>
                                            <br/>
                                            <xsl:value-of select="'n.1 Specify the content of the 1st note like this.'"/>
                                            <br/>
                                            <xsl:value-of select="'n.2 And the content for the 2nd on another new line.'"/>
                                            <br/>
                                        </pre>
                                        
                                        <pre class="wrap small">
                                            <xsl:value-of select="'You may encounter complex nesting of elements, like [[[The Teaching of [[[Vimalakīrti]]](term ref:entity-123)]](http://read.84000.co/translation/toh176.html)](title lang:en) (Toh 176). '"/>
                                            <xsl:value-of select="'If in doubt leave brackets alone and ask a TEI editor to help. '"/>
                                        </pre>
                                        
                                    </div>
                                    
                                </xsl:with-param>
                            </xsl:call-template>
                        </div>
                        
                        
                    </xsl:when>
                    
                    <!-- Lock / unlock file -->
                    <xsl:when test="$passage-id eq 'locking'">
                        <xsl:call-template name="form">
                            <xsl:with-param name="content">
                                
                                <xsl:variable name="element" select="(m:translation, m:knowledgebase/m:page)[1]"/>
                                
                                <div class="top-margin bottom-margin">
                                    
                                    <p class="text-muted">
                                        <xsl:value-of select="'File: ' || $element/@document-url"/>
                                    </p>
                                    
                                    <hr class="sml-margin"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="$element[@locked-by-user eq /m:response/@user-name]">
                                            
                                            <input type="hidden" name="form-action" value="unlock-tei"/>
                                            
                                            <div class="form-group center-vertical full-width">
                                                <div>
                                                    <p class="text-danger">
                                                        <xsl:value-of select="'Currently locked by you'"/>
                                                    </p>
                                                    <p>
                                                        <xsl:value-of select="'Locking the file alerts other users that changes are being made'"/>
                                                    </p>
                                                    <p>
                                                        <xsl:value-of select="'To unlock the file close it in the Oxygen XML editor '"/>
                                                    </p>
                                                </div>
                                                <!--<div>
                                                    <button type="submit" class="btn btn-danger pull-right" data-loading="Updating lock...">
                                                        <xsl:value-of select="'Un-lock the file'"/>
                                                    </button>
                                                </div>-->
                                            </div>
                                            
                                        </xsl:when>
                                        <xsl:when test="$element[not(@locked-by-user gt '')]">
                                            
                                            <input type="hidden" name="form-action" value="lock-tei"/>
                                            
                                            <div class="form-group center-vertical full-width">
                                                <div>
                                                    <p class="text-danger">
                                                        <xsl:value-of select="'Not currently locked'"/>
                                                    </p>
                                                    <p>
                                                        <!--<xsl:value-of select="'Locking the file alerts other users that changes are being made'"/>-->
                                                        <xsl:value-of select="'To lock the file open it using the Oxygen XML editor using a WebDAV connection'"/>
                                                    </p>
                                                </div>
                                                <!--<div>
                                                    <button type="submit" class="btn btn-danger pull-right" data-loading="Updating lock...">
                                                        <xsl:value-of select="'Lock the file'"/>
                                                    </button>
                                                </div>-->
                                            </div>
                                            
                                        </xsl:when>
                                        <xsl:otherwise>
                                            
                                            <p class="text-danger">
                                                <xsl:value-of select="'To un-lock this file please contact user: '"/>
                                                <strong>
                                                    <xsl:value-of select="$element/@locked-by-user"/>
                                                </strong>
                                            </p>
                                            
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </div>
                                
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    
                    <xsl:otherwise>
                        <xsl:call-template name="form">
                            <xsl:with-param name="content">
                                <div class="top-margin bottom-margin">
                                    
                                    <p class="text-muted">
                                        <xsl:value-of select="'Passage not found / removed'"/>
                                    </p>
                                    
                                </div>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'TEI Editor | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'84000 TEI Editor'"/>
            <xsl:with-param name="content">
                
                <div class="title-band hidden-print">
                    <div class="container">
                        <div class="center-vertical full-width">
                            <span class="logo">
                                <img alt="84000 logo">
                                    <xsl:attribute name="src" select="concat($front-end-path, '/imgs/logo.png')"/>
                                </img>
                            </span>
                            <span>
                                <h1 class="title">
                                    <xsl:value-of select="'84000 TEI Editor'"/>
                                </h1>
                            </span>
                        </div>
                    </div>
                </div>
                
                <main class="content-band">
                    <div class="container">
                        <xsl:sequence select="$content"/>
                    </div>
                </main>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="form">
        
        <xsl:param name="content" as="node()*"/>
        <xsl:param name="callbackurl" as="xs:string?"/>
        
        <form action="/tei-editor.html" method="post" data-ajax-target="#ajax-source" class="bottom-margin">
            
            <xsl:if test="$callbackurl gt ''">
                <xsl:attribute name="data-ajax-target-callbackurl" select="$callbackurl"/>
            </xsl:if>
            
            <input type="hidden" name="resource-id" value="{ m:request/@resource-id }"/>
            <input type="hidden" name="resource-type" value="{ m:request/@resource-type }"/>
            <input type="hidden" name="passage-id" value="{ $passage-id }"/>
            
            <xsl:sequence select="$content"/>
            
        </form>
        
    </xsl:template>
    
</xsl:stylesheet>