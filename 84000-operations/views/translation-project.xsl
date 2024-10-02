<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">

    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>

    <xsl:variable name="response" select="/m:response"/>
    <xsl:variable name="text" select="$response/m:text"/>
    <xsl:variable name="translation-status" select="$response/m:translation-status"/>

    <xsl:template match="/m:response">

        <xsl:variable name="content">

            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">

                    <xsl:call-template name="alert-updated"/>

                    <xsl:call-template name="alert-translation-locked"/>

                    <!-- Title / status -->
                    <div class="center-vertical full-width sml-margin bottom">

                        <div class="h3">
                            <a target="_blank">
                                <xsl:attribute name="href" select="m:translation-href(($text/m:toh/@key)[1], (), (), (), (), $reading-room-path)"/>
                                <xsl:value-of select="concat(string-join($text/m:toh/m:full, ' / '), ' / ', $text/m:titles/m:title[@xml:lang eq 'en'][1])"/>
                            </a>
                        </div>

                        <div class="text-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>

                    </div>

                    <!-- Links -->
                    <xsl:call-template name="text-links-list">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="disable-links" select="('translation-project')"/>
                        <xsl:with-param name="text-status" select="$response/m:text-statuses/m:status[@status-id eq $text/@status]"/>
                    </xsl:call-template>

                    <!-- TEI -->
                    <div class="center-vertical full-width sml-margin top bottom">

                        <!-- url -->
                        <div>
                            <a class="text-muted small">
                                <xsl:attribute name="href" select="concat($reading-room-path, '/translation/', $text/@id, '.tei')"/>
                                <xsl:attribute name="target" select="concat($text/@id, '.tei')"/>
                                <xsl:value-of select="concat('TEI file: ', $text/@document-url)"/>
                            </a>
                        </div>

                        <!-- Version -->
                        <span class="text-right">
                            <span class="small">
                                <xsl:value-of select="'TEI version: '"/>
                            </span>
                            <span class="label label-info monospace">
                                <xsl:value-of select="if($text[@tei-version gt '']) then $text/@tei-version else '[none]'"/>
                            </span>
                        </span>

                    </div>

                    <!-- Due date -->
                    <xsl:variable name="next-target-date" select="$translation-status/m:text[@status-surpassable eq 'true']/m:target-date[@next eq 'true'][1]"/>
                    <xsl:if test="$next-target-date">
                        <div class="center-vertical full-width sml-margin bottom">

                            <span class="small">
                                <xsl:value-of select="'Target dates: '"/>
                            </span>

                            <span class="text-right">
                                <xsl:choose>
                                    <xsl:when test="xs:integer($next-target-date/@due-days) ge 0">

                                        <span class="label label-success">
                                            <xsl:value-of select="'Due in '"/>
                                            <xsl:value-of select="$next-target-date/@due-days"/>
                                            <xsl:value-of select="' days'"/>
                                        </span>

                                    </xsl:when>
                                    <xsl:when test="xs:integer($next-target-date/@due-days) lt 0">

                                        <span class="label label-danger">
                                            <xsl:value-of select="'Overdue '"/>
                                            <xsl:value-of select="abs($next-target-date/@due-days)"/>
                                            <xsl:value-of select="' days'"/>
                                        </span>

                                    </xsl:when>
                                </xsl:choose>
                            </span>

                        </div>
                    </xsl:if>

                    <!-- Forms accordion -->
                    <div class="list-group accordion accordion-bordered accordion-background top-margin tests replace" role="tablist" aria-multiselectable="true" id="forms-accordion">

                        <xsl:call-template name="translation-status-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'translation-status') then true() else false()"/>
                        </xsl:call-template>

                        <xsl:call-template name="contributors-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'contributors') then true() else false()"/>
                        </xsl:call-template>

                        <xsl:call-template name="submissions-form-panel">
                            <xsl:with-param name="active" select="if(m:request/@form-expand eq 'submissions') then true() else false()"/>
                        </xsl:call-template>

                        <xsl:call-template name="generated-files-panel">
                            <!--<xsl:with-param name="active" select="if(m:request/@form-expand eq 'generated-files') then true() else false()"/>-->
                            <xsl:with-param name="active" select="if (m:request/@form-expand eq 'generated-files' or (m:request/@form-expand eq '' and $text/@status-group eq 'published')) then true() else false()"/>
                        </xsl:call-template>

                    </div>

                </xsl:with-param>
            
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                </xsl:with-param>
            
            </xsl:call-template>

        </xsl:variable>

        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="concat(string-join($text/m:toh/m:full, ' / '), ' | Translation Project | 84000 Project Management')"/>
            <xsl:with-param name="page-description" select="concat('Translation project for ', string-join($text/m:toh/m:full, ' / '))"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>

    </xsl:template>

    <!-- Translation status form -->
    <xsl:template name="translation-status-form-panel">

        <xsl:param name="active"/>

        <xsl:call-template name="expand-item">

            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'translation-status'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>

            <xsl:with-param name="title">
                
                <div class="h4">
                    <xsl:value-of select="'Project status'"/>
                </div>
                
                <p class="text-muted small sml-margin top">
                    <xsl:value-of select="'Options for managing the status of the translation project'"/>
                </p>
                
            </xsl:with-param>

            <xsl:with-param name="content">

                <form method="post" class="form-horizontal form-update sml-margin top" id="publication-status-form" data-loading="Updating status...">

                    <xsl:attribute name="action" select="'translation-project.html'"/>

                    <input type="hidden" name="form-action" value="update-publication-status"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="$text/@id"/>
                    </input>
                    <input type="hidden" name="form-expand" value="translation-status"/>

                    <div class="alert alert-warning small text-center">
                        <p>
                            <xsl:value-of select="'Updating the version number will commit the new version to the '"/>
                            <a target="_blank" class="alert-link">
                                <xsl:attribute name="href" select="concat('https://github.com/84000/data-tei/commits/master/', substring-after($text/@document-url, concat($response/@data-path, '/tei/')))"/>
                                <xsl:value-of select="'Github repository'"/>
                            </a>
                            <xsl:value-of select="'. '"/>
                            <xsl:if test="$text/@status eq '1'">
                                <xsl:value-of select="'Associated files (pdfs, ebooks) will be generated for published texts. This can take some time.'"/>
                            </xsl:if>
                        </p>
                    </div>

                    <div class="row">

                        <!-- Form -->
                        <div class="col-sm-8">
                            <div class="match-this-height" data-match-height="status-form">

                                <!--Contract details-->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="contract-number">
                                        <xsl:value-of select="'Contract number:'"/>
                                    </label>
                                    <div class="col-sm-3">
                                        <input type="text" name="contract-number" id="contract-number" class="form-control" placeholder="">
                                            <xsl:attribute name="value" select="normalize-space($translation-status/m:text/m:contract/@number)"/>
                                        </input>
                                    </div>
                                    <label class="control-label col-sm-3" for="contract-date">
                                        <xsl:value-of select="'Contract date:'"/>
                                    </label>
                                    <div class="col-sm-3">
                                        <input type="date" name="contract-date" id="contract-date" class="form-control">
                                            <xsl:attribute name="value" select="$translation-status/m:text/m:contract/@date"/>
                                        </input>
                                    </div>
                                </div>

                                <!--Translation Status-->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="translation-status">
                                        <xsl:value-of select="'Translation Status:'"/>
                                    </label>
                                    <div class="col-sm-9">
                                        <select class="form-control" name="translation-status" id="translation-status">
                                            <xsl:for-each select="$response/m:text-statuses/m:status">
                                                <xsl:sort select="@value eq '0'"/>
                                                <xsl:sort select="@value"/>
                                                <option>
                                                    <xsl:attribute name="value" select="@value"/>
                                                    <xsl:if test="@selected eq 'selected'">
                                                        <xsl:attribute name="selected" select="'selected'"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="concat(@value, ' / ', text())"/>
                                                </option>
                                            </xsl:for-each>
                                        </select>
                                    </div>
                                </div>

                                <!--Publication Date-->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="publication-date">
                                        <xsl:value-of select="'Publication Date:'"/>
                                    </label>
                                    <div class="col-sm-3">
                                        <input type="date" name="publication-date" id="publication-date" class="form-control">
                                            <xsl:attribute name="value" select="$text/m:publication/m:publication-date"/>
                                            <xsl:if test="$response/m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                <xsl:attribute name="required" select="'required'"/>
                                            </xsl:if>
                                        </input>
                                    </div>
                                </div>

                                <!--Version-->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="text-version">
                                        <xsl:value-of select="'Version:'"/>
                                    </label>
                                    <div class="col-sm-2">
                                        <input type="text" name="text-version" id="text-version" class="form-control" placeholder="e.g. v 1.0">
                                            <!-- Force the addition of a version number if the form is used -->
                                            <xsl:attribute name="value">
                                                <xsl:choose>
                                                    <xsl:when test="$text/m:publication/m:edition/text()[1]/normalize-space()">
                                                        <xsl:value-of select="$text/m:publication/m:edition/text()[1]/normalize-space()"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="'0.0.1'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
                                            <xsl:if test="$response/m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                <xsl:attribute name="required" select="'required'"/>
                                            </xsl:if>
                                        </input>
                                    </div>
                                    <div class="col-sm-2">
                                        <input type="text" name="text-version-date" id="text-version-date" class="form-control" placeholder="e.g. 2019">
                                            <xsl:attribute name="value">
                                                <xsl:choose>
                                                    <xsl:when test="$text/m:publication/m:edition/tei:date/text()/normalize-space()">
                                                        <xsl:value-of select="$text/m:publication/m:edition/tei:date/text()/normalize-space()"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y]')"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
                                            <xsl:if test="$response/m:text-statuses/m:status[@selected eq 'selected']/@value eq '1'">
                                                <xsl:attribute name="required" select="'required'"/>
                                            </xsl:if>
                                        </input>
                                    </div>
                                    <div class="col-sm-5">
                                        <input type="text" name="update-notes" id="update-notes" class="form-control" placeholder="Add a note about this version"/>
                                    </div>
                                </div>

                                <!-- Action note -->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="action-note">
                                        <xsl:value-of select="'Awaiting action from:'"/>
                                    </label>
                                    <div class="col-sm-3">
                                        <input type="text" class="form-control" name="action-note" id="action-note" placeholder="e.g. Konchog">
                                            <xsl:attribute name="value" select="normalize-space($translation-status/m:text/m:action-note)"/>
                                        </input>
                                    </div>
                                </div>

                                <!-- Progress note -->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="progress-note">
                                        <xsl:value-of select="'Progress notes:'"/>
                                    </label>
                                    <div class="col-sm-9">
                                        <textarea class="form-control" name="progress-note" id="progress-note" placeholder="Notes about the status of the translation...">
                                            <xsl:attribute name="rows" select="common:textarea-rows($translation-status/m:text/m:progress-note, 4, 70)"/>
                                            <xsl:sequence select="$translation-status/m:text/m:progress-note/text()"/>
                                        </textarea>
                                        <xsl:if test="$translation-status/m:text/m:progress-note/@last-edited">
                                            <div class="small text-muted sml-margin top">
                                                <xsl:value-of select="common:date-user-string('Last updated', $translation-status/m:text/m:progress-note/@last-edited, $translation-status/m:text/m:progress-note/@last-edited-by)"/>
                                            </div>
                                        </xsl:if>
                                    </div>
                                </div>

                                <!-- Text note -->
                                <div class="form-group">
                                    <label class="control-label col-sm-3" for="text-note">
                                        <xsl:value-of select="'Text notes:'"/>
                                    </label>
                                    <div class="col-sm-9">
                                        <textarea class="form-control" name="text-note" id="text-note" placeholder="Notes about the text itself...">
                                            <xsl:attribute name="rows" select="common:textarea-rows($translation-status/m:text/m:text-note, 4, 70)"/>
                                            <xsl:sequence select="$translation-status/m:text/m:text-note/text()"/>
                                        </textarea>
                                        <xsl:if test="$translation-status/m:text/m:text-note/@last-edited">
                                            <div class="small text-muted sml-margin top">
                                                <xsl:value-of select="common:date-user-string('Last updated', $translation-status/m:text/m:text-note/@last-edited, $translation-status/m:text/m:text-note/@last-edited-by)"/>
                                            </div>
                                        </xsl:if>
                                    </div>
                                </div>

                                <!-- Target dates -->
                                <xsl:variable name="target-dates" select="$translation-status/m:text/m:target-date"/>
                                <xsl:variable name="actual-dates" select="$text/m:status-updates/m:status-update[@type = ('translation-status', 'publication-status')]"/>
                                <div class="form-group">
                                    <label class="control-label col-sm-3 top-margin" for="text-note">
                                        <xsl:value-of select="'Target dates:'"/>
                                    </label>
                                    <div class="col-sm-9">
                                        <table class="table table-responsive table-icons no-border">
                                            <thead>
                                                <tr>
                                                    <th>
                                                        <xsl:value-of select="'Status'"/>
                                                    </th>
                                                    <th>
                                                        <xsl:value-of select="'Target date'"/>
                                                    </th>
                                                    <th colspan="2">
                                                        <xsl:value-of select="'Actual date'"/>
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <xsl:for-each select="$response/m:text-statuses/m:status[@target-date eq 'true']">

                                                    <xsl:variable name="status-id" select="@status-id"/>
                                                    <xsl:variable name="status-surpassed" select="@selected eq 'selected' or preceding-sibling::m:status[@selected eq 'selected']"/>
                                                    <xsl:variable name="target-date" select="$target-dates[@status-id eq $status-id][1]"/>

                                                    <xsl:variable name="actual-date" select="                                                             if ($status-surpassed) then                                                                 $actual-dates[@status eq $status-id][last()]                                                             else                                                                 ()"/>
                                                    <xsl:variable name="target-date-hit" select="($target-date[@date-time] and $actual-date[@when] and xs:dateTime($target-date/@date-time) ge xs:dateTime($actual-date/@when))"/>
                                                    <xsl:variable name="target-date-miss" select="($target-date[@date-time] and (xs:dateTime($target-date/@date-time) lt current-dateTime()) or ($actual-date[@when] and xs:dateTime($target-date/@date-time) lt xs:dateTime($actual-date/@when)))"/>

                                                    <tr class="vertical-middle">
                                                        <td class="small">
                                                            <xsl:if test="$status-surpassed">
                                                                <xsl:attribute name="class" select="'text-muted'"/>
                                                            </xsl:if>
                                                            <xsl:value-of select="common:limit-str(concat($status-id, ' / ', text()), 28)"/>
                                                        </td>
                                                        <td>
                                                            <input type="date" class="form-control">
                                                                <xsl:attribute name="name" select="concat('target-date-', @index)"/>
                                                                <xsl:if test="$target-date">
                                                                    <xsl:attribute name="value" select="format-dateTime($target-date/@date-time, '[Y]-[M01]-[D01]')"/>
                                                                </xsl:if>
                                                                <xsl:if test="$status-surpassed">
                                                                    <xsl:attribute name="disabled" select="'disabled'"/>
                                                                </xsl:if>
                                                            </input>
                                                        </td>
                                                        <td class="icon">
                                                            <xsl:choose>
                                                                <xsl:when test="$target-date-hit">
                                                                    <i class="fa fa-check-circle"/>
                                                                </xsl:when>
                                                                <xsl:when test="$target-date-miss">
                                                                    <i class="fa fa-times-circle"/>
                                                                </xsl:when>
                                                                <xsl:when test="$target-date[@next eq 'true']">
                                                                    <i class="fa fa-exclamation-circle"/>
                                                                </xsl:when>
                                                                <xsl:when test="$status-surpassed">
                                                                    <i class="fa fa-question-circle"/>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                        </td>
                                                        <td class="small">
                                                            <xsl:choose>
                                                                <xsl:when test="$actual-date[@when]">
                                                                    <xsl:value-of select="format-dateTime($actual-date/@when, '[D01] [MNn,*-3] [Y]')"/>
                                                                </xsl:when>
                                                                <xsl:when test="$target-date[@next eq 'true']">
                                                                    <xsl:choose>
                                                                        <xsl:when test="xs:integer($target-date/@due-days) ge 0">
                                                                            <xsl:value-of select="'Due in '"/>
                                                                            <xsl:value-of select="$target-date/@due-days"/>
                                                                            <xsl:value-of select="' days'"/>
                                                                        </xsl:when>
                                                                        <xsl:when test="xs:integer($target-date/@due-days) lt 0">
                                                                            <xsl:value-of select="'Overdue '"/>
                                                                            <xsl:value-of select="abs($target-date/@due-days)"/>
                                                                            <xsl:value-of select="' days'"/>
                                                                        </xsl:when>
                                                                    </xsl:choose>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>

                            </div>
                        </div>

                        <!-- History -->
                        <div class="col-sm-4">
                            <div class="match-height-overflow" data-match-height="status-form">

                                <xsl:apply-templates select="$text/m:status-updates"/>

                            </div>
                        </div>

                    </div>
                    <hr/>
                    <div class="center-vertical full-width">
                        <span>
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:if test="$response/m:text[@locked-by-user gt '']">
                                    <xsl:attribute name="disabled" select="'disabled'"/>
                                </xsl:if>
                                <xsl:value-of select="'Update'"/>
                            </button>
                        </span>
                    </div>
                </form>

            </xsl:with-param>

        </xsl:call-template>

    </xsl:template>

    <!-- Contributors form -->
    <xsl:template name="contributors-form-panel">

        <xsl:param name="active"/>

        <xsl:call-template name="expand-item">

            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'contributors'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>

            <xsl:with-param name="title">
                
                <div class="h4">
                    <xsl:value-of select="'Contributors'"/>
                </div>
                
                <p class="text-muted small sml-margin top">
                    <xsl:value-of select="'Specify the contributors to the translation project'"/>
                </p>
                
            </xsl:with-param>

            <xsl:with-param name="content">

                <xsl:variable name="summary" select="$text/m:publication/m:contributors/m:summary[1]"/>
                <xsl:variable name="translator-team" select="/m:response/m:contributor-teams/m:team[m:instance/@id = $summary/@xml:id]"/>

                <form method="post" class="form-horizontal form-update labels-left top-margin" id="contributors-form" data-loading="Updating contributors...">

                    <xsl:attribute name="action" select="'translation-project.html'"/>

                    <input type="hidden" name="form-action" value="update-contributors"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="$text/@id"/>
                    </input>
                    <input type="hidden" name="form-expand" value="contributors"/>

                    <div class="row">

                        <!-- Specify contributors -->
                        <div class="col-sm-8">

                            <input type="hidden" name="contribution-id-team" value="{ $summary/@xml:id }"/>

                            <!-- Select team -->
                            <div class="form-group bottom-margin">

                                <label class="control-label col-sm-3">
                                    <xsl:value-of select="'Translator Team'"/>
                                </label>

                                <div class="col-sm-9">
                                    <select class="form-control" name="contributor-id-team">
                                        <option value="">
                                            <xsl:value-of select="'[none]'"/>
                                        </option>
                                        <xsl:for-each select="/m:response/m:contributor-teams/m:team">
                                            <option>
                                                <xsl:attribute name="value" select="@xml:id"/>
                                                <xsl:if test="@xml:id = $translator-team/@xml:id">
                                                    <xsl:attribute name="selected" select="'selected'"/>
                                                </xsl:if>
                                                <xsl:value-of select="m:label/text()"/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                </div>

                            </div>

                            <!-- Specify contributors -->
                            <div class="add-nodes-container">

                                <xsl:variable name="team-contributors" select="/m:response/m:contributor-persons/m:person[m:team/@id = $translator-team/@xml:id]"/>
                                <xsl:variable name="other-contributors" select="/m:response/m:contributor-persons/m:person except $team-contributors"/>

                                <xsl:call-template name="contributors-controls">
                                    <xsl:with-param name="text-contributors" select="$text/m:publication/m:contributors/m:*[self::m:author | self::m:editor | self::m:consultant]"/>
                                    <xsl:with-param name="contributor-types" select="/m:response/m:contributor-types/m:contributor-type[@type eq 'translation']"/>
                                    <xsl:with-param name="team-contributors" select="$team-contributors"/>
                                    <xsl:with-param name="other-contributors" select="$other-contributors"/>
                                </xsl:call-template>

                                <div>
                                    <a href="#add-nodes" class="add-nodes">
                                        <span class="monospace">+</span> add a contributor </a>
                                </div>

                            </div>

                        </div>

                        <!-- The attribution in the text -->
                        <div class="col-sm-4">

                            <xsl:if test="$text/m:publication/m:contributors/m:summary">

                                <div class="text-bold">
                                    <xsl:value-of select="'Attribution'"/>
                                </div>

                                <xsl:for-each select="$text/m:publication/m:contributors/m:summary">
                                    <p>
                                        <xsl:apply-templates select="node()"/>
                                    </p>
                                </xsl:for-each>

                                <hr class="sml-margin"/>

                            </xsl:if>

                            <div class="text-bold">
                                <xsl:value-of select="'Acknowledgments'"/>
                            </div>

                            <xsl:choose>
                                <xsl:when test="$text/m:contributors/m:acknowledgement[tei:p]">
                                    <xsl:apply-templates select="$text/m:contributors/m:acknowledgement/tei:p"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <p class="text-muted italic">
                                        <xsl:value-of select="'No acknowledgment text in the TEI'"/>
                                    </p>
                                </xsl:otherwise>
                            </xsl:choose>

                        </div>

                    </div>

                    <xsl:if test="$text/m:contributors/tei:div[@type eq 'acknowledgment']/tei:p">
                        <hr class="sml-margin"/>
                        <div>
                            <p class="small text-muted">
                                <xsl:value-of select="'If a contributor is not automatically recognised in the acknowledgement text then please specify how they are expressed (their &#34;expression&#34;). If a contributor is already highlighted then you can leave this field blank.'"/>
                            </p>
                        </div>
                    </xsl:if>

                    <hr class="sml-margin"/>
                    <div class="form-group">
                        <div class="col-sm-offset-2 col-sm-10">
                            <div class="pull-right">
                                <div class="center-vertical">
                                    <span>
                                        <a>
                                            <xsl:if test="not(/m:response/@model eq 'operations/edit-text-sponsors')">
                                                <xsl:attribute name="target" select="'operations'"/>
                                            </xsl:if>
                                            <xsl:attribute name="href" select="concat($operations-path, '/edit-translator.html')"/>
                                            <xsl:value-of select="'Enter a new contributor'"/>
                                        </a>
                                    </span>
                                    <span>|</span>
                                    <span>
                                        <button type="submit" class="btn btn-primary">
                                            <xsl:if test="/m:response/m:text[@locked-by-user gt '']">
                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Save'"/>
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </xsl:with-param>

        </xsl:call-template>

    </xsl:template>

    <!-- Contributors row -->
    <xsl:template name="contributors-controls">

        <xsl:param name="text-contributors" required="yes"/>
        <xsl:param name="contributor-types" required="yes"/>
        <xsl:param name="team-contributors" as="element(m:person)*"/>
        <xsl:param name="other-contributors" as="element(m:person)*"/>

        <xsl:choose>
            <xsl:when test="$text-contributors">
                <xsl:for-each select="$text-contributors">

                    <xsl:sort select="common:index-of-node($contributor-types, $contributor-types[@node-name eq xs:string(local-name(current()))][@role eq current()/@role])" order="ascending"/>

                    <xsl:variable name="text-contributor" select="."/>
                    <xsl:variable name="contributor-id" select="($team-contributors | $other-contributors)[m:instance/@id = $text-contributor/@xml:id]/@xml:id"/>
                    <xsl:variable name="contributor-type" select="concat(node-name(.), '-', @role)"/>
                    <xsl:variable name="index" select="common:index-of-node($text-contributors, .)"/>

                    <input type="hidden" name="contribution-id-{ $index }" value="{ $text-contributor/@xml:id }"/>

                    <div class="form-group add-nodes-group">

                        <div class="col-sm-3">
                            <xsl:call-template name="select-contributor-type">
                                <xsl:with-param name="contributor-types" select="$contributor-types"/>
                                <xsl:with-param name="control-name" select="concat('contributor-type-', $index)"/>
                                <xsl:with-param name="selected-value" select="$contributor-type"/>
                            </xsl:call-template>
                        </div>

                        <div class="col-sm-3">
                            <xsl:call-template name="select-contributor">
                                <xsl:with-param name="contributor-id" select="$contributor-id"/>
                                <xsl:with-param name="control-name" select="concat('contributor-id-', $index)"/>
                                <xsl:with-param name="team-contributors" select="$team-contributors"/>
                                <xsl:with-param name="other-contributors" select="$other-contributors"/>
                            </xsl:call-template>
                        </div>

                        <label class="control-label col-sm-2">
                            <xsl:value-of select="'expression:'"/>
                        </label>

                        <div class="col-sm-4">
                            <input class="form-control" placeholder="same">
                                <xsl:attribute name="name" select="concat('contributor-expression-', $index)"/>
                                <xsl:if test="$contributor-type != ('summary-')">
                                    <xsl:attribute name="value" select="text()"/>
                                </xsl:if>
                            </input>
                        </div>

                    </div>

                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- No existing contributors so show an set of controls -->

                <input type="hidden" name="contribution-id-1" value=""/>

                <div class="form-group add-nodes-group">

                    <div class="col-sm-3">
                        <xsl:call-template name="select-contributor-type">
                            <xsl:with-param name="contributor-types" select="$contributor-types"/>
                            <xsl:with-param name="control-name" select="'contributor-type-1'"/>
                            <xsl:with-param name="selected-value" select="''"/>
                        </xsl:call-template>
                    </div>

                    <div class="col-sm-3">
                        <xsl:call-template name="select-contributor">
                            <xsl:with-param name="control-name" select="'contributor-id-1'"/>
                            <xsl:with-param name="contributor-id" select="''"/>
                            <xsl:with-param name="team-contributors" select="$team-contributors"/>
                            <xsl:with-param name="other-contributors" select="$other-contributors"/>
                        </xsl:call-template>
                    </div>

                    <label class="control-label col-sm-2">
                        <xsl:value-of select="'expression:'"/>
                    </label>

                    <div class="col-sm-4">
                        <input class="form-control" placeholder="same">
                            <xsl:attribute name="name" select="'contributor-expression-1'"/>
                        </input>
                    </div>

                </div>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Contributor type <select/> -->
    <xsl:template name="select-contributor-type">
        <xsl:param name="contributor-types" required="yes"/>
        <xsl:param name="control-name" required="yes"/>
        <xsl:param name="selected-value" required="yes"/>
        <select class="form-control">
            <xsl:attribute name="name" select="$control-name"/>
            <option value="">
                <xsl:value-of select="'[none]'"/>
            </option>
            <xsl:for-each select="$contributor-types">
                <option>
                    <xsl:variable name="value" select="concat(@node-name, '-', @role)"/>
                    <xsl:attribute name="value" select="$value"/>
                    <xsl:if test="$value eq $selected-value">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="m:label/text()"/>
                </option>
            </xsl:for-each>
        </select>
    </xsl:template>

    <!-- Contributor <select/> -->
    <xsl:template name="select-contributor">

        <xsl:param name="contributor-id" as="xs:string?"/>
        <xsl:param name="control-name" as="xs:string"/>
        <xsl:param name="team-contributors" as="element(m:person)*"/>
        <xsl:param name="other-contributors" as="element(m:person)*"/>

        <select class="form-control">
            <xsl:attribute name="name" select="$control-name"/>
            <option value="">
                <xsl:value-of select="'[none]'"/>
            </option>
            <xsl:if test="$team-contributors">
                <xsl:for-each select="$team-contributors">
                    <option>
                        <xsl:attribute name="value" select="@xml:id"/>
                        <xsl:if test="@xml:id eq $contributor-id">
                            <xsl:attribute name="selected" select="'selected'"/>
                        </xsl:if>
                        <xsl:value-of select="m:label/text()"/>
                    </option>
                </xsl:for-each>
                <option value="">-</option>
            </xsl:if>
            <xsl:for-each select="$other-contributors">
                <option>
                    <xsl:attribute name="value" select="@xml:id"/>
                    <xsl:if test="@xml:id eq $contributor-id">
                        <xsl:attribute name="selected" select="'selected'"/>
                    </xsl:if>
                    <xsl:value-of select="m:label/text()"/>
                </option>
            </xsl:for-each>
        </select>

    </xsl:template>

    <!-- Submissions form -->
    <xsl:template name="submissions-form-panel">

        <xsl:param name="active"/>

        <xsl:call-template name="expand-item">

            <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
            <xsl:with-param name="id" select="'submissions'"/>
            <xsl:with-param name="active" select="$active"/>
            <xsl:with-param name="persist" select="true()"/>

            <xsl:with-param name="title">
                
                <div class="center-vertical align-left">
                    
                    <span class="h4">
                        <xsl:value-of select="'Submissions'"/>
                    </span>
                    
                    <span>
                        <span class="badge badge-notification badge-muted">
                            <xsl:value-of select="count($translation-status/m:text/m:submission)"/>
                        </span>
                    </span>
                    
                </div>
                
                <p class="text-muted small sml-margin top">
                    <xsl:value-of select="'Upload draft translations'"/>
                </p>
                
            </xsl:with-param>

            <xsl:with-param name="content">
                
                <xsl:for-each select="$translation-status/m:text/m:submission">

                    <xsl:variable name="submission" select="."/>

                    <div class="row">
                        <div class="col-sm-8">
                            <a>
                                <xsl:attribute name="href" select="concat('/edit-text-submission.html?text-id=', $text/@id,'&amp;submission-id=', $submission/@id)"/>
                                <xsl:value-of select="$submission/@file-name"/>
                            </a>
                        </div>
                        <div class="col-sm-4 text-right text-muted italic small">
                            <xsl:value-of select="common:date-user-string('Submited', $submission/@date-time, $submission/@user)"/>
                        </div>
                        <div class="col-sm-12">
                            <xsl:choose>

                                <xsl:when test="$submission/@file-type eq 'spreadsheet'">
                                    <xsl:if test="$submission/@latest eq 'true'">
                                        <span class="label label-success">
                                            <i class="fa fa-check"/>
                                            <xsl:value-of select="' Latest spreadsheet'"/>
                                        </span>
                                    </xsl:if>
                                    <xsl:for-each select="/m:response/m:submission-checklist/m:spreadsheet/m:item">
                                        <xsl:variable name="item" select="."/>
                                        <span class="label label-default">
                                            <xsl:if test="$submission/m:item-checked[@item-id eq $item/@id]">
                                                <xsl:if test="$submission/@latest eq 'true'">
                                                    <xsl:attribute name="class" select="'label label-success'"/>
                                                </xsl:if>
                                                <i class="fa fa-check"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(' ', $item/text())"/>
                                        </span>
                                    </xsl:for-each>
                                </xsl:when>

                                <xsl:when test="$submission/@file-type eq 'document'">
                                    <xsl:if test="$submission/@latest eq 'true'">
                                        <span class="label label-primary">
                                            <i class="fa fa-check"/>
                                            <xsl:value-of select="' Latest document'"/>
                                        </span>
                                    </xsl:if>
                                    <xsl:for-each select="/m:response/m:submission-checklist/m:document/m:item">
                                        <xsl:variable name="item" select="."/>
                                        <span class="label label-default">
                                            <xsl:if test="$submission/m:item-checked[@item-id eq $item/@id]">
                                                <xsl:if test="$submission/@latest eq 'true'">
                                                    <xsl:attribute name="class" select="'label label-primary'"/>
                                                </xsl:if>
                                                <i class="fa fa-check"/>
                                            </xsl:if>
                                            <xsl:value-of select="concat(' ', $item/text())"/>
                                        </span>
                                    </xsl:for-each>
                                </xsl:when>
                            </xsl:choose>

                            <span class="label label-default">
                                <xsl:if test="$submission/m:tei-file/@file-exists eq 'true'">
                                    <xsl:choose>
                                        <xsl:when test="$submission/@latest eq 'true' and $submission/@file-type eq 'spreadsheet'">
                                            <xsl:attribute name="class" select="'label label-success'"/>
                                        </xsl:when>
                                        <xsl:when test="$submission/@latest eq 'true' and $submission/@file-type eq 'document'">
                                            <xsl:attribute name="class" select="'label label-primary'"/>
                                        </xsl:when>
                                    </xsl:choose>
                                    <i class="fa fa-check"/>
                                </xsl:if>
                                <xsl:value-of select="' Generate TEI'"/>
                            </span>

                        </div>
                    </div>
                    
                    <hr/>
                    
                </xsl:for-each>

                <form method="post" enctype="multipart/form-data" class="form-horizontal form-update labels-left" id="submissions-form" data-loading="Uploading submission...">

                    <xsl:attribute name="action" select="'translation-project.html'"/>

                    <input type="hidden" name="form-action" value="process-upload"/>
                    <input type="hidden" name="post-id">
                        <xsl:attribute name="value" select="$text/@id"/>
                    </input>
                    <input type="hidden" name="form-expand" value="submissions"/>

                    <div class="form-group">
                        <div class="col-sm-10">
                            <input type="file" name="submit-translation-file" id="submit-translation-file" required="required" accept=".doc,.docx,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/pdf"/>
                        </div>
                        <div class="col-sm-2">
                            <button type="submit" class="btn btn-primary pull-right">
                                <xsl:value-of select="'Upload a file'"/>
                            </button>
                        </div>
                    </div>

                </form>

            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <!-- Generated files -->
    <xsl:template name="generated-files-panel">

        <xsl:param name="active"/>
        
        <xsl:call-template name="expand-item">
                
                <xsl:with-param name="accordion-selector" select="'#forms-accordion'"/>
                <xsl:with-param name="id" select="'generated-files'"/>
                <xsl:with-param name="active" select="$active"/>
                <xsl:with-param name="persist" select="true()"/>            
                <xsl:with-param name="title">
                    
                    <xsl:variable name="count-files" select="count($text/m:files/m:file) + count($text/m:api-status/m:api-call)"/>
                    <xsl:variable name="count-missing" select="count(($text/m:files/m:file[@publish][not(@timestamp[not(. = ('none',''))])], $text/m:api-status/m:api-call[@publish][not(@timestamp[not(. = ('none',''))])]))"/>
                    <xsl:variable name="count-updates" select="count(($text/m:files/m:file[@publish], $text/m:api-status/m:api-call[@publish])) - $count-missing"/>
                    <xsl:variable name="count-manual" select="count(($text/m:files/m:file[@action eq 'manual'][not(@up-to-date)], $text/m:api-status/m:api-call[@action eq 'manual'][not(@up-to-date)]))"/>
                    <xsl:variable name="count-scheduled" select="count(($text/m:files/m:file[@action eq 'scheduled'][not(@up-to-date)], $text/m:api-status/m:api-call[@action eq 'scheduled'][not(@up-to-date)]))"/>
                    
                    <div class="center-vertical align-left">
                        
                        <span class="h4">
                            <xsl:value-of select="'Publish content'"/>
                        </span>
                        
                        <span>
                            <span class="badge badge-notification badge-muted">
                                <xsl:value-of select="format-number($count-files, '#,###')"/>
                            </span>
                        </span>
                        
                    </div>
                    
                    <p class="text-muted small sml-margin top">
                        <xsl:value-of select="'Once all revisions to a text have been completed and signed off, use these options to generate publication files. Updated files are be published to the public site once a day.'"/>
                    </p>
                    
                    <div class="center-vertical align-left bottom-margin">
                        
                        <xsl:if test="$count-missing gt 0">
                            <span>
                                <span class="label label-danger">
                                    <xsl:value-of select="format-number($count-missing, '#,###')"/>
                                </span>
                                <span class="text-danger small">
                                    <xsl:value-of select="concat(($count-missing[. eq 1] ! ' file', ' files')[1], ' to be created')"/>
                                </span>
                            </span>
                        </xsl:if>
                        
                        <xsl:if test="$count-updates gt 0">
                            <span>
                                <span class="label label-warning">
                                    <xsl:value-of select="format-number($count-updates, '#,###')"/>
                                </span>
                                <span class="text-warning small">
                                    <xsl:value-of select="concat(($count-updates[. eq 1] ! ' file', ' files')[1], ' older than the TEI timestamp')"/>
                                </span>
                            </span>
                        </xsl:if>
                        
                        <xsl:if test="$count-manual gt 0">
                            <span>
                                <span class="label label-warning">
                                    <xsl:value-of select="format-number($count-manual, '#,###')"/>
                                </span>
                                <span class="text-warning small">
                                    <xsl:value-of select="($count-manual[. eq 1] ! ' manual update', ' scheduled updates')[1]"/>
                                </span>
                            </span>
                        </xsl:if>
                        
                        <xsl:if test="$count-scheduled gt 0">
                            <span>
                                <span class="label label-warning">
                                    <xsl:value-of select="format-number($count-scheduled, '#,###')"/>
                                </span>
                                <span class="text-warning small">
                                    <xsl:value-of select="($count-scheduled[. eq 1] ! ' scheduled update', ' scheduled updates')[1]"/>
                                </span>
                            </span>
                        </xsl:if>
                        
                        <xsl:if test="$response/scheduler:job">
                            <span>
                                <span class="label label-danger">
                                    <xsl:value-of select="'Generating files and publishing...'"/>
                                </span>
                            </span>
                            <span>
                                <a title="Re-load status" class="small underline">
                                    <xsl:attribute name="href" select="concat('/translation-project.html?id=', $text/@id, '&amp;form-expand=generated-files#forms-accordion')"/>
                                    <xsl:attribute name="data-ajax-target" select="'#forms-accordion'"/>
                                    <xsl:attribute name="data-autoclick-seconds" select="10"/>
                                    <xsl:value-of select="'re-load'"/>
                                </a>
                            </span>
                        </xsl:if>
                    
                    </div>
                    
                </xsl:with-param>
                
                <xsl:with-param name="content">
                    
                    <div>
                        
                        <xsl:if test="$text/m:files[@glossary-locations-timestamp[. gt '']][@glossary-locations-timestamp ! xs:dateTime(.) lt @tei-timestamp ! xs:dateTime(.)]">
                            <div class="center-vertical align-left">
                                <span class="icon">
                                    <i class="fa fa-exclamation-circle" title="Warning"/>
                                </span>
                                <span>
                                    <span class="text-warning small">
                                        <xsl:value-of select="concat('The TEI has been updated since the last glossary locations cache (', format-dateTime($text/m:files/@glossary-locations-timestamp, '[D01] [MNn,*-3] [Y0001] [H01]:[m01]'), '). Consider re-caching the glossary locations.')"/>
                                    </span>
                                </span>
                                <span>
                                    <a class="underline small" target="84000-glossary-editor">
                                        <xsl:attribute name="href" select="concat('/edit-glossary.html?resource-id=', $text/@id)"/>
                                        <xsl:value-of select="'Glossary editor'"/>
                                    </a>
                                </span>
                            </div>
                        </xsl:if>
                        
                        <!--<hr class="sml-margin"/>-->
                        
                        <div class="sml-margin top bottom text-right">
                            <span class="small">
                                <xsl:value-of select="'TEI timestamp: '"/>
                            </span>
                            <xsl:choose>
                                <xsl:when test="$text/m:files/@tei-timestamp[not(. = ('none', ''))]">
                                    <span class="label label-info">
                                        <span class="monospace">
                                            <xsl:value-of select="format-dateTime($text/m:files/@tei-timestamp, '[D01] [MNn,*-3] [Y0001] [H01]:[m01]')"/>
                                        </span>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="label label-default">
                                        <span class="monospace">
                                            <xsl:value-of select="'[unknown]'"/>
                                        </span>
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        
                        <form method="POST" data-loading="Initiating file generation...">
                            
                            <xsl:attribute name="action" select="concat('/translation-project.html?id=', $text/@id)"/>
                            
                            <input type="hidden" name="form-action" value="publish-content"/>
                            
                            <div class="list-group accordion accordion-bordered" role="tablist" aria-multiselectable="false" id="generated-files-accordion">
                                
                                <!-- Translation files -->
                                <xsl:for-each select="('translation-html', 'translation-files', 'source-html', 'glossary-html')">
                                    
                                    <xsl:variable name="files-group-name" select="."/>
                                    <xsl:variable name="files-group" select="$text/m:files/m:file[@group eq $files-group-name]"/>
                                    
                                    <xsl:if test="$files-group">
                                        <xsl:call-template name="expand-item">
                                            
                                            <xsl:with-param name="accordion-selector" select="'#generated-files-accordion'"/>
                                            <xsl:with-param name="id" select="concat('generated-files-', $files-group-name)"/>
                                            <xsl:with-param name="active" select="false()"/>
                                            <xsl:with-param name="persist" select="true()"/>
                                            
                                            <xsl:with-param name="title">
                                                <div class="center-vertical align-left">
                                                    <span class="icon">
                                                        <xsl:choose>
                                                            <xsl:when test="count($files-group[@up-to-date]) eq count($files-group)">
                                                                <i class="fa fa-check-circle" title="Files published"/>
                                                            </xsl:when>
                                                            <xsl:when test="count($files-group[@action = ('scheduled','manual') or @timestamp[not(. = ('none', ''))]]) eq count($files-group)">
                                                                <i class="fa fa-exclamation-circle" title="Updates scheduled"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <i class="fa fa-times-circle" title="Updates remaining"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    <span>
                                                        <xsl:choose>
                                                            <xsl:when test="$files-group-name eq 'translation-html'">
                                                                <xsl:value-of select="'Translation pages'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$files-group-name eq 'translation-files'">
                                                                <xsl:value-of select="'Translation files (PDF, EPUB etc.)'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$files-group-name eq 'source-html'">
                                                                <xsl:value-of select="'Source pages'"/>
                                                            </xsl:when>
                                                            <xsl:when test="$files-group-name eq 'glossary-html'">
                                                                <xsl:value-of select="'Glossary pages'"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="concat($files-group-name, ' pages')"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    <span>
                                                        <span class="badge badge-notification badge-muted">
                                                            <xsl:value-of select="format-number(count($files-group), '#,###')"/>
                                                        </span>
                                                    </span>
                                                    <xsl:choose>
                                                        <xsl:when test="$files-group[@publish]">
                                                            <span>
                                                                <div class="checkbox-inline">
                                                                    <label class="small text-danger">
                                                                        <input type="checkbox" name="publish-file-group[]" value="{ $files-group-name }">
                                                                            <xsl:if test="$response/scheduler:job">
                                                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                                                                <xsl:attribute name="class" select="'disabled'"/>
                                                                            </xsl:if>
                                                                        </input>
                                                                        <xsl:value-of select="' include'"/>
                                                                    </label>
                                                                </div>
                                                            </span>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </div>
                                            </xsl:with-param>
                                            
                                            <xsl:with-param name="content">
                                                <xsl:call-template name="status-table">
                                                    <xsl:with-param name="items" select="$files-group"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                            
                                        </xsl:call-template>
                                    </xsl:if>
                                    
                                </xsl:for-each>
                                
                            </div>
                            
                            <div class="bottom-margin text-right">
                                <xsl:choose>
                                    <xsl:when test="$text/m:files/m:file[@group = ('translation-html', 'translation-files', 'source-html', 'glossary-html')][@publish]">
                                        <button type="submit" class="btn btn-danger">
                                            <xsl:if test="$response/scheduler:job">
                                                <xsl:attribute name="class" select="'btn btn-danger disabled'"/>
                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Generate files'"/>
                                        </button>
                                    </xsl:when>
                                </xsl:choose>
                            </div>
                            
                        </form>
                        
                        <form method="POST" data-loading="Initiating listings update...">
                            
                            <xsl:attribute name="action" select="concat('/translation-project.html?id=', $text/@id)"/>
                            
                            <input type="hidden" name="form-action" value="publish-content"/>
                            
                            <div class="list-group accordion accordion-bordered" role="tablist" aria-multiselectable="false" id="publication-listings-accordion">
                                
                                <!-- Translation listings -->
                                <xsl:variable name="files-group-name" select="'publications-list'"/>
                                <xsl:variable name="files-group" select="$text/m:files/m:file[@group eq $files-group-name]"/>
                                
                                <xsl:if test="$files-group">
                                    <xsl:call-template name="expand-item">
                                        
                                        <xsl:with-param name="accordion-selector" select="'#publication-listings-accordion'"/>
                                        <xsl:with-param name="id" select="'publication-listings-publications-list'"/>
                                        <xsl:with-param name="active" select="false()"/>
                                        <xsl:with-param name="persist" select="true()"/>
                                        
                                        <xsl:with-param name="title">
                                            <div class="center-vertical align-left">
                                                <span class="icon">
                                                    <xsl:choose>
                                                        <xsl:when test="count($files-group[@up-to-date]) eq count($files-group)">
                                                            <i class="fa fa-check-circle" title="Files published"/>
                                                        </xsl:when>
                                                        <xsl:when test="count($files-group[@action = ('scheduled','manual') or @timestamp[not(. = ('none', ''))]]) eq count($files-group)">
                                                            <i class="fa fa-exclamation-circle" title="Updates scheduled"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <i class="fa fa-times-circle" title="Updates remaining"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                <span>
                                                    <xsl:value-of select="'Publication listings'"/>
                                                </span>
                                                <span>
                                                    <span class="badge badge-notification badge-muted">
                                                        <xsl:value-of select="format-number(count($files-group), '#,###')"/>
                                                    </span>
                                                </span>
                                                <xsl:choose>
                                                    <xsl:when test="$files-group[@publish]">
                                                        <span>
                                                            <div class="checkbox-inline">
                                                                <label class="small text-danger">
                                                                    <input type="checkbox" name="publish-file-group[]" value="{ $files-group-name }">
                                                                        <xsl:if test="$response/scheduler:job">
                                                                            <xsl:attribute name="disabled" select="'disabled'"/>
                                                                            <xsl:attribute name="class" select="'disabled'"/>
                                                                        </xsl:if>
                                                                    </input>
                                                                    <xsl:value-of select="' include'"/>
                                                                </label>
                                                            </div>
                                                        </span>
                                                    </xsl:when>
                                                </xsl:choose>
                                            </div>
                                        </xsl:with-param>
                                        
                                        <xsl:with-param name="content">
                                            <xsl:call-template name="status-table">
                                                <xsl:with-param name="items" select="$files-group"/>
                                            </xsl:call-template>
                                        </xsl:with-param>
                                        
                                    </xsl:call-template>
                                </xsl:if>
                                
                                <!-- API status -->
                                <xsl:variable name="api-calls" select="$text/m:api-status/m:api-call[@type eq 'webflow-api']"/>
                                <xsl:call-template name="expand-item">
                                    
                                    <xsl:with-param name="accordion-selector" select="'#publication-listings-accordion'"/>
                                    <xsl:with-param name="id" select="'publication-listings-webflow-api'"/>
                                    <xsl:with-param name="active" select="false()"/>
                                    <xsl:with-param name="persist" select="true()"/>
                                    
                                    <xsl:with-param name="title">
                                        <div class="center-vertical align-left">
                                            
                                            <span class="icon">
                                                <xsl:choose>
                                                    <xsl:when test="count($api-calls[@up-to-date]) eq count($api-calls)">
                                                        <i class="fa fa-check-circle" title="Updates published"/>
                                                    </xsl:when>
                                                    <xsl:when test="count($api-calls[@action eq 'scheduled' or @timestamp[not(. = ('none', ''))]]) eq count($api-calls)">
                                                        <i class="fa fa-exclamation-circle" title="Updates scheduled"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <i class="fa fa-times-circle" title="Updates remaining"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </span>
                                            
                                            <span>
                                                <xsl:value-of select="'Webflow CMS updates'"/>
                                            </span>
                                            
                                            <span>
                                                <span class="badge badge-notification badge-muted">
                                                    <xsl:value-of select="format-number(count($api-calls), '#,###')"/>
                                                </span>
                                            </span>
                                            
                                            <xsl:choose>
                                                <xsl:when test="not($api-calls[@publish])">
                                                    <span>
                                                        <div class="checkbox-inline">
                                                            <label class="small text-danger">
                                                                <input type="checkbox" name="publish-file-group[]" value="webflow-api">
                                                                    <xsl:if test="$response/scheduler:job">
                                                                        <xsl:attribute name="disabled" select="'disabled'"/>
                                                                        <xsl:attribute name="class" select="'disabled'"/>
                                                                    </xsl:if>
                                                                </input>
                                                                <xsl:value-of select="' include'"/>
                                                            </label>
                                                        </div>
                                                    </span>
                                                </xsl:when>
                                            </xsl:choose>
                                            
                                        </div>
                                    </xsl:with-param>
                                    
                                    <xsl:with-param name="content">
                                        <xsl:call-template name="status-table">
                                            <xsl:with-param name="items" select="$api-calls"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                    
                                </xsl:call-template>
                                
                            </div>
                            
                            <div class="bottom-margin text-right">
                                <xsl:choose>
                                    <xsl:when test="($text/m:files/m:file[@group eq 'publications-list'][@publish], $text/m:api-status/m:api-call[@publish])">
                                        <button type="submit" class="btn btn-danger">
                                            <xsl:if test="$response/scheduler:job">
                                                <xsl:attribute name="class" select="'btn btn-danger disabled'"/>
                                                <xsl:attribute name="disabled" select="'disabled'"/>
                                            </xsl:if>
                                            <xsl:value-of select="'Update listings'"/>
                                        </button>
                                    </xsl:when>
                                </xsl:choose>
                            </div>
                            
                        </form>
                        
                    </div>
                    
                </xsl:with-param>
                
            </xsl:call-template>
        
    </xsl:template>

    <xsl:template name="status-table">

        <xsl:param name="items" as="element()*"/>

        <table class="table table-responsive table-icons">
            <thead>
                <tr>
                    <th>
                        <xsl:value-of select="'Source'"/>
                    </th>
                    <xsl:if test="$items[@linked]">
                        <th class="icon">
                            <xsl:value-of select="'Linked'"/>
                        </th>
                    </xsl:if>
                    <th>
                        <xsl:value-of select="'Target'"/>
                    </th>
                    <th style="width:150px">
                        <xsl:value-of select="'Timestamp'"/>
                    </th>
                    <th class="text-right" style="width:40px">
                        <!--<xsl:value-of select="'Up-to-date'"/>-->
                    </th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="$items">
                    <tr class="vertical-middle">
                        <td>
                            <xsl:choose>
                                <xsl:when test="@source[. gt ''] and @target-file[. gt ''] and @target-url[. gt '']">
                                    <a class="monospace small">
                                        <xsl:attribute name="href" select="concat($reading-room-path, @source)"/>
                                        <xsl:attribute name="target" select="concat('source-', @target-file)"/>
                                        <xsl:value-of select="@source"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="monospace small">
                                        <xsl:value-of select="@source"/>
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <xsl:if test="$items[@linked]">
                            <td class="icon">
                                <xsl:choose>
                                    <xsl:when test="not(@linked eq 'true')">
                                        <i class="fa fa-times-circle" title="Item not-linked"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i class="fa fa-check-circle" title="Item linked"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </xsl:if>
                        <td>
                            <xsl:choose>
                                <xsl:when test="@target-file[. gt ''] and @target-url[. gt '']">
                                    <a class="monospace small">
                                        <xsl:attribute name="href" select="@target-url"/>
                                        <xsl:attribute name="target" select="concat('target-', @target-file)"/>
                                        <xsl:value-of select="string-join((@target-folder, @target-file), '/')"/>
                                    </a>
                                </xsl:when>
                                <xsl:when test="@target-file[. gt '']">
                                    <span class="monospace small">
                                        <xsl:value-of select="string-join((@target-folder, @target-file), '/')"/>
                                    </span>
                                </xsl:when>
                                <xsl:when test="@target-call[. gt '']">
                                    <span class="monospace small">
                                        <xsl:value-of select="string-join((@target-call, @target-id), '/')"/>
                                    </span>
                                </xsl:when>
                                
                            </xsl:choose>
                            
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="@up-to-date and @timestamp[not(. = ('none', ''))]">
                                    <span class="label label-default">
                                        <span class="monospace">
                                            <xsl:value-of select="format-dateTime(@timestamp, '[D01] [MNn,*-3] [Y0001] [H01]:[m01]')"/>
                                        </span>
                                    </span>
                                </xsl:when>
                                <xsl:when test="@timestamp[not(. = ('none', ''))]">
                                    <span class="label label-warning">
                                        <span class="monospace">
                                            <xsl:value-of select="format-dateTime(@timestamp, '[D01] [MNn,*-3] [Y0001] [H01]:[m01]')"/>
                                        </span>
                                    </span>
                                </xsl:when>
                                <xsl:when test="@action eq 'scheduled'">
                                    <span class="label label-info">
                                        <span class="monospace">
                                            <xsl:value-of select="'[scheduled]'"/>
                                        </span>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="label label-danger">
                                        <span class="monospace">
                                            <xsl:value-of select="'[unknown]'"/>
                                        </span>
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="icon text-right">
                            <xsl:choose>
                                <xsl:when test="@up-to-date">
                                    <i class="fa fa-check-circle" title="Updated"/>
                                </xsl:when>
                                <xsl:when test="@action eq 'scheduled'">
                                    <i class="fa fa-exclamation-circle" title="Scheduled"/>
                                </xsl:when>
                                <xsl:when test="@action eq 'manual'">
                                    <i class="fa fa-exclamation-circle" title="Action required"/>
                                </xsl:when>
                                <xsl:when test="@timestamp[not(. = ('none', ''))]">
                                    <i class="fa fa-exclamation-circle" title="Action required"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <i class="fa fa-times-circle" title="Update required"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>

    </xsl:template>

</xsl:stylesheet>