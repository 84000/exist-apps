<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:include href="../../84000-reading-room/views/html/reading-room-page.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    
                    <div class="panel-heading panel-heading-bold hidden-print center-vertical">
                        <ul class="breadcrumb">
                            <li>
                                <a href="translations.html">
                                    Translations
                                </a>
                            </li>
                            <li>
                                Edit <xsl:value-of select="m:translation/@id"/>
                                <span class="label label-warning">Pre-publication</span>
                                <span class="label label-warning">In mark-up</span>
                            </li>
                        </ul>
                        <span>
                            <a class="pull-right">
                                <xsl:attribute name="href" select="concat('/translation/', m:translation/@id, '.html')"/>
                                <xsl:attribute name="target" select="m:translation/@id"/>
                                Preview
                            </a>
                        </span>
                    </div>
                    
                    <div class="panel-body">
                        
                        <xsl:if test="m:updates/m:updated">
                            <div class="alert alert-success alert-temporary" role="alert">
                                Updated
                            </div>
                        </xsl:if>
                        
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation">
                                <xsl:if test="@tab = 'translation'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=translation">Translation</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="@tab = 'tibetan-sources'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=tibetan-sources">Tibetan Sources</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="@tab = 'other-sources'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=other-sources">Indian &amp; Chinese Sources</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="@tab = 'content'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=content">Content</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="@tab = 'bibl-gloss'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=bibl-gloss">Bibliography &amp; Glossary</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="@tab = 'editorial-notes'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=editorial-notes">Editorial Notes</a>
                            </li>
                            <li role="presentation">
                                <xsl:if test="@tab = 'status'">
                                    <xsl:attribute name="class" select="'active'"/>
                                </xsl:if>
                                <a href="?tab=status">Status</a>
                            </li>
                        </ul>
                        
                        <div class="tab-content">
                            
                            
                            <form method="post" class="form-horizontal">
                                
                                <xsl:attribute name="action" select="'translation-edit.html'"/>
                                
                                <input type="hidden" name="translation-id">
                                    <xsl:attribute name="value" select="m:translation/@id"/>
                                </input>
                                
                                <xsl:if test="@tab = 'translation'">
                                    
                                    <input type="hidden" name="tab" value="translation"/>
                                    
                                    <fieldset>
                                        <legend>Title</legend>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Tohoku no','toh', '', '2', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Main title','main-title', '', '7', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Full title','full-title', '', '10', '', '')"/>
                                        </div>
                                    </fieldset>
                                    
                                    <fieldset>
                                        <legend>Language</legend>
                                        <div class="form-group">
                                            <xsl:variable name="translation-into-options">
                                                <options>
                                                    <option name="en">English</option>
                                                </options>
                                            </xsl:variable>
                                            <xsl:copy-of select="m:select-input('Into', 'translation-into', '2', 0, $translation-into-options)"/>
                                            <xsl:variable name="translation-from-options">
                                                <options>
                                                    <option name="bo">Tibetan</option>
                                                    <option name="sa">Sanskrit</option>
                                                    <option name="ch">Chinese</option>
                                                    <option name="other">Other (specify)</option>
                                                </options>
                                            </xsl:variable>
                                            <xsl:copy-of select="m:select-input('From', 'translation-from', '2', 4, $translation-from-options)"/>
                                            <xsl:variable name="translation-revised-options">
                                                <options>
                                                    <option name="bo">Tibetan</option>
                                                    <option name="sa">Sanskrit</option>
                                                    <option name="ch">Chinese</option>
                                                    <option name="other">Other (specify)</option>
                                                </options>
                                            </xsl:variable>
                                            <xsl:copy-of select="m:select-input('Revised', 'translation-revised', '2', 4, $translation-revised-options)"/>
                                        </div>
                                    </fieldset>
                                    
                                    <fieldset>
                                        <legend>Translation Team</legend>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Main translator','translator-main', '', '4', '', 'e.g. John Smith')"/>
                                            <xsl:copy-of select="m:text-input('Their location','translator-location', '', '4', '', 'e.g. London, U.K.')"/>
                                        </div>
                                        <xsl:copy-of select="m:text-multiple-input('Translator(s)','translator', (), '4', '', '')"/>
                                        <xsl:copy-of select="m:text-multiple-input('Reviser(s)','reviser', (), '4', '', '')"/>
                                        <xsl:copy-of select="m:text-multiple-input('Editor(s)','editor', (), '4', '', '')"/>
                                        <xsl:copy-of select="m:text-multiple-input('Consultant(s)','consultant', (), '4', '', '')"/>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Other','other', '', '4', '', '')"/>
                                            <xsl:copy-of select="m:text-input('Their role','other-role', '', '4', '', 'e.g. coordinator')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('84000 project editor','project-editor', (), '4', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('External reviewer','external-reviewer', (), '4', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Copy editor','copy-editor', (), '4', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Final reviewer','final-reviewer', (), '4', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Markup editor','markup-editor', (), '4', '', '')"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('TEI coordinator','tei-coordinator', (), '4', '', '')"/>
                                        </div>
                                        <xsl:copy-of select="m:text-multiple-input('Catalogue data entry(s)','data-inputer', (), '4', '', '')"/>
                                        <div class="form-group">
                                            <xsl:copy-of select="m:text-input('Catalogue data revision','data-revision', (), '4', '', '')"/>
                                        </div>
                                        <xsl:copy-of select="m:text-multiple-input('Translation sponsor(s)','translation-sponsor', (), '4', '', '')"/>
                                    </fieldset>
                                    
                                    <fieldset>
                                        <legend>Statements</legend>
                                        <div class="row">
                                            <div class="col-sm-6">
                                                <label>Translation &amp; patronage statement</label>
                                                <div class="well" data-match-height="1">
                                                    Translated by ____ under the patronage and supervision of 84000: Translating the Words of the Buddha.
                                                </div>
                                            </div>
                                            <div class="col-sm-6">
                                                <label>Acknowledgements and Sponsor's dedication</label>
                                                <p class="well" data-match-height="1">
                                                    This sūtra was translated by ____. This translation has been completed under the patronage and supervision of 84000: Translating the Words of the Buddha. The generous sponsorship of ________ for work on this sūtra is gratefully acknowledged.
                                                </p>
                                            </div>
                                        </div>
                                    </fieldset>
                                    
                                    <fieldset>
                                        <legend>Edition(s)</legend>
                                        <div class="form-group">
                                            <label class="col-sm-1 control-label">
                                                <xsl:attribute name="for" select="'edition-ref-1'"/>
                                                <xsl:value-of select="'Edition'"/>
                                            </label>
                                            <div class="col-sm-2">
                                                <input type="text" class="form-control">
                                                    <xsl:attribute name="name" select="'edition-ref-1'"/>
                                                    <xsl:attribute name="id" select="'edition-ref-1'"/>
                                                    <xsl:attribute name="value" select="''"/>
                                                    <xsl:attribute name="placeholder" select="'e.g. 1.0'"/>
                                                </input>
                                            </div>
                                            <label class="col-sm-1 control-label">
                                                <xsl:attribute name="for" select="'edition-date-1'"/>
                                                <xsl:value-of select="'Date'"/>
                                            </label>
                                            <div class="col-sm-2">
                                                <input type="date" class="form-control">
                                                    <xsl:attribute name="name" select="'edition-date-1'"/>
                                                    <xsl:attribute name="id" select="'edition-date-1'"/>
                                                    <xsl:attribute name="value" select="''"/>
                                                </input>
                                            </div>
                                            <label class="col-sm-2 control-label">
                                                <xsl:attribute name="for" select="'edition-summary-1'"/>
                                                <xsl:value-of select="'Summary of changes'"/>
                                            </label>
                                            <div class="col-sm-4">
                                                <textarea class="form-control" rows="3">
                                                    <xsl:attribute name="name" select="'edition-summary-1'"/>
                                                    <xsl:attribute name="id" select="'edition-summary-1'"/>
                                                    <xsl:attribute name="value" select="''"/>
                                                </textarea>
                                            </div>
                                        </div>
                                    </fieldset>
                                    
                                    <fieldset>
                                        <legend>Availability</legend>
                                        <div class="form-group">
                                            <xsl:variable name="restriction-options">
                                                <options>
                                                    <option name="none">None</option>
                                                    <option name="tantric">Tantric</option>
                                                </options>
                                            </xsl:variable>
                                            <xsl:copy-of select="m:select-input('Reading restrictions', 'restriction', '2', 0, $restriction-options)"/>
                                        </div>
                                        <div class="form-group">
                                            <xsl:variable name="license-options">
                                                <options>
                                                    <option name="cc-nc-3.0">Creative Commons CC-BY-NC-ND (Attribution - Non-commercial - No-derivatives) 3.0 copyright.</option>
                                                </options>
                                            </xsl:variable>
                                            <xsl:copy-of select="m:select-input('License', 'license', '10', 0, $license-options)"/>
                                        </div>
                                        
                                    </fieldset>
                                  
                                </xsl:if>
                                
                                <hr/>
                                
                                <div class="form-group">
                                    <div class="col-sm-offset-2 col-sm-10">
                                        <button type="submit" class="btn btn-primary">Save</button>
                                    </div>
                                </div>
                                
                            </form>
                            
                            
                        </div>
                    </div>
                    
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat('Edit Toh', m:translation/m:source/m:toh)"/>
            <xsl:with-param name="page-description" select="''"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:function name="m:text-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="size"/>
        <xsl:param name="css-class"/>
        <xsl:param name="placeholder"/>
        
        <label class="col-sm-2 control-label">
            <xsl:attribute name="for" select="$name"/>
            <xsl:value-of select="$label"/>
        </label>
        <div class="col-sm-10">
            <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
            <input type="text" class="form-control">
                <xsl:attribute name="name" select="$name"/>
                <xsl:attribute name="id" select="$name"/>
                <xsl:attribute name="value" select="$value"/>
                <xsl:attribute name="class" select="concat('form-control', ' ', $css-class)"/>
                <xsl:attribute name="placeholder" select="$placeholder"/>
            </input>
        </div>
    </xsl:function>
    
    <xsl:function name="m:date-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        
        <label class="col-sm-2 control-label">
            <xsl:attribute name="for" select="$name"/>
            <xsl:value-of select="$label"/>
        </label>
        <div class="col-sm-2">
            <input type="date" class="form-control">
                <xsl:attribute name="name" select="$name"/>
                <xsl:attribute name="id" select="$name"/>
                <xsl:attribute name="value" select="$value"/>
            </input>
        </div>
    </xsl:function>
    
    <xsl:function name="m:text-multiple-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="values"/>
        <xsl:param name="size"/>
        <xsl:param name="css-class"/>
        <xsl:param name="placeholder"/>
        
        <xsl:for-each select="$values">
            <div class="form-group">
              <xsl:choose>
                  <xsl:when test="position() = 1">
                      <xsl:copy-of select="m:text-input($label, concat($name, '-', position()), text(), $size, $css-class, $placeholder)"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:copy-of select="m:text-input('+', concat($name, '-', position()), text(), $size, $css-class, $placeholder)"/>
                  </xsl:otherwise>
              </xsl:choose>
            </div>
        </xsl:for-each>
        
        <div class="form-group">
          <xsl:choose>
              <xsl:when test="$values">
                  <xsl:copy-of select="m:text-input('+', concat($name, '-', (count($values) + 1)), '', $size, $css-class, $placeholder)"/>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:copy-of select="m:text-input($label, concat($name, '-', '1'), '', $size, $css-class, $placeholder)"/>
              </xsl:otherwise>
          </xsl:choose>
        </div>
        
    </xsl:function>
    
    <xsl:function name="m:select-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size"/>
        <xsl:param name="rows"/>
        <xsl:param name="options"/>
        
        <label class="col-sm-2 control-label">
            <xsl:attribute name="for" select="$name"/>
            <xsl:value-of select="$label"/>
        </label>
        <div class="col-sm-10">
            <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
            <select class="form-control">
                <xsl:attribute name="name" select="$name"/>
                <xsl:attribute name="id" select="$name"/>
                <xsl:if test="$rows &gt; 0">
                    <xsl:attribute name="multiple" select="'multiple'"/>
                    <xsl:attribute name="size" select="$rows"/>
                </xsl:if>
                <xsl:for-each select="$options//option">
                    <option>
                        <xsl:attribute name="value" select="@name"/>
                        <xsl:value-of select="text()"/>
                    </option>
                </xsl:for-each>
            </select>
        </div>
        
    </xsl:function>
    
</xsl:stylesheet>