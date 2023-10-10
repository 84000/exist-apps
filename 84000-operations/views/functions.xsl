<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <!-- <input type="text"/> -->
    <xsl:function name="ops:text-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div>
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <input type="text" class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:attribute name="value" select="$value"/>
                    <xsl:attribute name="class" select="concat('form-control', ' ', $css-class)"/>
                    <xsl:if test="contains($css-class, 'disabled')">
                        <xsl:attribute name="disabled" select="'disabled'"/>
                    </xsl:if>
                    <xsl:if test="contains($css-class, 'required')">
                        <xsl:attribute name="required" select="'required'"/>
                    </xsl:if>
                </input>
            </div>
        </div>
    </xsl:function>
    
    <!-- Sequence of <input type="text"/> elements -->
    <xsl:function name="ops:text-multiple-input">
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="values"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="css-class"/>
        <xsl:for-each select="$values">
            <xsl:choose>
                <xsl:when test="position() = 1">
                    <xsl:sequence select="ops:text-input($label, concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="ops:text-input('+', concat($name, '-', position()), text(), $size, $css-class)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:sequence select="ops:text-input('+', concat($name, '-', (count($values) + 1)), '', $size, $css-class)"/>
    </xsl:function>
    
    <!-- <select/> -->
    <xsl:function name="ops:select-input">
        <!-- $options sequence requires @value and @selected attributes -->
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="rows"/>
        <xsl:param name="options"/>
        <div class="form-group">
            <label>
                <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                <xsl:attribute name="for" select="$name"/>
                <xsl:value-of select="$label"/>
            </label>
            <div class="col-sm-10">
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <select class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <xsl:if test="$rows gt 1">
                        <xsl:attribute name="multiple" select="'multiple'"/>
                        <xsl:attribute name="size" select="$rows"/>
                    </xsl:if>
                    <xsl:for-each select="$options">
                        <option>
                            <xsl:attribute name="value" select="@value"/>
                            <xsl:if test="@selected eq 'selected'">
                                <xsl:attribute name="selected" select="@selected"/>
                            </xsl:if>
                            <xsl:value-of select="text()"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:function>
    
    <!-- <select/> variation -->
    <xsl:function name="ops:select-input-name">
        <!-- $options sequence requires m:name, m:label or text() and @xml:id or @id elements -->
        <xsl:param name="label"/>
        <xsl:param name="name"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:param name="options"/>
        <xsl:param name="selected-id"/>
        <div class="form-group">
            <xsl:if test="$label">
                <label>
                    <xsl:attribute name="class" select="concat('control-label col-sm-', xs:string(12 - $size))"/>
                    <xsl:attribute name="for" select="$name"/>
                    <xsl:value-of select="$label"/>
                </label>
            </xsl:if>
            <div>
                <xsl:attribute name="class" select="concat('col-sm-', $size)"/>
                <select class="form-control">
                    <xsl:attribute name="name" select="$name"/>
                    <xsl:attribute name="id" select="$name"/>
                    <option value="">
                        <xsl:value-of select="'[none]'"/>
                    </option>
                    <xsl:for-each select="$options">
                        <xsl:variable name="option-id" select="(@xml:id, @id)[1]"/>
                        <xsl:variable name="text" select="if (m:name | m:label) then (m:name | m:label)[1] else text()"/>
                        <option>
                            <xsl:attribute name="value" select="$option-id"/>
                            <xsl:if test="$option-id eq $selected-id">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="$text"/>
                        </option>
                    </xsl:for-each>
                </select>
            </div>
        </div>
    </xsl:function>
    
    <!-- Translation status -->
    <xsl:function name="ops:translation-status">
        <xsl:param name="status-group"/>
        <xsl:choose>
            <xsl:when test="$status-group eq 'published'">
                <span class="label label-success published">
                    <xsl:value-of select="'Published'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'translated'">
                <span class="label label-warning in-progress">
                    <xsl:value-of select="'In progress'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'in-translation'">
                <span class="label label-warning in-progress">
                    <xsl:value-of select="'In progress'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'in-application'">
                <span class="label label-danger in-progress">
                    <xsl:value-of select="'Application pending'"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="label label-default">
                    <xsl:value-of select="'Not Started'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Sponsorship status -->
    <xsl:function name="ops:sponsorship-status">
        <xsl:param name="sponsorship-statuses"/>
        <xsl:for-each select="$sponsorship-statuses">
            <xsl:if test="not(@id eq 'no-sponsorship')">
                <span>
                    <xsl:choose>
                        <xsl:when test="@id = 'available'">
                            <xsl:attribute name="class" select="'nowrap label label-success'"/>
                        </xsl:when>
                        <xsl:when test="@id = 'full'">
                            <xsl:attribute name="class" select="'nowrap label label-info'"/>
                        </xsl:when>
                        <xsl:when test="@id = ('part', 'reserved', 'priority')">
                            <xsl:attribute name="class" select="'nowrap label label-warning'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class" select="'nowrap label label-default'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="m:label"/>
                </span>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Standardise wayward lang ids -->
    <xsl:function name="ops:lang-class" as="xs:string?">
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="lower-case($lang) eq 'bo'">
                <xsl:value-of select="'text-bo'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'sa-ltn'">
                <xsl:value-of select="'text-sa'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                <xsl:value-of select="'text-wy'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = ('eng', 'en')">
                <xsl:value-of select="'text-en'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'zh'">
                <xsl:value-of select="'text-zh'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'ja'">
                <xsl:value-of select="'text-ja'"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="ops:class-attribute">
        
        <xsl:param name="classes" as="xs:string*"/>
        <xsl:param name="lang" as="xs:string?"/>
        
        <xsl:variable name="class-str" select="string-join(($classes, $lang ! ops:lang-class(.)), ' ')"/>
        
        <xsl:if test="$class-str gt ''">
            <xsl:attribute name="class" select="$class-str"/>
        </xsl:if>
        
    </xsl:template>
    
    <!-- Limit string length ... -->
    <xsl:function name="ops:limit-str" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="max-length" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string-length($string) gt $max-length ">
                <xsl:value-of select="concat(substring($string ,1, $max-length), '...')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Set number of rows for a <textarea/> -->
    <xsl:function name="ops:textarea-rows" as="xs:integer">
        
        <xsl:param name="content" as="xs:string?"/>
        <xsl:param name="default-rows" as="xs:integer"/>
        <xsl:param name="chars-per-row" as="xs:integer"/>
        
        <xsl:variable name="lines" select="$content ! sum(tokenize(., '\n') ! ceiling((string-length(.) + 1) div $chars-per-row))"/>
        
        <xsl:value-of select="if($lines gt $default-rows) then $lines else $default-rows"/>
        
    </xsl:function>
    
    <!-- Translate number to letter -->
    <xsl:function name="ops:position-to-letter" as="xs:string">
        
        <xsl:param name="position" as="xs:integer"/>
        
        <xsl:variable name="alphabet" select="'abcdefghijklmnopqursuvwxyz'"/>
        <xsl:variable name="position-mod" select="$position mod string-length($alphabet)"/>
        
        <xsl:value-of select="substring($alphabet, $position-mod, 1)"/>
        
    </xsl:function>
    
    <!-- Find position of a node in a collection -->
    <xsl:function name="ops:index-of-node" as="xs:integer*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="nodeToFind" as="node()?"/>
        <xsl:sequence select="for $seq in (1 to count($nodes)) return $seq[$nodes[$seq] is $nodeToFind]"/>
    </xsl:function>
    
    <!-- Set element namespace recurring -->
    <xsl:function name="ops:change-element-ns-deep" as="node()*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="newns" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:for-each select="$nodes">
            <xsl:variable name="node" select="."/>
            <xsl:choose>
                <xsl:when test="$node instance of element()">
                    <xsl:element name="{concat($prefix, if ($prefix = '') then '' else ':', local-name($node))}" namespace="{$newns}">
                        <xsl:sequence select="($node/@*, ops:change-element-ns-deep($node/node(), $newns, $prefix))"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$node instance of document-node()">
                    <xsl:document>
                        <xsl:sequence select="ops:change-element-ns-deep($node/node(), $newns, $prefix)"/>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$node"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Repeat a string, Repeat a string, ... -->
    <xsl:function name="ops:repeat-string" as="xs:string">
        <xsl:param name="stringToRepeat" as="xs:string?"/>
        <xsl:param name="count" as="xs:integer"/>
        
        <xsl:sequence select="string-join((for $i in 1 to $count return $stringToRepeat),'')"/>
        
    </xsl:function>
    
    <!-- MARKDOWN templates:
        
        Markdown                       XML                                              Notes / Conditions
        ~~~~~~~~~~~~~~~~~~~~~~~~       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        text                      <->  <p>text</p>                                      Where text is on a new line
        (tag)                     <->  <tag/>                                           Where tag is on a new line e.g. <lb/>
        (tag id:abc)              <->  <tag xml:id="abc"/>                              Where tag is on a new line e.g. <milestone/>
        [data](tag)               <->  <tag>data</tag>
        [data](tag lang:bo)       <->  <tag xml:lang="bo">data</tag>
        [data[[data]](tag)](tag)  <->  <tag xml:lang="bo">data[[data]](tag)</tag>       Match the outermost brackets, then recurse.
        [data](bo)                <->  <foreign xml:lang="bo">data</foreign>            Where lang is known-lang
        [data](http://abc)        <->  <ref target="http://abc">data</ref>              Valid for http: and https:
        
    -->
    <xsl:variable name="element-regex" select="'(?:^\s*|\[((?:\[{2,}|\]{2,}|[^\[\]])+)\])\((.+?)\)'"/>
    <xsl:variable name="heading-regex" select="'^\s*#+\s+'"/>
    <xsl:variable name="bullet-item-regex" select="'^\s*\*\s+'"/>
    <xsl:variable name="numbers-item-regex" select="'^\s*\d\.\s+'"/>
    <xsl:variable name="letters-item-regex" select="'^\s*[a-zA-Z]\.\s+'"/>
    <xsl:variable name="endnote-regex" select="'^\s*n\.\d\s+'"/>
    
    <!-- 
        Known languages can be used in short codes 
        e.g. [data](bo) -> <foreign xml:lang="bo">data</foreign>
    -->
    <xsl:variable name="known-langs" select="('bo', 'en', 'zh', 'Sa-Ltn', 'Bo-Ltn', 'Pi-Ltn')"/>
    
    <!-- Return character for new lines in markdown -->
    <xsl:variable name="char-nl" select="'&#xA;'"/>
    
    <xsl:function name="markdown:new-line">
        <xsl:param name="position"/>
        <xsl:if test="$position gt 1">
            <xsl:value-of select="$char-nl || $char-nl"/>
        </xsl:if>
    </xsl:function>
    
    <!-- Tei -> Markdown -->
    <xsl:template match="tei:div[@type eq 'markup']">
        
        <xsl:variable name="markup" select="."/>
        <!-- The element to convert for a new-line -->
        <xsl:variable name="newline-element" select="($markup/@newline-element, 'p')[1]" as="xs:string"/>
        
        <xsl:element name="markdown" namespace="http://read.84000.co/ns/1.0">
            
            <!-- Loop through nodes formatting everything to markdown strings -->
            <xsl:for-each select="$markup/node()[normalize-space(data())]">
                
                <xsl:choose>
                    
                    <!-- Text node -->
                    <xsl:when test=". instance of text() and normalize-space(.) gt ''">
                        
                        <xsl:call-template name="markdown:string">
                            <xsl:with-param name="node" select="."/>
                        </xsl:call-template>
                        
                    </xsl:when>
                    
                    <!-- Element -->
                    <xsl:when test=". instance of element()">
                        <xsl:choose>
                            
                            <!-- List -->
                            <xsl:when test="local-name(.) eq 'list' and @type eq 'bullet'">
                                
                                <xsl:variable name="list-style" select="@rend"/>
                                
                                <xsl:for-each select="*:item">
                                    
                                    <!-- New line before list item -->
                                    <xsl:value-of select="markdown:new-line(position())"/>
                                    
                                    <!-- Leading chars to markdown list -->
                                    <xsl:choose>
                                        
                                        <!-- Numbered list -->
                                        <xsl:when test="$list-style eq 'numbers'">
                                            <xsl:value-of select="concat(position(), '. ')"/>
                                        </xsl:when>
                                        
                                        <!-- Letters list -->
                                        <xsl:when test="$list-style eq 'letters'">
                                            <xsl:value-of select="concat(ops:position-to-letter(position()), '. ')"/>
                                        </xsl:when>
                                        
                                        <!-- Bullet list -->
                                        <xsl:otherwise>
                                            <xsl:value-of select="'* '"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                    
                                    <!-- Parse each content node -->
                                    <xsl:choose>
                                        <!-- Shortcut for single p element -->
                                        <xsl:when test="count(child::*) eq 1 and child::tei:p">
                                            <xsl:for-each select="child::tei:p/node()">
                                                <xsl:call-template name="markdown:string">
                                                    <xsl:with-param name="node" select="."/>
                                                    <xsl:with-param name="markup" select="$markup"/>
                                                </xsl:call-template>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <!-- Otherwise markdown all content -->
                                        <xsl:otherwise>
                                            <xsl:for-each select="node()">
                                                <xsl:call-template name="markdown:string">
                                                    <xsl:with-param name="node" select="."/>
                                                    <xsl:with-param name="markup" select="$markup"/>
                                                </xsl:call-template>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:for-each>
                                
                            </xsl:when>
                            
                            <!-- Heading -->
                            <xsl:when test="local-name(.) eq 'head' and @type = ('section', 'nonStructuralBreak') and not(@*[not(local-name(.) = ('type', 'tid'))]) and not(*)">
                                
                                <!-- New line before heading -->
                                <xsl:value-of select="markdown:new-line(position())"/>
                                
                                <!-- Hash specifies a header -->
                                <xsl:value-of select="'# '"/>
                                
                                <!-- Output value -->
                                <xsl:value-of select="normalize-space(data())"/>
                                
                            </xsl:when>
                            
                            <!-- Element creating a new line -->
                            <xsl:when test="local-name(.) eq $newline-element and not(@*[not(local-name(.) eq 'tid')])">
                                
                                <!-- New line before paragraph -->
                                <xsl:value-of select="markdown:new-line(position())"/>
                                
                                <!-- Parse each content node -->
                                <xsl:for-each select="node()">
                                    <xsl:call-template name="markdown:string">
                                        <xsl:with-param name="node" select="."/>
                                        <xsl:with-param name="markup" select="$markup"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                
                            </xsl:when>
                            
                            <!-- Parse the content -->
                            <xsl:otherwise>
                                
                                <xsl:call-template name="markdown:string">
                                    <xsl:with-param name="node" select="."/>
                                    <xsl:with-param name="markup" select="$markup"/>
                                </xsl:call-template>
                                
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
                
            </xsl:for-each>
            
            <!-- Output notes at the end -->
            <xsl:for-each select="//tei:note[@place eq 'end']">
                
                <!-- Force new line -->
                <xsl:value-of select="markdown:new-line(2)"/>
                
                <xsl:value-of select="concat('n.', position(), ' ')"/>
                
                <xsl:for-each select="node()">
                    <xsl:call-template name="markdown:string">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
                
            </xsl:for-each>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Markdown -> XML(TEI) -->
    <xsl:template match="m:markdown">
    
        <!-- The source node -->
        <xsl:variable name="source" select="."/>
        
        <!-- The element to apply for a new-line -->
        <xsl:variable name="newline-element" select="($source/@newline-element, 'p')[1]" as="xs:string"/>
        <!-- The target namespace for markup -->
        <xsl:variable name="namespace" select="($source/@target-namespace, 'http://www.tei-c.org/ns/1.0')[1]" as="xs:string"/>
        <!-- The content tokenized into lines -->
        <xsl:variable name="lines" select="tokenize($source/node(), '\n')" as="xs:string*"/>
        
        <!-- Parse lines to elements -->
        <xsl:variable name="elements">
            
            <!-- Need a root element so we can evaluate siblings -->
            <elements xmlns="http://read.84000.co/ns/1.0">
                
                <!-- Exclude empty lines and notes -->
                <xsl:for-each select="$lines[matches(., '\w+')][not(matches(., $endnote-regex))]">
                    
                    <xsl:variable name="line" select="."/>
                    <xsl:variable name="line-number" select="position()"/>
                    
                    <xsl:choose>
                        
                        <!-- This line defines an element -->
                        <xsl:when test="matches($line, concat('^\s*', $element-regex, '\s*$'), 'i')">
                            <xsl:call-template name="markdown:element">
                                <xsl:with-param name="md-string" select="replace($line, '\s+', ' ')"/>
                                <xsl:with-param name="namespace" select="$namespace"/>
                                <xsl:with-param name="lines" select="$lines"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                        <!-- Otherwise derive the element -->
                        <xsl:otherwise>
                            
                            <xsl:variable name="element-name">
                                <xsl:choose>
                                    
                                    <!-- Check known patterns -->
                                    
                                    <xsl:when test="matches($line, $heading-regex)">
                                        <xsl:value-of select="'head'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $bullet-item-regex)">
                                        <xsl:value-of select="'item'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $numbers-item-regex)">
                                        <xsl:value-of select="'item'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $letters-item-regex)">
                                        <xsl:value-of select="'item'"/>
                                    </xsl:when>
                                    
                                    <xsl:when test="matches($line, $endnote-regex)">
                                        <xsl:value-of select="'note'"/>
                                    </xsl:when>
                                    
                                    <!-- Default element -->
                                    <xsl:otherwise>
                                        <xsl:value-of select="$newline-element"/>
                                    </xsl:otherwise>
                                    
                                </xsl:choose>
                            </xsl:variable>
                            
                            <!-- Add a container element -->
                            <xsl:element name="{ $element-name }" namespace="{ $namespace }">
                                
                                <!-- Set item type -->
                                <xsl:if test="$element-name eq 'item'">
                                    <xsl:attribute name="line-group-type">
                                        <xsl:choose>
                                            
                                            <xsl:when test="matches($line, $bullet-item-regex)">
                                                <xsl:value-of select="'list-item-bullet'"/>
                                            </xsl:when>
                                            
                                            <xsl:when test="matches($line, $numbers-item-regex)">
                                                <xsl:value-of select="'list-item-number'"/>
                                            </xsl:when>
                                            
                                            <xsl:when test="matches($line, $letters-item-regex)">
                                                <xsl:value-of select="'list-item-letter'"/>
                                            </xsl:when>
                                            
                                        </xsl:choose>
                                    </xsl:attribute>
                                </xsl:if>
                                
                                <!-- Set head type -->
                                <xsl:if test="$element-name eq 'head'">
                                    <xsl:attribute name="type">
                                        
                                        <!-- 
                                            Remove option for multiple #
                                            Heading type determined by position in section
                                            
                                            <!-/- Evaluate the indent level -/->
                                            <xsl:variable name="leading-hashes" select="replace($line, '^\s*(#+)\s+(.*)', '$1')"/>
                                            
                                            <xsl:choose>
                                                <xsl:when test="string-length($leading-hashes) eq 1">
                                                    <xsl:value-of select="'section'"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="'nonStructuralBreak'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        -->
                                        
                                        <xsl:choose>
                                            <xsl:when test="$line-number eq 1">
                                                <xsl:value-of select="'section'"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'nonStructuralBreak'"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        
                                    </xsl:attribute>
                                    
                                </xsl:if>
                                
                                <!-- Get content -->
                                <xsl:variable name="content">
                                    <xsl:choose>
                                        
                                        <!-- Head -->
                                        <xsl:when test="matches($line, $heading-regex)">
                                            <xsl:value-of select="replace(., $heading-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Bullet list -->
                                        <xsl:when test="matches($line, $bullet-item-regex)">
                                            <xsl:value-of select="replace(., $bullet-item-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Number list -->
                                        <xsl:when test="matches($line, $numbers-item-regex)">
                                            <xsl:value-of select="replace(., $numbers-item-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Letter list -->
                                        <xsl:when test="matches($line, $letters-item-regex)">
                                            <xsl:value-of select="replace(., $letters-item-regex, '')"/>
                                        </xsl:when>
                                        
                                        <!-- Note -->
                                        <xsl:when test="matches($line, $endnote-regex)">
                                            <xsl:value-of select="replace(., $endnote-regex, '')"/>
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <!-- Parse content -->
                                <xsl:analyze-string select="replace(replace($content, '^\s+', ''), '\s+', ' ')" regex="{ $element-regex }">
                                    
                                    <xsl:matching-substring>
                                        <xsl:call-template name="markdown:element">
                                            <xsl:with-param name="md-string" select="."/>
                                            <xsl:with-param name="namespace" select="$namespace"/>
                                            <xsl:with-param name="lines" select="$lines"/>
                                            <xsl:with-param name="leading-space" select="if(matches(., '^\s+')) then ' ' else ''"/>
                                            <xsl:with-param name="trailing-space" select="if(matches(., '\s+$')) then ' ' else ''"/>
                                        </xsl:call-template>
                                    </xsl:matching-substring>
                                    
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                    
                                </xsl:analyze-string>
                                
                            </xsl:element>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </xsl:for-each>
            
            </elements>
        
        </xsl:variable>
        
        <!-- Make groups of similar items for lists -->
        <xsl:variable name="elements">
            <xsl:for-each select="$elements/m:elements/*">
                
                <xsl:variable name="element" select="."/>
                
                <!-- Make a copy of the element -->
                <!-- Add a group for list items -->
                <xsl:element name="{ node-name($element) }" namespace="{ namespace-uri($element) }">
                    
                    <!-- Copy attributes -->
                    <xsl:sequence select="$element/@*"/>
                    
                    <!-- Add an attribute grouping list items -->
                    <xsl:attribute name="line-group-id">
                        <xsl:choose>
                            
                            <!-- List types where it's not the first in the list -->
                            <xsl:when test="local-name($element) eq 'item' and preceding-sibling::*[1][@line-group-type eq $element/@line-group-type]">
                                <!-- 
                                    Find the first in this list
                                    - Closest sibling of this type that has a first sibling of not this type
                                    - Use the index of that as the group id
                                -->
                                <xsl:variable name="first-in-group" select="$element/preceding-sibling::*[@line-group-type eq $element/@line-group-type][preceding-sibling::*[1][not(@line-group-type eq $element/@line-group-type)]][1]"/>
                                <xsl:value-of select="ops:index-of-node($elements/m:elements/*, $first-in-group)"/>
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <xsl:value-of select="ops:index-of-node($elements/m:elements/*, $element)"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:attribute>
                    
                    <!-- Copy nodes -->
                    <xsl:sequence select="node()"/>
                    
                </xsl:element>
                
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Output tei -->
        <xsl:element name="div" namespace="{ $namespace }">
            
            <xsl:attribute name="type" select="'markup'"/>
            
            <xsl:for-each-group select="$elements/*" group-by="@line-group-id">
                <xsl:choose>
                    
                    <!-- Add a list for list items -->
                    <xsl:when test="local-name(.) eq 'item'">
                        <xsl:element name="list" namespace="{ $namespace }">
                            
                            <xsl:attribute name="type" select="'bullet'"/>
                            
                            <xsl:choose>
                                <xsl:when test="@line-group-type eq 'list-item-bullet'">
                                    <xsl:attribute name="rend" select="'dots'"/>
                                </xsl:when>
                                <xsl:when test="@line-group-type eq 'list-item-number'">
                                    <xsl:attribute name="rend" select="'numbers'"/>
                                </xsl:when>
                                <xsl:when test="@line-group-type eq 'list-item-letter'">
                                    <xsl:attribute name="rend" select="'letters'"/>
                                </xsl:when>
                            </xsl:choose>
                            
                            <!-- Add each item in the list -->
                            <xsl:for-each select="current-group()">
                                <xsl:choose>
                                    <!-- If item has direct child data then nest in a <p/> -->
                                    <xsl:when test="node()[. instance of text() and normalize-space(.)]">
                                        <xsl:element name="item" namespace="{ namespace-uri(.) }">
                                            <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                            <xsl:element name="p" namespace="{ $namespace }">
                                                <xsl:sequence select="node()"/>
                                            </xsl:element>
                                        </xsl:element>
                                    </xsl:when>
                                    <!-- Otherwise output item -->
                                    <xsl:otherwise>
                                        <xsl:element name="item" namespace="{ namespace-uri(.) }">
                                            <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                            <xsl:sequence select="node()"/>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            
                        </xsl:element>
                    </xsl:when>
                    
                    <!-- Add the element -->
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:element name="{ node-name(.) }" namespace="{ $namespace }">
                                <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                <xsl:sequence select="node()"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:otherwise>
                    
                </xsl:choose>  
            </xsl:for-each-group>
            
        </xsl:element>
           
    </xsl:template>
    
    <!-- XML(TEI) -> escaped string -->
    <xsl:template match="m:unescaped">
        
        <xsl:element name="escaped" namespace="http://read.84000.co/ns/1.0">
            
            <xsl:variable name="serialization-parameters" as="element(output:serialization-parameters)">
                <output:serialization-parameters>
                    <output:method value="xml"/>
                    <output:version value="1.1"/>
                    <output:indent value="no"/>
                    <output:omit-xml-declaration value="yes"/>
                </output:serialization-parameters>
            </xsl:variable>
            
            <!-- Loop through nodes to avoid whitespace from passing node() sequence, remove namespaces -->
            <xsl:for-each select="node()">
                <xsl:value-of select="replace(replace(serialize(., $serialization-parameters), '\s+', ' '), '\s*xmlns=&#34;[^\s|&gt;]*&#34;', '')"/>
            </xsl:for-each>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Escaped string -> XML(TEI) -->
    <xsl:template match="m:escaped">
        
        <xsl:variable name="source" select="."/>
        <xsl:variable name="namespace" select="($source/@target-namespace, 'http://www.tei-c.org/ns/1.0')[1]"/>
        
        <xsl:element name="div" namespace="{ $namespace }">
            
            <xsl:attribute name="type" select="'markup'"/>
            
            <xsl:sequence select="ops:change-element-ns-deep(parse-xml(concat('&lt;doc&gt;',text(),'&lt;/doc&gt;'))/doc/node(), $namespace, '')"/>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Create an element from a markdown string -->
    <xsl:template name="markdown:element">
        
        <xsl:param name="md-string" as="xs:string"/>
        <xsl:param name="lines" as="xs:string*"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="leading-space" as="xs:string?"/>
        <xsl:param name="trailing-space" as="xs:string?"/>
        
        <xsl:variable name="content" select="replace($md-string, $element-regex, '$1')"/>
        <xsl:variable name="element" select="replace($md-string, $element-regex, '$2')"/>
        <xsl:variable name="element-tokenized" select="tokenize($element, '\s+')"/>
        <xsl:variable name="element-one" select="$element-tokenized[1]"/>
        <xsl:variable name="element-one-tokenized" select="tokenize($element-one,':')"/>
        <xsl:variable name="element-rest" select="subsequence($element-tokenized, 2)"/>
        
        <!-- Derive the element from the first token -->
        <xsl:variable name="element-name" as="xs:string?">
            <xsl:choose>
                <xsl:when test="lower-case($element-one) = $known-langs ! lower-case(.)">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="count($element-one-tokenized) eq 1">
                    <xsl:value-of select="$element-one-tokenized"/>
                </xsl:when>
                <xsl:when test="$element-one-tokenized[1] eq 'lang'">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="$element-one-tokenized[1] = ('http', 'https')">
                    <xsl:value-of select="'ref'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- If it's a note derive the content from a different line -->
        <xsl:variable name="content">
            
            <xsl:choose>
                
                <xsl:when test="$element-name eq 'note'">
                    <xsl:value-of select="$lines[matches(., concat('^\s*n\.', $content, '\s+'))][1] ! replace(., $endnote-regex, '')"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:value-of select="$content"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- An element has been determined -->
            <xsl:when test="$element-name">
                
                <xsl:value-of select="$leading-space"/>
                
                <!-- Add the element -->
                <xsl:element name="{ $element-name }" namespace="{ $namespace }">
                    
                    <!-- Add attributes based on first token -->
                    <xsl:choose>
                        <xsl:when test="lower-case($element-one) = $known-langs ! lower-case(.)">
                            <xsl:attribute name="xml:lang" select="$known-langs[lower-case(.) eq lower-case($element-one)]"/>
                        </xsl:when>
                        <xsl:when test="$element-one-tokenized[1] eq 'lang'">
                            <xsl:call-template name="markdown:attributes">
                                <xsl:with-param name="md-string" select="$element-one"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$element-one-tokenized[1] = ('http', 'https')">
                            <xsl:attribute name="target" select="$element-one"/>
                        </xsl:when>
                        <xsl:when test="$element-name eq 'milestone'">
                            <xsl:attribute name="unit" select="'chunk'"/>
                        </xsl:when>
                        <xsl:when test="$element-name eq 'note'">
                            <xsl:attribute name="place" select="'end'"/>
                        </xsl:when>
                    </xsl:choose>
                    
                    <!-- Parse other attributes -->
                    <xsl:call-template name="markdown:attributes">
                        <xsl:with-param name="md-string" select="$element-rest"/>
                    </xsl:call-template>
                    
                    <!-- Add the content -->
                    <xsl:if test="normalize-space($content) gt ''">
                        
                        <!-- Parse content -->
                        <!-- Remove a bracket from nested brackets - single brackets get parsed e.g. [[data]](tag) (will be ignored) -> [data](tag) (will be marked up) -->
                        <xsl:variable name="content-unnested" select="replace(replace($content, '(?:\]{2})([^\]])', ']$1'), '(?:\[{2})([^\[])', '[$1')"/>
                        <xsl:analyze-string select="$content-unnested" regex="{ $element-regex }">
                            
                            <xsl:matching-substring>
                                <xsl:call-template name="markdown:element">
                                    <xsl:with-param name="md-string" select="."/>
                                    <xsl:with-param name="namespace" select="$namespace"/>
                                    <xsl:with-param name="lines" select="$lines"/>
                                    <xsl:with-param name="leading-space" select="if(matches(., '^\s+')) then ' ' else ''"/>
                                    <xsl:with-param name="trailing-space" select="if(matches(., '\s+$')) then ' ' else ''"/>
                                </xsl:call-template>
                            </xsl:matching-substring>
                            
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                            
                        </xsl:analyze-string>
                        
                    </xsl:if>
                    
                </xsl:element>
                
                <xsl:value-of select="$trailing-space"/>
                
            </xsl:when>
            
            <!-- No element determined -->
            <xsl:otherwise>
                <xsl:value-of select="$md-string"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Create attributes from markdown string -->
    <xsl:template name="markdown:attributes">
        
        <xsl:param name="md-string" as="xs:string*"/>
        
        <xsl:for-each select="$md-string">
            
            <xsl:variable name="attribute-tokenized" select="tokenize(., ':')"/>
            
            <xsl:if test="count($attribute-tokenized) eq 2">
                <xsl:choose>
                    <xsl:when test="$attribute-tokenized[1] eq 'lang'">
                        <xsl:attribute name="xml:lang" select="($known-langs[lower-case(.) eq lower-case($attribute-tokenized[2])], $attribute-tokenized[2])[1]"/>
                    </xsl:when>
                    <xsl:when test="$attribute-tokenized[1] eq 'id'">
                        <xsl:attribute name="xml:id" select="$attribute-tokenized[2]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{ $attribute-tokenized[1] }" select="$attribute-tokenized[2]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Create a markdown string from an element -->
    <xsl:template name="markdown:string">
        
        <xsl:param name="node" as="node()"/>
        <xsl:param name="markup" as="node()*"/>
        <xsl:param name="nesting" as="xs:integer" select="1"/>
        
        <xsl:choose>
            
            <!-- Text node -->
            <xsl:when test="$node instance of text()">
                <xsl:value-of select="replace($node/data(), '\s+', ' ')"/>
            </xsl:when>
            
            <!-- Element -->
            <xsl:when test="$node instance of element()">
                
                <!-- Add data in square brackets -->
                <xsl:if test="$node[data()]">
                    
                    <xsl:value-of select="ops:repeat-string('[', $nesting)"/>
                    
                    <xsl:choose>
                        
                        <!-- If it's an end note then just output the number e.g. 1) -->
                        <xsl:when test="$node[self::tei:note[@place eq 'end']]">
                            <xsl:value-of select="ops:index-of-node($markup//tei:note[@place eq 'end'], $node)"/>
                        </xsl:when>
                        
                        <!-- Otherwise parse the sub nodes -->
                        <xsl:otherwise>
                            <xsl:for-each select="$node/node()">
                                <xsl:call-template name="markdown:string">
                                    <xsl:with-param name="node" select="."/>
                                    <xsl:with-param name="markup" select="$markup"/>
                                    <xsl:with-param name="nesting" select="$nesting + 1"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <xsl:value-of select="ops:repeat-string(']', $nesting)"/>
                    
                </xsl:if>
                
                <!-- Attributes string -->
                <xsl:variable name="attributes-strings" as="xs:string*">
                    
                    <xsl:variable name="exclude-attributes" as="xs:string*">
                        <xsl:value-of select="'tid'"/>
                        <xsl:choose>
                            <xsl:when test="local-name($node) eq 'milestone'">
                                <xsl:value-of select="'unit'"/>
                            </xsl:when>
                            <xsl:when test="local-name($node) eq 'note' and $node[@place eq 'end']">
                                <xsl:value-of select="'index'"/>
                                <xsl:value-of select="'place'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="included-attributes" select="$node/@*[not(local-name(.) = $exclude-attributes)]"/>
                    
                    <xsl:choose>
                        <xsl:when test="count($included-attributes) eq 1 and local-name($node) eq 'foreign' and local-name($included-attributes[1]) eq 'lang' and $known-langs[lower-case(.) eq lower-case($included-attributes[1])]">
                            <xsl:value-of select="$known-langs[lower-case(.) eq lower-case($included-attributes[1])]"/>
                        </xsl:when>
                        <xsl:when test="count($included-attributes) eq 1 and local-name($node) eq 'ref' and local-name($included-attributes[1]) eq 'target' and matches($included-attributes[1]/string(), '^(http:|https:)')">
                            <xsl:value-of select="$included-attributes[1]/string()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$included-attributes ! concat(local-name(.), ':', string())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:variable>
                
                <!-- Element name -->
                <xsl:variable name="element-name" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="count($attributes-strings) eq 1 and ($known-langs[. eq $attributes-strings[1]] or matches($attributes-strings[1], '^(http:|https:)'))">
                            <!-- Short code: no element name required -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name($node)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Add element name and attributes in round brackets -->
                <xsl:value-of select="concat('(', string-join(($element-name, $attributes-strings), ' '), ')')"/>
                
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Markdown help guide -->
    <xsl:template name="markdown:guide">
        
        <xsl:param name="mode" as="xs:string?"/>
        
        <h3>
            <xsl:value-of select="'Using Markdown'"/>
        </h3>
        
        <div class="small">
            
            <xsl:if test="$mode eq 'full'">
                
                <p class="text-muted">
                    <xsl:value-of select="'Markdown is a standard for marking-up content using simplified syntax. '"/>
                    <xsl:value-of select="'Here we have extended the markdown standard to allow us to update TEI.'"/>
                    <br/>
                    <span class="text-danger uppercase">
                        <xsl:value-of select="'Note: this is NOT standard markdown.'"/>
                    </span>
                </p>
                
                <p>
                    <xsl:value-of select="'To add a new paragraph simply start a new line'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'A paragraph has no line breaks in it.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'A new paragraph comes after a line break.'"/>
                    <br/>
                </pre>
                
                <p>
                    <xsl:value-of select="'Specify a heading with a #'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'# Heading'"/>
                </pre>
                
                <p>
                    <xsl:value-of select="'Easily define lists'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'* First bullet list item'"/>
                    <br/>
                    <xsl:value-of select="'* Next bullet list item'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'1. First numbered list item'"/>
                    <br/>
                    <xsl:value-of select="'2. Next numbered list item'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'a. First lettered list item'"/>
                    <br/>
                    <xsl:value-of select="'b. Next lettered list item'"/>
                    <br/>
                </pre>
                
                <p>
                    <xsl:value-of select="'There are also some short-code tags'"/>
                </p>
                <pre class="wrap">
                    <xsl:value-of select="'(lb)'"/>
                    <br/>
                    <xsl:value-of select="'This paragraph will have an extra line of space above.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'(milestone)'"/>
                    <br/>
                    <xsl:value-of select="'This paragraph has a milestone in the margin.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'The term [Maitrāyanī](Sa-Ltn) is tagged as Sanskrit.'"/>
                    <br/>
                    <br/>
                    <xsl:value-of select="'This [84000.co](https://84000.co) will be rendered as a link.'"/>
                    <br/>
                </pre>
                
            </xsl:if>
            
            <p>
                <xsl:value-of select="'All TEI tags are supported by specifying the text in square brackets [text] followed by the tag definition in round brackets (tag).'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'You can specify a tag for any text inline [Karmaśataka](title). '"/>
                <br/>
                <br/>
                <xsl:value-of select="'Add the language attribute [Karmaśataka](title lang:Sa-Ltn).'"/>
                <br/>
                <br/>
                <xsl:value-of select="'And add further attributes [Karmaśataka](title lang:Sa-Ltn ref:entity-123).'"/>
                <br/>
            </pre>
            
            <pre class="wrap">
                <xsl:value-of select="'You may encounter complex nesting of elements, like [[[The Teaching of [[[Vimalakīrti]]](term ref:entity-123)]](http://read.84000.co/translation/toh176.html)](title lang:en) (Toh 176). '"/>
                <xsl:value-of select="'If in doubt leave brackets alone and ask a TEI editor to help. '"/>
            </pre>
            
            <pre class="wrap">
                <xsl:value-of select="'You can add a notes using the syntax [1](note) and another [2](note).'"/>
                <br/>
                <br/>
                <xsl:value-of select="'n.1 The content of the 1st note is after the passage.'"/>
                <br/>
                <xsl:value-of select="'n.2 And the content for the 2nd is on a new line.'"/>
                <br/>
            </pre>
            
        </div>
    </xsl:template>
    
</xsl:stylesheet>