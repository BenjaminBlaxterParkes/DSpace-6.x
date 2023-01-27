<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Main structure of the page, determines where
    header, footer, body, navigation are structurally rendered.
    Rendering of the header, footer, trail and alerts

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:confman="org.dspace.core.ConfigurationManager"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <!--
        Requested Page URI. Some functions may alter behavior of processing depending if URI matches a pattern.
        Specifically, adding a static page will need to override the DRI, to directly add content.
    -->
    <xsl:variable name="request-uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>
    <xsl:variable name="doc-root" select="translate(/dri:document/dri:meta/dri:pageMeta/dri:trail[@target][last()]/@target, '/', '')" />

    <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">

        <xsl:choose>
            <xsl:when test="not($isModal)">


            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
            </xsl:text>
            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7]&gt; &lt;html class=&quot;no-js lt-ie9 lt-ie8 lt-ie7&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 7]&gt;    &lt;html class=&quot;no-js lt-ie9 lt-ie8&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if IE 8]&gt;    &lt;html class=&quot;no-js lt-ie9&quot; lang=&quot;en&quot;&gt; &lt;![endif]--&gt;
            &lt;!--[if gt IE 8]&gt;&lt;!--&gt; &lt;html class=&quot;no-js&quot; lang=&quot;en&quot;&gt; &lt;!--&lt;![endif]--&gt;
            </xsl:text>

                <!-- First of all, build the HTML head element -->

                <xsl:call-template name="buildHead"/>

                <!-- Then proceed to the body -->
                <body>
                    <!-- Prompt IE 6 users to install Chrome Frame. Remove this if you support IE 6.
                   chromium.org/developers/how-tos/chrome-frame-getting-started -->
                    <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->
                    <xsl:choose>
                        <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                            <xsl:apply-templates select="dri:body/*"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="buildHeader"/>
                            <xsl:call-template name="buildTrail"/>
                            <!--javascript-disabled warning, will be invisible if javascript is enabled-->
                            <div id="no-js-warning-wrapper" class="hidden">
                                <div id="no-js-warning">
                                    <div class="notice failure">
                                        <xsl:text>JavaScript is disabled for your browser. Some features of this site may not work without it.</xsl:text>
                                    </div>
                                </div>
                            </div>

                            <div id="main-container" class="container">

                                <div class="row row-offcanvas row-offcanvas-right">
                                    <div class="horizontal-slider clearfix">
                                        <div class="col-xs-12 col-sm-12 col-md-9 main-content">

                                            <!-- Add searchbar to body of HTML pages -->
                                            <!-- * code lifted from sidebar/navigation.xsl  -->
                                            <div class="body-search" alt="seach for exam papers using either the course name or course code. if neither is known you can also search for keywords">
                                                <form id="ds-search-form" class="" method="post">
                                                    <xsl:attribute name="action">
                                                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                                                    </xsl:attribute>
                                                    <fieldset id="main-search">
                                                        <div class="input-group">
                                                            <input id="body-input" class="ds-text-field form-control" type="text" placeholder="Course Title / Course Code" >
                                                                <xsl:attribute name="name">
                                                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                                                                </xsl:attribute>
                                                            </input>
                                                            <span class="input-group-btn">
                                                                <button id="search-button" class="ds-button-field btn btn-primary" title="Submit search">
                                                                    <span>Search</span>
                                                                    <xsl:attribute name="onclick">
                                                                                <xsl:text>
                                                                                    var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                                                                    if (radio != undefined &amp;&amp; radio.checked)
                                                                                    {
                                                                                    var form = document.getElementById(&quot;ds-search-form&quot;);
                                                                                    form.action=
                                                                                </xsl:text>
                                                                        <xsl:text>&quot;</xsl:text>
                                                                        <xsl:value-of
                                                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                                                        <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                                                        <xsl:value-of
                                                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                                                                        <xsl:text>&quot; ; </xsl:text>
                                                                                <xsl:text>
                                                                                    }
                                                                                </xsl:text>
                                                                    </xsl:attribute>
                                                                </button>
                                                            </span>
                                                        </div>
                                                    </fieldset>
                                                </form>

                                                <!-- Reset search button added, clears seach filters and returns to default discovery page -->
                                                <xsl:variable name="clean-search" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                                <a id="search-reset" href="{$clean-search}/discover" alt="clear all seach filters" title="Clear search criteria">Reset Search</a>
                                            </div>

                                            <xsl:apply-templates select="*[not(self::dri:options)]"/>

                                            <div class="visible-xs visible-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>

                                            <!-- The footer div, dropping whatever extra information is needed on the page. It
                                            will most likely be something similar in structure to the currently given example. -->
                                            <div class="hidden-xs hidden-sm">
                                                <xsl:call-template name="buildFooter"/>
                                            </div>
                                        </div>


                                    <!-- CREATE STATIC SIDEBAR FOR STATIC PAGES -->
                                    <!-- Very ugly solution but works for these purposes -->
                                    <!-- * MUST BE UPDATED MANUALLY! * -->
                                    <xsl:variable name="root-url" select="/dri:document/dri:meta/dri:pageMeta/dri:trail[@target][last()]/@target"/>
                                    <xsl:choose>
                                        <!-- Conditional to determine if current URL is a static page and serve up static sidebar accordingly -->
                                        <xsl:when test="contains($request-uri, 'about') or contains($request-uri, 'help') or contains($request-uri, 'feedback')
                                                        or contains($request-uri, 'faq') or contains($request-uri, 'unavailable') or contains($request-uri, 'accessibility')">
                                            <div role="navigation" id="sidebar" class="col-xs-6 col-sm-3 sidebar-offcanvas">
                                                <div id="aspect_viewArtifacts_Navigation_list_discovery" class="list-group">
                                                    <a class="list-group-item active" alt="sidebar category">
                                                        <span class="h5 list-group-item-heading h5">
                                                            Browse by School
                                                        </span>
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Biological+Sciences%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Biological Sciences, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Biomedical+Sciences%2C+Deanery+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Biomedical Sciences, Deanery of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Business+School"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Business School
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Chemistry%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Chemistry, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Clinical+Sciences%2C+Deanery+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Clinical Sciences, Deanery of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Divinity%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Divinity, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Economics%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Economics, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Edinburgh+College+of+Art"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Edinburgh College of Art
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Education%2C+The+Moray+House+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Education, The Moray House School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Engineering%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Engineering, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Geosciences%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Geosciences, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Health+in+Social+Science%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Health in Social Science, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=History%2C+Classics+and+Archaeology%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        History, Classics and Archaeology, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Informatics%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Informatics, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Law%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Law, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Life+Long+Learning"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Life Long Learning
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Literatures%2C+Languages+%26+Cultures%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Literatures, Languages &amp; Cultures, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Mathematics%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Mathematics, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=MBChB+%28Papers+unavailable+at+request+of+College%29"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        MBChB (Papers unavailable at request of College)
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Molecular%2C+Genetic+and+Population+Health+Sciences%2C+Deanery+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Molecular, Genetic and Population Health Sciences, Deanery of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Philosophy%2C+Psychology+%26+Language+Sciences%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Philosophy, Psychology &amp; Language Sciences, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Physics+and+Astronomy%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Physics and Astronomy, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Social+%26+Political+Science%2C+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Social &amp; Political Science, School of
                                                    </a>
                                                    <a href="{$root-url}discover?filtertype=author&amp;filter_relational_operator=equals&amp;filter=Veterinary+Studies%2C+Royal+%28Dick%29+School+of"
                                                        class="list-group-item ds-option" alt="click to view all papers for this school" title="Click to view all papers from this school">
                                                        Veterinary Studies, Royal (Dick) School of
                                                    </a>
                                                </div>
                                            </div>
                                        </xsl:when>
                                        <!-- Serve up dynamic sidebar on all other pages -->
                                        <xsl:otherwise>
                                            <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar" role="navigation">
                                                <xsl:apply-templates select="dri:options"/>
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    </div>
                                </div>
                        </div>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Javascript at the bottom for fast page loading -->
                    <xsl:call-template name="addJavascript"/>
                </body>
                <xsl:text disable-output-escaping="yes">&lt;/html&gt;</xsl:text>

            </xsl:when>
            <xsl:otherwise>
                <!-- This is only a starting point. If you want to use this feature you need to implement
                JavaScript code and a XSLT template by yourself. Currently this is used for the DSpace Value Lookup -->
                <xsl:apply-templates select="dri:body" mode="modal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
    information is either user-provided bits of post-processing (as in the case of the JavaScript), or
    references to stylesheets pulled directly from the pageMeta element. -->
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>

            <!-- Use the .htaccess and remove these lines to avoid edge case issues.
             More info: h5bp.com/i/378 -->
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>

            <!-- Mobile viewport optimized: h5bp.com/viewport -->
            <meta name="viewport" content="width=device-width,initial-scale=1"/>

            <link rel="shortcut icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/favicon.ico</xsl:text>
                </xsl:attribute>
            </link>
            <link rel="apple-touch-icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:text>images/apple-touch-icon.png</xsl:text>
                </xsl:attribute>
            </link>

            <meta name="Generator">
                <xsl:attribute name="content">
                    <xsl:text>DSpace</xsl:text>
                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                    </xsl:if>
                </xsl:attribute>
            </meta>

            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS'][not(@qualifier)]">
                <meta name="ROBOTS">
                    <xsl:attribute name="content">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='ROBOTS']"/>
                    </xsl:attribute>
                </meta>
            </xsl:if>

            <!-- Add stylesheets -->

            <!--TODO figure out a way to include these in the concat & minify-->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$theme-path"/>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <link rel="stylesheet" href="{concat($theme-path, 'styles/main.css')}"/>

            <!-- Add syndication feeds -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>

            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='autolink']"/>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>

            <!-- The following javascript removes the default text of empty text areas when they are focused on or submitted -->
            <!-- There is also javascript to disable submitting a form when the 'enter' key is pressed. -->
            <script>
                //Clear default text of empty text areas on focus
                function tFocus(element)
                {
                if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                }
                //Clear default text of empty text areas on submit
                function tSubmit(form)
                {
                var defaultedElements = document.getElementsByTagName("textarea");
                for (var i=0; i != defaultedElements.length; i++){
                if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                function disableEnterKey(e)
                {
                var key;

                if(window.event)
                key = window.event.keyCode;     //Internet Explorer
                else
                key = e.which;     //Firefox and Netscape

                if(key == 13)  //if "Enter" pressed, then disable!
                return false;
                else
                return true;
                }
            </script>

            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 9]&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/html5shiv/dist/html5shiv.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;script src="</xsl:text><xsl:value-of select="concat($theme-path, 'vendor/respond/dest/respond.min.js')"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;/script&gt;
                &lt;![endif]--&gt;</xsl:text>

            <!-- Modernizr enables HTML5 elements & feature detects -->
            <script src="{concat($theme-path, 'vendor/modernizr/modernizr.js')}">&#160;</script>

            <!-- Add the title in -->
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'][last()]" />
            <title>
                <xsl:choose>
                    <xsl:when test="starts-with($request-uri, 'page/about')">
                        <i18n:text>xmlui.mirage2.page-structure.aboutThisRepository</i18n:text>
                    </xsl:when>

                    <!-- Add static page titles to tabs -->
                    <!-- * urls will need to be updated if static page urls are changed on live release -->
                    <xsl:when test="starts-with($request-uri, 'about')">
                        <i18n:text>About</i18n:text>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'help')">
                        <i18n:text>Help</i18n:text>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'feedback')">
                        <i18n:text>Feedback</i18n:text>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'faqs')">
                        <i18n:text>FAQs</i18n:text>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'exam-papers/unavailable')">
                        <i18n:text>Paper Unavailable</i18n:text>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'accessibility')">
                        <i18n:text>Accessibility</i18n:text>
                    </xsl:when>
                    <xsl:when test="starts-with($request-uri, 'exam-papers/archive')">
                        <i18n:text>Archive</i18n:text>
                    </xsl:when>
                    <xsl:when test="not($page_title)">
                        <xsl:text>  </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$page_title/node()" />
                    </xsl:otherwise>
                </xsl:choose>
            </title>

            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                              disable-output-escaping="yes"/>
            </xsl:if>

            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>

            <!-- Add MathJAX JS library to render scientific formulas-->
            <xsl:if test="confman:getProperty('webui.browse.render-scientific-formulas') = 'true'">
                <script type="text/x-mathjax-config">
                    MathJax.Hub.Config({
                      tex2jax: {
                        ignoreClass: "detail-field-data|detailtable|exception"
                      },
                      TeX: {
                        Macros: {
                          AA: '{\\mathring A}'
                        }
                      }
                    });
                </script>
                <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML">&#160;</script>
            </xsl:if>

        </head>
    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <!-- * Login has been moved to footer for this custom implementation -->
    <xsl:template name="buildHeader">

        <header class="exam-header">

            <div class="container" id="navbar-container" alt="naviagtion bar">

                <div class="navbar navbar-default navbar-static-top" role="navigation">
                    <div class="container">
                        <div class="navbar-header">

                            <button type="button" class="navbar-toggle" data-toggle="offcanvas">
                                <span class="sr-only">
                                    <i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text>
                                </span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                            </button>


                            <div class="navbar-header pull-right visible-xs hidden-sm hidden-md hidden-lg">
                            <ul class="nav nav-pills pull-left ">

                                <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
                                    <li id="ds-language-selection-xs" class="dropdown">
                                        <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                                        <button id="language-dropdown-toggle-xs" href="#" role="button" class="dropdown-toggle navbar-toggle navbar-link" data-toggle="dropdown">
                                            <b class="visible-xs glyphicon glyphicon-globe" aria-hidden="true"/>
                                        </button>
                                        <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle-xs" data-no-collapse="true">
                                            <xsl:for-each
                                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                                                <xsl:variable name="locale" select="."/>
                                                <li role="presentation">
                                                    <xsl:if test="$locale = $active-locale">
                                                        <xsl:attribute name="class">
                                                            <xsl:text>disabled</xsl:text>
                                                        </xsl:attribute>
                                                    </xsl:if>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="$current-uri"/>
                                                            <xsl:text>?locale-attribute=</xsl:text>
                                                            <xsl:value-of select="$locale"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of
                                                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                                                    </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </li>
                                </xsl:if>

                                <xsl:choose>
                                    <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                        <li class="dropdown">
                                            <button class="dropdown-toggle navbar-toggle navbar-link" id="user-dropdown-toggle-xs" href="#" role="button"  data-toggle="dropdown">
                                                <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                            </button>
                                            <ul class="dropdown-menu pull-right" role="menu"
                                                aria-labelledby="user-dropdown-toggle-xs" data-no-collapse="true">
                                                <li>
                                                    <a href="{/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='url']}">
                                                        <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a href="{/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                        <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                    </a>
                                                </li>
                                            </ul>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <form style="display: inline" action="{/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='loginURL']}" method="get">
                                                <button class="navbar-toggle navbar-link">
                                                    <b class="visible-xs glyphicon glyphicon-user" aria-hidden="true"/>
                                                </button>
                                            </form>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </ul>
                                </div>
                        </div>

                        <div class="navbar-header pull-right hidden-xs">
                            <ul class="nav navbar-nav pull-left">
                                <xsl:call-template name="languageSelection"/>
                            </ul>
                            <ul class="nav navbar-nav pull-left">
                                <xsl:choose>
                                    <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'
                                            and /dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier'][@qualifier='group'] = 'Administrator'">
                                        <li>
                                            <a href="{$context-path}/" alt="naviagtion link to home page" title="Link to home page">Home</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/about" alt="naviagtion link to about page" title="Link to about page">About</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/help" alt="naviagtion link to help page" title="Link to help page">Help</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/feedback" alt="naviagtion link to feedback page" title="Link to feedback page">Feedback</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/faqs" alt="naviagtion link to frequently asked questions page" title="Link to frequently asked questions page">FAQs</a>
                                        </li>
                                        <li class="dropdown">
                                            <a id="user-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown"  title="Profile dropdown menu">
                                                <span class="hidden-xs">
                                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='firstName']"/>
                                                    <xsl:text> </xsl:text>
                                                    <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='lastName']"/>
                                                    &#160;
                                                    <b class="caret"/>
                                                </span>
                                            </a>
                                            <ul class="dropdown-menu pull-right" role="menu"
                                                aria-labelledby="user-dropdown-toggle" data-no-collapse="true">
                                                <li id="auth-dropdown">
                                                    <a href="{/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='url']}" id="auth-dropdown" alt="View profile" title="View profile page">
                                                        <i18n:text>xmlui.EPerson.Navigation.profile</i18n:text>
                                                    </a>
                                                </li>
                                                <li>
                                                    <a id="auth-dropdown"  alt="Logout of profile" title="Logout of profile">
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='logoutURL']"/>
                                                        </xsl:attribute>
                                                            Logout
                                                    </a>
                                                </li>
                                                <!-- Supress logout button in navigation -->
                                                <!-- * has been moved to footer for admin use only -->
                                                <!--<li>
                                                    <a href="{/dri:document/dri:meta/dri:userMeta/
                                                                dri:metadata[@element='identifier' and @qualifier='logoutURL']}">
                                                        <i18n:text>xmlui.dri2xhtml.structural.logout</i18n:text>
                                                    </a>
                                                </li>-->
                                            </ul>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!-- Supress login button in navigation -->
                                        <!-- * has been moved to footer for admin use only -->
                                        <!--<li>
                                            <a href="{/dri:document/dri:meta/dri:userMeta/
                                                                dri:metadata[@element='identifier' and @qualifier='loginURL']}">
                                                <span class="hidden-xs">
                                                    <i18n:text>xmlui.dri2xhtml.structural.login</i18n:text>
                                                </span>
                                            </a>
                                        </li>-->

                                        <!-- Add static pages to navbar -->
                                        <!-- * urls will need to be updated if static urls are changed for live release -->
                                        <li>
                                            <a href="{$context-path}/" alt="naviagtion link to home page" title="Link to home page">Home</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/about" alt="naviagtion link to about page" title="Link to about page">About</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/help" alt="naviagtion link to help page" title="Link to help page">Help</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/feedback" alt="naviagtion link to feedback page" title="Link to feedback page">Feedback</a>
                                        </li>
                                        <li>
                                            <a href="{$context-path}/faqs" alt="naviagtion link to frequently asked questions page" title="Link to frequently asked questions page">FAQs</a>
                                        </li>

                                    </xsl:otherwise>
                                </xsl:choose>
                            </ul>

                            <button data-toggle="offcanvas" class="navbar-toggle visible-sm" type="button">
                                <span class="sr-only"><i18n:text>xmlui.mirage2.page-structure.toggleNavigation</i18n:text></span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                                <span class="icon-bar"></span>
                            </button>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Header container for UofE & Exam Papers banners -->
            <div class="container" id="header-container">
                <div id="container-header">
                    <div class="uofe-logo">
                        <a href="https://www.ed.ac.uk/" alt="image link to the univeristy of edinburgh's home page" title="Click image to link to the univeristy of edinburgh's home page">
                            <img src="{$theme-path}images/uni-logo-black.png" alt="University of Edinburgh Logo"></img>
                        </a>
                    </div>
                    <div class="exam-banner" href="{$context-path}/">
                        <a class="exam-banner-click" href="{$context-path}/" alt="image link to the univeristy of edinburgh's exam papers home page" title="Click image to link to exam papers home page">
                            <img src="{$theme-path}images/exampapersbanner.png" alt="University of Edinburgh Exam Papers Banner" href="{$context-path}/" ></img>
                            <h1>EXAM PAPERS ONLINE</h1>
                        </a>
                    </div>

                </div>
            </div>
        </header>

    </xsl:template>


    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildTrail">
        <div class="container" id="trail-container">
            <div class="trail-wrapper hidden-print">
                <div class="container">
                    <div class="row">
                        <!--TODO-->
                        <div class="col-xs-12">

                                <!-- REMOVED DYNAMIC BREADCRUMBS -->
                                <!--<xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) > 1">
                                    <div class="breadcrumb dropdown visible-xs">
                                        <a id="trail-dropdown-toggle" href="#" role="button" class="dropdown-toggle"
                                        data-toggle="dropdown">
                                            <xsl:variable name="last-node"
                                                        select="/dri:document/dri:meta/dri:pageMeta/dri:trail[last()]"/>
                                            <xsl:choose>
                                                <xsl:when test="$last-node/i18n:*">
                                                    <xsl:apply-templates select="$last-node/*"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="$last-node/text()"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:text>&#160;</xsl:text>
                                            <b class="caret"/>
                                        </a>
                                        <ul class="dropdown-menu" role="menu" aria-labelledby="trail-dropdown-toggle">
                                            <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"
                                                                mode="dropdown"/>
                                        </ul>
                                    </div>
                                    <ul class="breadcrumb hidden-xs">
                                        <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                                    </ul>
                                </xsl:when>-->

                                <!-- OVERRIDE BREADCRUMBS -->
                                <!-- Add static page breadcrumbs based on url conditional -->
                                <!-- * lengthy and ugly but avoids end-users being able to access default dspace discovery & collection pages
                                        (stops students seeing dspace admin interface etc -->

                            <ul  class="breadcrumb" id="breadcrumb-list" alt="breadcrumb trail for current page">
                                <li>
                                    <a href="http://www.ed.ac.uk" title="External link to the University of Edinburgh's home page" alt="breadcrumb link to university homapge">
                                        University Homepage
                                    </a>
                                </li>
                                <li>
                                    <a href="http://www.ed.ac.uk/schools-departments" title="External link to the University of Edinburgh's Schools and Departments page" alt="breadcrumb link to university schools and departments">
                                        Schools &amp; Departments
                                    </a>
                                </li>
                                <li>
                                    <a href="http://www.ed.ac.uk/schools-departments/information-services" title="External link to the University of Edinburgh's Information Services page" alt="breadcrumb link to university information services">
                                        Information Services
                                    </a>
                                </li>
                                <li>
                                    <a href="http://www.ed.ac.uk/schools-departments/information-services/library-museum-gallery" title="External link to the University of Edinburgh's Library Essentials page" alt="breadcrumb link to university library information page">
                                        Library Essentials
                                    </a>
                                </li>
                                <xsl:choose>
                                    <xsl:when test="$request-uri = $doc-root">
                                        <li>
                                            Exam Papers
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <a href="/" alt="breadcrumb link to exam papers homapge" title="Breadcrumb link to exam papers home page">
                                                Exam Papers
                                            </a>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="starts-with($request-uri, 'about')">
                                        <li alt="breadcrumb for current page" title="Current page: About">
                                            <xsl:text>About</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'help')">
                                        <li alt="breadcrumb for current page" title="Current page: Help">
                                            <xsl:text>Help</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'feedback')">
                                        <li alt="breadcrumb for current page" title="Current page: Feedback">
                                            <xsl:text>Feedback</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'faqs')">
                                        <li alt="breadcrumb for current page" title="Current page: FAQs">
                                            <xsl:text>FAQs</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'exam-papers/unavailable')">
                                        <li alt="breadcrumb for current page" title="Current page: Paper Unavailable">
                                            <xsl:text>Paper Unavailable</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'accessibility')">
                                        <li alt="breadcrumb for current page" title="Current page: Accessibility">
                                            <xsl:text>Accessibility</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'handle')">
                                        <li alt="breadcrumb for current page" title="Current page: View Paper">
                                            <xsl:text>View Paper</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'discover')">
                                        <li alt="breadcrumb for current page" title="Current page: Search">
                                            <xsl:text>Search</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'password-login')">
                                        <li alt="breadcrumb for current page" title="Current page: Password Login">
                                            <xsl:text>Password Login</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'forgot')">
                                        <li alt="breadcrumb for current page" title="Current page: Forgotten Password">
                                            <xsl:text>Forgotten Password</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="starts-with($request-uri, 'profile')">
                                        <li alt="breadcrumb for current page" title="Current page: Edit Profile">
                                            <xsl:text>Edit Profile</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="contains($request-uri, 'admin') or contains($request-uri, 'statistics')">
                                        <li alt="breadcrumb for current page" title="Current page: Administation">
                                            <xsl:text>Administation</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="contains($request-uri, 'submi')">
                                        <li alt="breadcrumb for current page" title="Current page: Administation">
                                            <xsl:text>Submissions</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:when test="contains($request-uri, 'archive')">
                                        <li alt="breadcrumb for current page" title="Current page: Administation">
                                            <xsl:text>Archive</xsl:text>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>


    </xsl:template>

    <!--The Trail-->
    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail-->
        <li>
            <xsl:if test="position()=1">
                <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
            </xsl:if>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <xsl:template match="dri:trail" mode="dropdown">
        <!--put an arrow between the parts of the trail-->
        <li role="presentation">
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a role="menuitem">
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:if test="position()=1">
                            <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                        </xsl:if>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:when test="position() > 1 and position() = last()">
                    <xsl:attribute name="class">disabled</xsl:attribute>
                    <a role="menuitem" href="#">
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">active</xsl:attribute>
                    <xsl:if test="position()=1">
                        <i class="glyphicon glyphicon-home" aria-hidden="true"/>&#160;
                    </xsl:if>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <!--The License-->
    <xsl:template name="cc-license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']" />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']" />
        <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
            <div about="{$handleUri}" class="row">
            <div class="col-sm-3 col-xs-12">
                <a rel="license"
                   href="{$ccLicenseUri}"
                   alt="{$ccLicenseName}"
                   title="{$ccLicenseName}"
                        >
                    <xsl:call-template name="cc-logo">
                        <xsl:with-param name="ccLicenseName" select="$ccLicenseName"/>
                        <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri"/>
                    </xsl:call-template>
                </a>
            </div> <div class="col-sm-8">
                <span>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                    <xsl:value-of select="$ccLicenseName"/>
                </span>
            </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="cc-logo">
        <xsl:param name="ccLicenseName"/>
        <xsl:param name="ccLicenseUri"/>
        <xsl:variable name="ccLogo">
             <xsl:choose>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/licenses/by/')">
                       <xsl:value-of select="'cc-by.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/licenses/by-sa/')">
                       <xsl:value-of select="'cc-by-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/licenses/by-nd/')">
                       <xsl:value-of select="'cc-by-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/licenses/by-nc/')">
                       <xsl:value-of select="'cc-by-nc.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/licenses/by-nc-sa/')">
                       <xsl:value-of select="'cc-by-nc-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/licenses/by-nc-nd/')">
                       <xsl:value-of select="'cc-by-nc-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/publicdomain/zero/')">
                       <xsl:value-of select="'cc-zero.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri, 'http://creativecommons.org/publicdomain/mark/')">
                       <xsl:value-of select="'cc-mark.png'" />
                  </xsl:when>
                  <xsl:otherwise>
                       <xsl:value-of select="'cc-generic.png'" />
                  </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
        <img class="img-responsive">
             <xsl:attribute name="src">
                <xsl:value-of select="concat($theme-path,'/images/creativecommons/', $ccLogo)"/>
             </xsl:attribute>
             <xsl:attribute name="alt">
                 <xsl:value-of select="$ccLicenseName"/>
             </xsl:attribute>
        </img>
    </xsl:template>

    <!-- Like the header, the footer contains various miscellaneous text, links, and image placeholders -->
    <xsl:template name="buildFooter">
        <footer alt="site footer">
                <div class="row">
                    <hr/>
                    <div class="col-xs-7 col-sm-8">

                        <!-- Supress links to DSpace and DuraSpace sites -->
                        <!--<div>
                            <a href="http://www.dspace.org/" target="_blank">DSpace software</a> copyright&#160;&#169;&#160;2002-2016&#160; <a href="http://www.duraspace.org/" target="_blank">DuraSpace</a>
                        </div>-->
                        <div class="hidden-print">
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/contact</xsl:text>

                                    <!-- Add static page URK paths -->
                                    <!-- * may require changes before deployment * -->
                                    <xsl:text>/about</xsl:text>
                                    <xsl:text>/help</xsl:text>
                                    <xsl:text>/feedback</xsl:text>
                                    <xsl:text>/faqs</xsl:text>
                                    <xsl:text>/exam-papers/unavailable</xsl:text>
                                    <xsl:text>/accessibility</xsl:text>
                                    <xsl:text>/exam-papers/archive</xsl:text>
                                </xsl:attribute>

                                <!--<i18n:text>xmlui.dri2xhtml.structural.contact-link</i18n:text>-->
                            </a>
                            <!--<xsl:text> | </xsl:text>-->
                            <a>
                                <!-- Supress default feedback page link -->
                                <!--<xsl:attribute name="href">
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                                    <xsl:text>/feedback</xsl:text>
                                </xsl:attribute>
                                <i18n:text>xmlui.dri2xhtml.structural.feedback-link</i18n:text>-->
                            </a>
                            <div class="footer-disclaimer">
                                <div class="footer-policies" alt="site privacy and accessibility policy links">
                                    <p id="footer-left">
                                        <a class="footer-policies-a" href="http://www.ed.ac.uk/about/website/privacy" title="Click to view the Universities Privacy and Cookies Policy" target="_blank"
                                            alt="link to univeristy privacy and coookie policies">
                                            Privacy &amp; Cookies
                                        </a>
                                        <a class="footer-policies-a" href="https://exampapers.ed.ac.uk/takedown"
                                            title="Click to view the Universities Takedown Policy" alt="link to univeristy take down policy">
                                            Takedown Policy
                                        </a>
                                        <a class="footer-policies-a" href="{$context-path}/accessibility" title="Click to view the exam papers Website Accessibility Statement"
                                            alt="link to univeristy accessibilty policy">
                                            Accessibility
                                        </a>
                                    </p>
                                    <p id="footer-right">
                                        <!-- Authentication login/logout footer links -->
                                        <xsl:choose>
                                            <xsl:when test="/dri:document/dri:meta/dri:userMeta/@authenticated = 'yes'">
                                                <a alt="admin logout link" title="Log out of admin profile">
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="/dri:document/dri:meta/dri:userMeta/dri:metadata[@element='identifier' and @qualifier='logoutURL']"/>
                                                    </xsl:attribute>
                                                    Admin Logout <i aria-hidden="true" class="glyphicon glyphicon glyphicon-log-in" id="admin-login-icon"></i>
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <a href="/login" alt="admin login link" title="Log into admin profile">
                                                    Admin Login <i aria-hidden="true" class="glyphicon glyphicon glyphicon-log-in" id="admin-login-icon"></i>
                                                </a>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </p>
                                </div>
                                <div id="footer-left" class="footer-disclaimer" alt="site disclaimer">
                                    <p>
                                        The University of Edinburgh is a charitable body, registered in Scotland, with registration number SC005336, VAT Registration Number GB 592 9507 00,
                                        and is acknowledged by the UK authorities as a <a href="https://www.gov.uk/recognised-uk-degrees" title="External link to UK Government Recognised Degrees site" target="_blank"
                                        alt="link to UK government recognised university charitable body check site"> “Recognised Body”</a> which has been granted degree awarding powers.
                                    </p>
                                    <p></p>
                                    <p>
                                        Unless explicitly stated otherwise, all material is copyright © 2019 <a href="http://www.ed.ac.uk" title="External link to University of Edinburgh home page"
                                        alt="link to univeristy of edinburgh homepage
                                        .
                                        " target="_blank">University of Edinburgh</a>.
                                    </p>
                                </div>
                                <!-- Commented out for now but can be added back in if required -->
                                <!--<div class="is-logo">
                                    <a href="http://www.is.ed.ac.uk" target="_blank" class="islogo" title="University of Edinburgh Information Services Home">
                                        <img src="{$theme-path}images/is_logo.jpg" href="http://www.is.ed.ac.uk"/>
                                    </a>
                                </div>-->
                            </div>
                        </div>
                    </div>

                    <!-- REMOVED THEME LOGO -->
                    <!--<div class="col-xs-5 col-sm-4 hidden-print">
                        <div class="pull-right">
                            <span class="theme-by">Theme by&#160;</span>
                            <br/>
                            <a title="Atmire NV" target="_blank" href="http://atmire.com">
                                <img alt="Atmire NV" src="{concat($theme-path, 'images/atmire-logo-small.svg')}"/>
                            </a>
                        </div>

                    </div>-->

                </div>
                <!--Invisible link to HTML sitemap (for search engines) -->
                <a class="hidden">
                    <xsl:attribute name="href">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/htmlmap</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </a>
            <p>&#160;</p>
        </footer>
    </xsl:template>


    <!--
            The meta, body, options elements; the three top-level elements in the schema
    -->



    <!--
        The template to handle the dri:body element. It simply creates the ds-body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->
    <xsl:template match="dri:body">
        <div>
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div class="alert alert-warning">
                    <button type="button" class="close" data-dismiss="alert">&#215;</button>
                        <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                </div>
            </xsl:if>

            <!-- Check for the custom pages -->
            <!-- STATIC PAGES ADDED BELOW -->
            <!-- * may require some changes before deployment if urls are updated * -->
            <xsl:choose>
            <!-- Conditionals to determin URL path and serve up corrisponding static page -->

                <!-- ABOUT PAGE -->
                <xsl:when test="starts-with($request-uri, 'about')">
                    <div class="hero-unit">
                        <div class="content">
                            <p></p>
                            <h3 alt="page title">University of Edinburgh Exam Papers Online</h3>
                            <p alt="information about the universities exam papers site">
                                Exam Papers Online is a service provided by University of Edinburgh Library and University Collections for students and staff of The University of Edinburgh.
                            </p>
                            <p>
                                These pages will be updated periodically, as more papers become available. If you cannot find the paper you are looking for, please email
                                <a href="mailto:exam.papers@ed.ac.uk" title="Clink to email the exam papers team at the University of Edinburgh about a specific exam paper"
                                alt="link to exam papers email address">exam.papers@ed.ac.uk</a>, or try visiting again at a later date.
                            </p>
                            <p>
                                These pages are part of the collected Degree Examination Papers of the University of Edinburgh and are provided for use by its students as a study aid.
                                No other use is permitted.
                            </p>
                            <p>
                                Bound volumes of older sets - up to academic year 2004/2005 - have now been moved to the University Collections Facility and may be retrieved upon request.
                                Further information on accessing materials stored in the university are available from:
                                <a href="https://www.ed.ac.uk/information-services/library-museum-gallery/using-library/lib-locate/university-collections-facility"
                                target="_blank" title="External link to details about accessing the University Collections Facility materials" alt="link to the univeristy collections
                                facility website">University Collections Facility.
                                </a>
                            </p>
                            <br></br>
                        </div>
                    </div>
                </xsl:when>

                <!-- HELP PAGE -->
                <xsl:when test="starts-with($request-uri, 'help')">
                    <div class="hero-unit">
                        <div class="content">
                            <p></p>
                            <h3 alt="page title">Exam Papers Online Help</h3>
                            <p alt=" helpful information about using the universities exam papers site">
                                Please contact <a href="mailto:exam.papers@ed.ac.uk" title="Clink to email the exam papers team at the University of Edinburgh with any queries"
                                alt="link to exam papers email address">exam.papers@ed.ac.uk</a> with any queries concerning past exam papers or use the
                                <a href="./feedback/" title="Clink to view the University of Edinburgh's exam papers feedback form" alt="link to exam papers feedback form">Feedback form</a>
                                for comments or suggestions on the web pages.
                            </p>
                            <p>
                                All exam paper downloads on this site are in PDF format. Your browser should automatically display the PDF but if this is not possible,
                                there will be a link for downloading the PDF. If you do not have a PDF reader installed, <a href="http://get.adobe.com/uk/reader/"
                                title="Clink to download and install Adobe Acrobat PDF Reader" alt="link to adobe acrobat reader download page">download Adobe Acrobat Reader here</a>.
                            </p>
                            <p>
                                Users who wish to use assisted software are advised to use Internet Explorer.
                            </p>
                            <br></br>
                        </div>
                    </div>
                </xsl:when>

                <!-- FEEDBACK PAGE -->
                <xsl:when test="starts-with($request-uri, 'feedback')">
                    <div class="hero-unit">
                        <div class="content">
                            <p></p>
                            <h3 alt="page title">Exam Papers Online Feedback</h3>
                            <p alt="feedabck information">
                                Please contact us with your suggestions or questions at <a href="mailto:exam.papers@ed.ac.uk"
                                title="Clink to email the exam papers team at the University of Edinburgh with feedback and suggestions" alt="link to exam papers email address">exam.papers@ed.ac.uk</a>.
                            </p>
                            <h3 alt="section title">Privacy Statement </h3>
                            <p alt="privacy statement deatils">
                                Information about you: how we use it and with whom we share it
                            </p>
                            <p>
                                The information you provide in this form will be used only for purposes of your enquiry. We will not share your personal information with any third party or use it
                                for any other purpose. We are using information about you because it is necessary to contact you regarding your enquiry. By providing your personal data when submitting
                                an enquiry to us, consent for your personal data to be used in this way is implied.
                            </p>
                            <p>
                                For digitisation orders, your personal data is necessary for the performance of our contract to provide you with services that charge a fee.
                            </p>
                            <p>
                                We will hold the personal data you provided us for 6 years. We do not use profiling or automated decision-making processes.
                            </p>
                            <p>
                                If you have any questions, please contact: <a href="mailto:exam.papers@ed.ac.uk"
                                title="Clink to email the exam papers team at the University of Edinburgh with any questions" alt="link to exam papers email address">exam.papers@ed.ac.uk</a>
                            </p>
                            <p>
                                <a href="https://www.ed.ac.uk/records-management/notice" target="_blank" title="External link to the University of Edinburgh's privacy statement" alt="link to university privacy statement">
                                    University privacy statement
                                </a>
                            </p>
                            <br></br>
                        </div>
                    </div>
                </xsl:when>

                <!-- FAQ PAGE -->
                <xsl:when test="starts-with($request-uri, 'faqs')">
                    <div class="hero-unit">
                        <div class="content">
                            <div class="content byEditor about">
                                <h3 alt="page title">Exam Papers Online FAQs</h3>
                                <br></br>
                                <h4 alt="subsection title">...For Students</h4>
                                <h5 alt="frequently asked question"> I can't find my paper. Why?</h5>
                                <p alt="answer to frequently asked question">
                                    If you have tried all of the search tips and cannot find an entry for your paper it might be missing for one of the following reasons:
                                </p>
                                <ul alt="list of possible reasons for exclution of desired exam paper">
                                    <li>We have not been sent the paper by the department. While we do our best to collect all papers there will inevitably be gaps in our records.</li>
                                    <li>The department does not want it made available online. It is at the discretion of teaching staff as to whether a past exam paper is made available online. Some departments ask that none of the papers are placed on Exam Papers Online, others may only want the most recent papers to be available.</li>
                                    <li>We have recently received the paper. The paper may have recently been sent to us by a department and is awaiting processing by us. Please try again later.</li>
                                    <li>This is the first year the course has run. If this is the first year a course has run then there will not be any record of the course on Exam Papers Online, as no past examinations have been sat.</li>
                                    <li>The course hasn't run every year. Not all courses run every year so there may be gaps in our holdings. If there is no record for a paper it is because it wasn't sat that year.</li>
                                    <li>It is not the type of exam paper we hold. We only hold digitised copies of print degree examination papers. We do not hold computer-based, class or practical examinations.</li>
                                    <li>If you require more information as to why a paper isn't available online please email us.</li>
                                </ul>
                                <p></p>
                                <h5 alt="frequently asked question">Do you hold the answers to exam papers?</h5>
                                <p alt="answer to frequently asked question">
                                    No, we only hold the examination papers that have been sat in past years, not the solutions.
                                </p>
                                <h5 alt="frequently asked question">A section has been removed from my paper. Why?</h5>
                                <p alt="answer to frequently asked question">
                                    Some sections, such as multiple choice questions, may have been removed from papers by the department, or others may be have been removed due to copyright restrictions.
                                </p>
                                <h5 alt="frequently asked question">Where can I find pre-2004 exam papers?</h5>
                                <p id="faq-div-p" alt="answer to frequently asked question">
                                    We hold some digitised exam papers from 1995 to 2004 in our archive. Please email us if you require older papers. Original print copies of papers further back are held at the
                                    <a href="https://www.ed.ac.uk/information-services/library-museum-gallery/using-library/lib-locate/university-collections-facility" target="_blank"
                                    title="Clink to view details about accessing the University Collections Facility materials" alt="link to the univeristy's collection facility wbsite">University Collections Facility.
                                    </a>
                                </p>
                                <br></br>
                                <h4 alt="subsection title">...For Administrative &amp; Teaching Staff</h4>
                                <h5 alt="frequently asked question">How do I submit an exam paper to go online?</h5>
                                <p alt="answer to frequently asked question">
                                    Once the examination period is over papers can be emailed to us at any time, in Word or pdf format. We send out email reminders out 3 times a year,
                                    after each examination diet. If you wish to be included in the mailing list please contact us.
                                </p>
                                <h5 alt="frequently asked question">Can you tell me what exam papers are missing from my subject?</h5>
                                <p alt="answer to frequently asked question">
                                    Yes, please email us with the details of the subject you are responsible for and we can provide a list of the papers not currently held.
                                </p>
                                <h5>How can I have a paper taken down?</h5>
                                <p alt="answer to frequently asked question">
                                    Please email us with the details of the paper you wish removed.
                                </p>
                                <br></br>
                                <br></br>
                                <p>
                                    If you have any other questions please email us at <a href="mailto:exam.papers@ed.ac.uk"
                                    title="Clink to email the exam papers team at the University of Edinburgh about any other queries" alt="link to exam papers email address">
                                    exam.papers@ed.ac.uk</a>
                                </p>
                                <br></br>
                            </div>
                        </div>
                    </div>
                </xsl:when>

                <!-- PAPER UNAVAILABLE PAGE -->
                <xsl:when test="starts-with($request-uri, 'exam-papers/unavailable')">
                    <div class="hero-unit">
                        <div class="content">
                            <h3 alt="page title">This exam paper is unavailable at present</h3>
                            <p></p>
                            <h5 class="unavailable-list">This may be due to one of the following reasons:</h5>
                            <ol class="unavailable-list" alt="list of possible reasons the paper is not available">
                                <li>The paper has not yet been supplied by the School.</li>
                                <li>The School does not wish this paper to be published online.</li>
                                <li>The paper contains copyright material which means it cannot be published online.</li>
                            </ol>
                            <p></p>
                            <p>If you need for further information please contact
                                <a href="mailto:exam.papers@ed.ac.uk" alt="link to exam papers email address" title="Click to email the exam papers department for more information">
                                exam.papers@ed.ac.uk</a>
                            </p>
                            <br></br>
                        </div>
                    </div>
                </xsl:when>

                <!-- ACCESSIBILITY PAGE -->
                <xsl:when test="starts-with($request-uri, 'accessibility')">
                    <div class="hero-unit">
                        <div class="content">
                            <h1>Accessibility statement for the <a href="https://exampapers.ed.ac.uk/">University of Edinburgh, Exam Papers online</a></h1>
                            <p><strong>Website accessibility statement in line with Public Sector Body (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018</strong></p>
                            <p>This accessibility statement applies to the “<a href="https://exampapers.ed.ac.uk/">University of Edinburgh, Exam Papers online</a>” - <a href="https://exampapers.ed.ac.uk/">https://exampapers.ed.ac.uk/</a></p>
                            <p>This website is hosted by the Digital Library Department, Library and University Collections, University of Edinburgh. We want as many people as possible to be able to use this application. For example, that means you should be able to:</p>
                            <ul>
                                <li>Using your browser settings, change colours, contrast levels and fonts</li>
                                <li>zoom in up to 200% without the text spilling off the screen</li>
                                <li>navigate most of the website using just a keyboard</li>
                                <li>navigate most of the website using speech recognition software such as Dragon Naturally Speaking</li>
                                <li>listen to most of the website using a screen reader (including the most recent versions of Job Access with Speech (JAWS)</li>
                                <li>Experience no time limits when using the site</li>
                                <li>There is no flashing, scrolling or moving text</li>
                            </ul>
                            <p>We've also made the website text as simple as possible to understand.</p>

                            <h2>Customising the website</h2>
                            <p>AbilityNet has advice on making your device easier to use if you have a disability. This is an external site with suggestions to make your computer more accessible:</p>
                            <p><a href="https://mcmw.abilitynet.org.uk/">AbilityNet - My computer my way</a></p>
                            <p>With a few simple steps you can customise the appearance of our website using your browser settings to make it easier to read and navigate:</p>
                            <p><a href="https://www.ed.ac.uk/about/website/accessibility/customising-site">Additional information on how to customise our website appearance</a></p>
                            <p>If you are a member of University staff or a student, you can use the free SensusAccess accessible document conversion service:</p>
                            <p><a href="https://www.ed.ac.uk/student-disability-service/staff/supporting-students/accessible-technology">SenusAccess Information</a></p>

                            <h2>How accessible this website is</h2>
                            <p>We know some parts of this website are not fully accessible:</p>
                            <ul>
                                <li>Tabbing highlights sometimes obscure the content they are highlighting</li>
                                <li>It can be hard to tell where you have tabbed to using keyboard navigation</li>
                                <li>Data entry does not alert users to information entered incorrect format and error messages are in a small font with a poor colour contrast</li>
                                <li>Not all colour contrasts meet the recommended levels</li>
                                <li>Not all non-text content has appropriate alternative text</li>
                                <li>No 'skip to main content' button is present throughout the website</li>
                                <li>The website is not fully compatible with mobile accessibility functionality (Android, iOS)</li>
                                <li>Some PDF's are not fully accessible</li>
                                <li>Not all non-text items have alt text</li>
                                <li>Links are not correctly formatted hypertext links</li>
                                <li>Not all touch targets are a minimum of 9mm by 9mm </li>
                            </ul>

                            <h2>Feedback and contact information</h2>
                            <p>If you need information on this website in a different format, including accessible PDF, large print, audio recording or braille please contact:</p>
                            <p>Email: <a href="mailto:info@exam.papers@ed.ac.uk">info@exam.papers@ed.ac.uk</a></p>
                            <p>Phone: +44 (0)131 651 1827</p>
                            <p>British Sign Language (BSL) users can contact us via Contact Scotland BSL, the on-line BSL interpreting service</p>
                            <p><a href="http://contactscotland-bsl.org/">Contact Scotland BSL</a></p>
                            <p>We'll consider your request and get back to you in 5 working days.</p>

                            <h2>Reporting accessibility problems with this website</h2>
                            <p>We are always looking to improve the accessibility of this website. If you find any problems not listed on this page, or think we're not meeting accessibility requirements, please contact:</p>
                            <p>Email: <a href="mailto:info@exam.papers@ed.ac.uk">info@exam.papers@ed.ac.uk</a></p>
                            <p>Phone: +44 (0)131 651 1827</p>
                            <p>British Sign Language (BSL) users can contact us via Contact Scotland BSL, the on-line BSL interpreting service</p>
                            <p><a href="http://contactscotland-bsl.org/">Contact Scotland BSL</a></p>
                            <p>We are able to provide the exam papers in an alternative format for a reason related to a disability free of charge. You can also run the document through the SenusAccess service to get an accessible alternative version: <a href="https://www.ed.ac.uk/student-disability-service/staff/supporting-students/accessible-technology">https://www.ed.ac.uk/student-disability-service/staff/supporting-students/accessible-technology</a></p>
                            <p>We'll consider your request and get back to you in 5 working days.</p>

                            <h2>Enforcement procedure</h2>
                            <p>The Equality and Human Rights Commission (EHRC) is responsible for enforcing the Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018 (the 'accessibility regulations'). If you're not happy with how we respond to your complaint please contact the Equality Advisory and Support Service (EASS) directly:</p>
                            <p><a href="https://www.equalityadvisoryservice.com/">Contact details for the Equality Advisory and Support Service (EASS)</a></p>
                            <p>The government has produced information on how to report accessibility issues:</p>
                            <p><a href="https://www.gov.uk/reporting-accessibility-problem-public-sector-website">Reporting an accessibility problem on a public sector website</a></p>

                            <h2>Contacting us by phone using British Sign Language</h2>
                            <p>British Sign Language service Contact Scotland BSL runs a service for British Sign Language users and all of Scotland's public bodies using video relay. This enables sign language users to contact public bodies and vice versa. The service operates 24 hours a day, 7 days a week.</p>
                            <p><a href="https://contactscotland-bsl.org/">British Sign Language Scotland service details</a></p>

                            <h2>Technical information about this website's accessibility</h2>
                            <p>The University of Edinburgh is committed to making its websites and applications accessible, in accordance with the Public Sector Bodies (Websites and Mobile Applications) (No. 2) Accessibility Regulations 2018.</p>
                            <p>This website is partially compliant with the Web Content Accessibility Guidelines (WCAG) 2.1 AA standard, due to the non-compliances listed below.</p>
                            <p>The full guidelines are available at</p>
                            <p><a href="https://www.w3.org/TR/WCAG21/">Web Content Accessibility Guidelines (WCAG) 2.1 AA standard</a></p>

                            <h2>Non accessible content</h2>
                            <p>The content listed below is non-accessible for the following reasons.</p>
                            <p>Noncompliance with the accessibility regulations.</p>
                            <p>The following items to not comply with the WCAG 2.1 AA success criteria:</p>
                            <ul>
                                <li>Some non-text content does not have text alternatives.</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#non-text-content">1.1.1 - Non-text Content</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>There may not be sufficient colour contrast between font and background colours, there are issues where text size is very small</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#visual-audio-contrast-contrast">1.4.3 - Contrast (Minimum)</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>Not all the content reflows when the page is magnified above 200%</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#reflow">1.4.10 - Reflow</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>There is no 'skip to main content' option available throughout the website</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#bypass-blocks">2.4.1 - Bypass Blocks</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>There are missing heading levels</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#headings-and-labels">2.4.6. - Headings and Labels</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>There are missing labels present in the website so fail to describe the purpose of the input form</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#labels-or-instructions">3.3.2 - Labels or Instruction</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>Error suggestions or corrections are not always displayed</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#error-suggestion">3.3.3 - Error Suggestionn</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>Voice recognition software was unable to identify some parts of the page</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#parsing">4.1.1 - Parsing</a></u></li>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#name-role-value">4.1.2 - Name, Role, Value</a></u></li>
                                </ul>
                            </ul>
                            <ul>
                                <li>There are PDF's that are not currently accessible</li>
                                <ul>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#parsing">4.1.1 - Parsing</a></u></li>
                                    <li><u><a href="https://www.w3.org/TR/WCAG21/#name-role-value">4.1.2 - Name, Role, Value</a></u></li>
                                </ul>
                            </ul>
                            <p>Unless specified otherwise, a complete solution, or significant improvement, will be in place by November 2023. At this time we believe all items are within our control.</p>

                            <h2>Disproportionate burden</h2>
                            <p>We are not currently claiming that any accessibility problems would be a disproportionate burden to fix.</p>

                            <h2>Content that is not within the Scope of the Accessibility Regulations</h2>
                            <p>At this time, we do not believe that any content is outside the scope of the accessibility regulations.</p>

                            <h2>What we're doing to improve accessibility</h2>
                            <p>We will continue to address and make adequate improvements to the accessibility issues highlighted. Unless specified otherwise, a complete solution or significant improvement will be in place by November 2023.</p>
                            <p>While we are in the process of resolving these accessibility issues we will ensure reasonable adjustments are in place to make sure no user is disadvantaged. As changes are made, we will continue to review accessibility and retest the accessibility of this website.</p>
                            <p>We are planning to upgrade the site to the most recent release of the system architecture before the end of 2023 which includes improvements to the current accessibility requirements. During this upgrade improving the other accessibility issues highlighted will be a key component of the development process.</p>

                            <h2>Preparation of this accessibility statement</h2>
                            <p>This statement was first prepared on 30th September 2021. It was last reviewed on 30th November 2022.</p>
                            <p>This website was last tested on 30th September 2021. The test was carried out by The University Library and University Collections Digital Library Development team using the automated <a href="https://wave.webaim.org/">Wave WEBAIM</a> tool and <a href="https://littleforest.co.uk/">Little Forest</a> testing.</p>
                            <p>This website was last tested by the Library and University Collections Digital Library team, University of Edinburgh in July 2022 following on from previous automated testing of the system the previous year. This was primarily using the Google Chrome (100.0.4896.127), Mozilla Firefox (91.8.0esr), Internet Explorer (11.0) and Microsoft Edge (100.0.1185.39) browsers for comparative purposes.</p>
                            <p>Recent world-wide usage levels survey for different screen readers and browsers shows that Chrome, Mozilla Firefox and Microsoft Edge are increasing in popularity and Google Chrome is now the favoured browser for screen readers:</p>
                            <p><a href="https://webaim.org/projects/screenreadersurvey9/">WebAIM: Screen Reader User Survey</a></p>
                            <p>The aforementioned three browsers have been used in certain questions for reasons of breadth and variety.</p>
                            <p>We ran automated testing using <a href="https://wave.webaim.org/">Wave WEBAIM</a> and then manual testing that included:</p>
                            <ul>
                                <li>Spell check functionality;</li>
                                <li>Scaling using different resolutions and reflow;</li>
                                <li>Options to customise the interface (magnification, font, background colour, etc);</li>
                                <li>Keyboard navigation and keyboard traps;</li>
                                <li>Data validation;</li>
                                <li>Warning of links opening in new tab or window;</li>
                                <li>Information conveyed in the colour or sound only;</li>
                                <li>Flashing, moving or scrolling text;</li>
                                <li>Operability if JavaScript is disabled;</li>
                                <li>Use with screen reading software (for example JAWS);</li>
                                <li>Assistive software (TextHelp Read and Write, Windows Magnifier, ZoomText, Dragon Naturally Speaking, TalkBack and VoiceOver);</li>
                                <li>Tooltips and text alternatives for any non-text content;</li>
                                <li>Time limits;</li>
                                <li>Compatibility with mobile accessibility functionality (Android and iOS).</li>
                            </ul>

                            <h2>Change Log</h2>
                            <p>Since our first evaluation and statement which was based on automated testing we have been doing extensive manual testing including with a range of assistive technology to ensure we have a clear picture of the accessibility issues and how best to resolve them.</p>
                        </div>
                    </div>
                </xsl:when>

                <!-- ARCHIVE PAGE -->
                <xsl:when test="starts-with($request-uri, 'exam-papers/archive')">
                    <div class="hero-unit">
                        <div class="content">
                            <h3 alt="page title">The past papers for 1996/1997 to 2003/2004 have been archived</h3>
                            <p></p>
                            <p>
                                If you require access to any of the exam papers from the archive please contact
                                <a href="mailto:exam.papers@ed.ac.uk" alt="link to exam papers email address" title="Click to email the exam papers department for more information">
                                exam.papers@ed.ac.uk</a> with your enquiry.
                            </p>
                            <br></br>
                        </div>
                    </div>
                </xsl:when>
                <!-- Otherwise use default handling of body -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>

        </div>
    </xsl:template>


    <!-- Currently the dri:meta element is not parsed directly. Instead, parts of it are referenced from inside
        other elements (like reference). The blank template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>

    <!-- Meta's children: userMeta, pageMeta, objectMeta and repositoryMeta may or may not have templates of
        their own. This depends on the meta template implementation, which currently does not go this deep.
    <xsl:template match="dri:userMeta" />
    <xsl:template match="dri:pageMeta" />
    <xsl:template match="dri:objectMeta" />
    <xsl:template match="dri:repositoryMeta" />
    -->

    <xsl:template name="addJavascript">

        <script type="text/javascript"><xsl:text>
                         if(typeof window.publication === 'undefined'){
                            window.publication={};
                          };
                        window.publication.contextPath= '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/><xsl:text>';</xsl:text>
            <xsl:text>window.publication.themePath= '</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>
        <!--TODO concat & minify!-->

        <script>
            <xsl:text>if(!window.DSpace){window.DSpace={};}window.DSpace.context_path='</xsl:text><xsl:value-of select="$context-path"/><xsl:text>';window.DSpace.theme_path='</xsl:text><xsl:value-of select="$theme-path"/><xsl:text>';</xsl:text>
        </script>

        <script type="text/javascript">
            <xsl:text>
                <!--window.addEventListener("load", function(){-->
                    document.onload = function()
                    {
                        a = document.getElementById("mailto-link").getElementsByTagName("A");
                        console.log(a);
                        a.href = "mailto:exam.papers@ed.ac.uk";
                    }
                    <!--onclick = function(){/*do something*/};
                });-->
            </xsl:text>
        </script>

        <!--inject scripts.html containing all the theme specific javascript references
        that can be minified and concatinated in to a single file or separate and untouched
        depending on whether or not the developer maven profile was active-->
        <xsl:variable name="scriptURL">
            <xsl:text>cocoon://themes/</xsl:text>
            <!--we can't use $theme-path, because that contains the context path,
            and cocoon:// urls don't need the context path-->
            <xsl:value-of select="$pagemeta/dri:metadata[@element='theme'][@qualifier='path']"/>
            <xsl:text>scripts-dist.xml</xsl:text>
        </xsl:variable>
        <xsl:for-each select="document($scriptURL)/scripts/script">
            <script src="{$theme-path}{@src}">&#160;</script>
        </xsl:for-each>

        <!-- Add javascript specified in DRI -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script>
                <xsl:attribute name="src">
                    <xsl:value-of select="$theme-path"/>
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>

        <!-- add "shared" javascript from static, path is relative to webapp root-->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support
            out of our theme without modifying the administrative and submission sitemaps.
            This is obviously not ideal, but adding those scripts in those sitemaps is far
            from ideal as well-->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of select="$theme-path"/>
                            <xsl:text>js/choice-support.js</xsl:text>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script>
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>

        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
            <xsl:call-template name="choiceLookupPopUpSetup"/>
        </xsl:if>

        <script>
            document.onload = function()
            {
                var byValue = document.querySelectorAll('a[value="... View More"]');
                byValue.style.display="none";
            }
            window.onload = function()
            {
                var byValue = document.querySelectorAll('a[value="... View More"]');
                byValue.style.display="none";
            }
        </script>

        <xsl:call-template name="addJavascript-google-analytics" />
    </xsl:template>

    <xsl:template name="addJavascript-google-analytics">
        <!-- Add a google analytics script if the key is present -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script><xsl:text>
                (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

                ga('create', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/><xsl:text>');
                ga('send', 'pageview');
            </xsl:text></script>
        </xsl:if>
    </xsl:template>

    <!--The Language Selection
        Uses a page metadata curRequestURI which was introduced by in /xmlui-mirage2/src/main/webapp/themes/Mirage2/sitemap.xmap-->
    <xsl:template name="languageSelection">
        <xsl:variable name="curRequestURI">
            <xsl:value-of select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='curRequestURI'],/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'])"/>
        </xsl:variable>

        <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']) &gt; 1">
            <li id="ds-language-selection" class="dropdown">
                <xsl:variable name="active-locale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>
                <a id="language-dropdown-toggle" href="#" role="button" class="dropdown-toggle" data-toggle="dropdown">
                    <span class="hidden-xs">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$active-locale]"/>
                        <xsl:text>&#160;</xsl:text>
                        <b class="caret"/>
                    </span>
                </a>
                <ul class="dropdown-menu pull-right" role="menu" aria-labelledby="language-dropdown-toggle" data-no-collapse="true">
                    <xsl:for-each
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='supportedLocale']">
                        <xsl:variable name="locale" select="."/>
                        <li role="presentation">
                            <xsl:if test="$locale = $active-locale">
                                <xsl:attribute name="class">
                                    <xsl:text>disabled</xsl:text>
                                </xsl:attribute>
                            </xsl:if>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$curRequestURI"/>
                                    <xsl:call-template name="getLanguageURL"/>
                                    <xsl:value-of select="$locale"/>
                                </xsl:attribute>
                                <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='supportedLocale'][@qualifier=$locale]"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Builds the Query String part of the language URL. If there already is an existing query string
like: ?filtertype=subject&filter_relational_operator=equals&filter=keyword1 it appends the locale parameter with the ampersand (&) symbol -->
    <xsl:template name="getLanguageURL">
        <xsl:variable name="queryString" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='queryString']"/>
        <xsl:choose>
            <!-- There allready is a query string so append it and the language argument -->
            <xsl:when test="$queryString != ''">
                <xsl:text>?</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains($queryString, '&amp;locale-attribute')">
                        <xsl:value-of select="substring-before($queryString, '&amp;locale-attribute')"/>
                        <xsl:text>&amp;locale-attribute=</xsl:text>
                    </xsl:when>
                    <!-- the query string is only the locale-attribute so remove it to append the correct one -->
                    <xsl:when test="starts-with($queryString, 'locale-attribute')">
                        <xsl:text>locale-attribute=</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$queryString"/>
                        <xsl:text>&amp;locale-attribute=</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?locale-attribute=</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
