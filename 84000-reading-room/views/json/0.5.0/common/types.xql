xquery version "3.0";

(: Variations to json types for version 0.5.0 :)
module namespace json-types = "http://read.84000.co/json-types/0.5.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json = "http://www.json.org";

import module namespace helpers = "http://read.84000.co/json-helpers/0.5.0" at "helpers.xql";
import module namespace common = "http://read.84000.co/common" at "/db/apps/84000-reading-room/modules/common.xql";

declare variable $json-types:api-version := '0.5.0';

declare variable $json-types:relation-types := map {
    'classifiedAs':                 'classifiedAs',
    'sameAs':                       'sameAs',
    'hasMember':                    'hasMember',
    'isMemberOf':                   'isMemberOf',
    'isUnrelated':                  'isUnrelated',
    'closelyRelated':               'closelyRelated',
    'alternateName':                'alternateName',
    'alternateGender':              'alternateGender',
    'instanceOf':                   'instanceOf',
    'headName':                     'headName',
    'hiddenName':                   'hiddenName',
    'usesName':                     'usesName',
    'isNameOf':                     'isNameOf',
    'isInternalNameOf':             'isInternalNameOf',
    'nameEquivalent':               'nameEquivalent',
    'articleAbout':                 'articleAbout',
    'isCommentaryOf':               'isCommentaryOf',
    'hasCommonSourceText':          'hasCommonSourceText'
};

declare variable $json-types:creator-types := map {
    'contribution-translatorMain':  'englishTranslationTeam',
    'contribution-translatorEng':   'englishTranslator',
    'contribution-preface':         'englishPrefaceAuthor',
    'contribution-dharmaMaster':    'englishDharmaMaster',
    'contribution-advisor':         'englishAdvisor',
    'contribution-projectManager':  'englishProjectManager',
    'contribution-reviser':         'englishReviser',
    'contribution-TEImarkupEditor': 'englishMarkup',
    'contribution-finalReviewer':   'englishFinalReviewer',
    'contribution-copyEditor':      'englishCopyEditor',
    'contribution-proofreader':     'englishProofReader',
    'contribution-associateEditor': 'englishAssociateEditor',
    'contribution-projectEditor':   'englishProjectEditor',
    'contribution-externalReviewer':'englishExternalReviewer',
    'contribution-sponsor':         'englishTranslationSponsor',
    'attribution-author':           'tibetanAuthor',
    'attribution-authorContested':  'tibetanAuthorContested',
    'attribution-translatorTib':    'tibetanTranslator',
    'attribution-reviser':          'tibetanReviser'
};

declare variable $json-types:annotation-types := map {
    'contentGlossaryNotes':         'notes',
    'contentPreferredTranslation':  'preferredTranslation',
    'flagRequiresAttention':        'requiresAttention',
    'flagHidden':                   'hidden',
    'rendHidden':                   'hidden',
    'note':                         'textNote',
    'general':                      'textNote',
    'title':                        'textTitleNote',
    'title-internal':               'textTitleNoteInternal',
    'attribution':                  'textAttributionNote'
};

declare variable $json-types:classification-types := map {
    'eft-thing': map{ 
        'label': 'Thing',
        'description': 'Root classification for anything',
        'parentKey': '',
        'outputKey': 'thing'
    },
    'eft-person': map{ 
        'label': 'Person',
        'description': 'Any person historical, contemporary, mythical or otherwise',
        'parentKey': 'eft-thing',
        'outputKey': 'person'
    },
    'eft-place': map{ 
        'label': 'Place',
        'description': 'Any place historical, contemporary, mythical or otherwise',
        'parentKey': 'eft-thing',
        'outputKey': 'place'
    },
    'eft-text': map{ 
        'label': 'Text',
        'description': 'Any text',
        'parentKey': 'eft-thing',
        'outputKey': 'text'
    },
    'eft-term': map{ 
        'label': 'Term',
        'description': 'A significant term from any text',
        'parentKey': 'eft-thing',
        'outputKey': 'term'
    },
    'eft-collection': map{ 
        'label': 'Collection',
        'description': 'A collection of things without a common type',
        'parentKey': 'eft-thing',
        'outputKey': 'collection'
    },
    'textual-person': map{ 
        'label': 'Character',
        'description': 'A character from any text',
        'parentKey': 'eft-person',
        'outputKey': 'personCharacter'
    },
    'textual-location': map{ 
        'label': 'Location',
        'description': 'A location or setting from any text',
        'parentKey': 'eft-place',
        'outputKey': 'placeLocation'
    },
    'contributor-person': map{ 
        'label': 'Contributor',
        'description': 'A person contributing expertise to one or more translation projects',
        'parentKey': 'eft-person',
        'outputKey': 'personContributor'
    },
    'contributor-academic': map{ 
        'label': 'Academic',
        'description': 'A contributor with academic credentials',
        'parentKey': 'contributor-person',
        'outputKey': 'personContributorAcademic'
    },
    'contributor-practitioner': map{ 
        'label': 'Practitioner',
        'description': 'A contributor Dharma credentials',
        'parentKey': 'contributor-person',
        'outputKey': 'personContributorPractitioner'
    },
    'sponsor-person': map{ 
        'label': 'Sponsor',
        'description': 'A sponsor of the project',
        'parentKey': 'eft-person',
        'outputKey': 'personSponsor'
    },
    'sponsor-sutra': map{ 
        'label': 'Sutra sponsor',
        'description': 'A person sponsoring one or more specific translation projects',
        'parentKey': 'sponsor-person',
        'outputKey': 'personSponsorSutra'
    },
    'sponsor-matching-funds': map{ 
        'label': 'Matching funds sponsor',
        'description': 'An 84000 matching funds sponsor',
        'parentKey': 'sponsor-person',
        'outputKey': 'personSponsorMatchingfunds'
    },
    'sponsor-founding': map{ 
        'label': 'Founding sponsor',
        'description': 'An 84000 founding sponsor',
        'parentKey': 'sponsor-person',
        'outputKey': 'personSponsorFounding'
    },
    'organisation': map{ 
        'label': 'Organisation',
        'description': 'An officially registered organisation',
        'parentKey': 'eft-thing',
        'outputKey': 'organisation'
    },
    'translation-team': map{ 
        'label': 'Translation Team',
        'description': 'A team of contributors to one or more translation projects',
        'parentKey': 'organisation',
        'outputKey': 'organisationTranslationteam'
    },
    'organisation-type-1': map{ 
        'label': 'Academic Institution',
        'description': 'An academic institution',
        'parentKey': 'organisation',
        'outputKey': 'organisationAcademy'
    },
    'organisation-type-2': map{ 
        'label': 'Buddhist Center',
        'description': 'An buddhist center',
        'parentKey': 'organisation',
        'outputKey': 'organisationDharmacenter'
    },
    'place-region': map{ 
        'label': 'Region',
        'description': 'Arbitrary geographical region',
        'parentKey': 'eft-place',
        'outputKey': 'placeRegion'
    },
    'region-1': map{ 
        'label': 'North America',
        'description': 'North America',
        'parentKey': 'place-region',
        'outputKey': 'placeRegionNorthamerica'
    },
    'region-2': map{ 
        'label': 'Europe',
        'description': 'Europe',
        'parentKey': 'place-region',
        'outputKey': 'placeRegionEurope'
    },
    'region-3': map{ 
        'label': 'India / Nepal / Tibet',
        'description': 'Himalayan region of India, Nepal and Tibet',
        'parentKey': 'place-region',
        'outputKey': 'placeRegionHimalaya'
    },
    'region-4': map{ 
        'label': 'China / Japan',
        'description': 'Region of China and Japan',
        'parentKey': 'place-region',
        'outputKey': 'placeRegionChinajapan'
    },
    'region-5': map{ 
        'label': 'Other region',
        'description': 'Other region',
        'parentKey': 'place-region',
        'outputKey': 'placeRegionOther'
    },
    'demographic': map{ 
        'label': 'Demographic',
        'description': 'An arbitrary social grouping',
        'parentKey': 'eft-thing',
        'outputKey': 'demographic'
    },
    'demographic-geo': map{ 
        'label': 'Geographical Demographic',
        'description': 'A geo/social grouping',
        'parentKey': 'demographic',
        'outputKey': 'demographicGeo'
    },
    'demographic-geo-taiwan': map{ 
        'label': 'Taiwan',
        'description': 'Taiwanese resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoTiawan'
    },
    'demographic-geo-china': map{ 
        'label': 'China',
        'description': 'Chinese resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoChina'
    },
    'demographic-geo-taiwan-staying-in-china': map{ 
        'label': 'Taiwanese in China',
        'description': 'Taiwanese resident in China',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoTaiwanesechina'
    },
    'demographic-geo-taiwan-staying-in-usa': map{ 
        'label': 'Taiwanese in USA',
        'description': 'Taiwanese resident in USA',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoTaiwaneseusa'
    },
    'demographic-geo-asian-in-us': map{ 
        'label': 'Asian in USA',
        'description': 'Asian resident in USA',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoAsianusa'
    },
    'demographic-geo-us': map{ 
        'label': 'US',
        'description': 'US resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoUsa'
    },
    'demographic-geo-usa': map{ 
        'label': 'US',
        'description': 'US resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoUsa'
    },
    'demographic-geo-canada': map{ 
        'label': 'Canada',
        'description': 'Canadian resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoCanada'
    },
    'demographic-geo-hong-kong': map{ 
        'label': 'Hong Kong',
        'description': 'Hong Kong resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoHongkong'
    },
    'demographic-geo-singapore': map{ 
        'label': 'Singapore',
        'description': 'Singapore resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoSingapore'
    },
    'demographic-geo-zuo': map{ 
        'label': 'Zuo',
        'description': 'Zuo resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoZuo'
    },
    'demographic-geo-indonesia': map{ 
        'label': 'Indonesia',
        'description': 'Indonesian resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoIndonesia'
    },
    'demographic-geo-new-zealand': map{ 
        'label': 'New Zealand',
        'description': 'New Zealand resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoNewzealand'
    },
    'demographic-geo-new-bhutan': map{ 
        'label': 'Bhutan',
        'description': 'Bhutanese resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoBhutan'
    },
    'demographic-geo-australia': map{ 
        'label': 'Australia',
        'description': 'Australian resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoAustralia'
    },
    'demographic-geo-thailand': map{ 
        'label': 'Thailand',
        'description': 'Thai resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoThailand'
    },
    'demographic-geo-hungary': map{ 
        'label': 'Hungary',
        'description': 'Hungarian resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoHungary'
    },
    'demographic-geo-malaysia': map{ 
        'label': 'Malaysia',
        'description': 'Malaysian resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoMalaysia'
    },
    'demographic-geo-bhutan': map{ 
        'label': 'Bhutan',
        'description': 'Bhutan resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoBhutan'
    },
    'demographic-geo-united-kingdom': map{ 
        'label': 'UK',
        'description': 'UK resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoUK'
    },
    'demographic-geo-italy': map{ 
        'label': 'Italy',
        'description': 'Italian resident',
        'parentKey': 'demographic-geo',
        'outputKey': 'demographicGeoItaly'
    }
};

declare variable $json-types:attestation-types := map {
    'attestation-attestedSource': map{ 
        'label': 'Attested in source text',
        'description': 'This term is attested in a manuscript used as a source for this translation.',
        'outputKey': 'attestedSource'
    },
    'attestation-attestedOther': map{ 
        'label': 'Attested in an alternative text',
        'description': 'This term is attested in other manuscripts with a parallel or similar context.',
        'outputKey': 'attestedOther'
    },
    'attestation-attestedDictionary': map{ 
        'label': 'Attested in dictionary',
        'description': 'This term is attested in dictionaries matching Tibetan to the corresponding language.',
        'outputKey': 'attestedDictionary'
    },
    'attestation-attestedApproximate': map{ 
        'label': 'Approximate attestation',
        'description': 'The attestation of this name is approximate. It is based on other names where the relationship between the Tibetan and source language is attested in dictionaries or other manuscripts.',
        'outputKey': 'attestedApproximate'
    },
    'attestation-reconstructedPhonetic': map{ 
        'label': 'Reconstruction from Tibetan phonetic rendering',
        'description': 'This term is a reconstruction based on the Tibetan phonetic rendering of the term.',
        'outputKey': 'reconstructedPhonetic'
    },
    'attestation-reconstructedSemantic': map{ 
        'label': 'Reconstruction from Tibetan semantic rendering',
        'description': 'This term is a reconstruction based on the semantics of the Tibetan translation.',
        'outputKey': 'reconstructedSemantic'
    },
    'attestation-sourceUnspecified': map{ 
        'label': 'Source unspecified',
        'description': 'This term has been supplied from an unspecified source, which most often is a widely trusted dictionary.',
        'outputKey': 'sourceUnspecified'
    }
};

declare variable $json-types:title-types := map {
    'eft:mainTitle':                        'mainTitle',
    'eft:mainTitleOutsideCatalogueSection': 'mainTitleOutsideCatalogueSection',
    'eft:longTitle':                        'longTitle',
    'eft:otherTitle':                       'otherTitle',
    'eft:toh':                              'tohoku',
    'eft:shortcode':                        'shortcode'
};

declare variable $json-types:log-types := map {
    'translation-status':               'translationStatusChange',
    'text-version':                     'translationVersionChange',
    'draft-submitted':                  'translationDraftSubmitted',
    'publication-date':                 'translationSetPublicationDate',
    'import':                           'translationImportNote',
    'submission-generate-tei':          'teiGeneratedFromDraft',
    'submission-document-template':     'submissionSetAsDocument',
    'submission-spreadsheet-template':  'submissionSetAsSpreadsheet',
    'submission-apostrophes-checked':   'submissionApostrophesChecked',
    'progress-note-updated':            'progressNoteUpdated',
    'action-note-updated':              'actionNoteUpdated',
    'project-updated':                  'translationProjectUpdated',
    'file-generated':                   'fileGenerated',
    'webflow-updated':                  'webflowUpdated'
};

declare variable $json-types:catalogue-section-types := map {
    'section':        'canonicalSection',
    'grouping':       'textGrouping',
    'pseudo-section': 'nonCanonicalSection'
};

declare variable $json-types:control-data-types := map {
    'count-child-sections':            'countChildSections',
    'count-child-works':               'countChildWorks',
    'count-descendant-sections':       'countDescendantSections',
    'count-descendant-works':          'countDescendantWorks',
    'work-toh':                        'catalogueWorkToh',
    'work-start-volume':               'catalogueWorkStartVolume',
    'work-end-volume':                 'catalogueWorkEndVolume',
    'work-start-page':                 'catalogueWorkStartPage',
    'work-end-page':                   'catalogueWorkEndPage',
    'work-count-pages':                'catalogueWorkCountPages',
    'work-text-id':                    'workXmlid',
    'work-count-titles':               'workCountTitles',
    'work-count-passages':             'workCountPassages',
    'work-count-passage-annotations':  'workCountPassageAnnotations',
    'work-count-glossary-entries':     'workCountGlossaryEntries',
    'work-count-glossary-names':       'workCountGlossaryNames',
    'work-count-bibliography-entries': 'workCountBibliographyEntries',
    'work-count-source-authors':       'workCountSourceAuthors'
};

declare function json-types:object-relation($subject-xmlid as xs:string, $relation as xs:string, $object-xmlid as xs:string) as element(eft:objectRelation) {
    element { QName('http://read.84000.co/ns/1.0', 'objectRelation') } {
        attribute json:array { true() },
        attribute xmlId { string-join(($subject-xmlid, $relation, $object-xmlid), '/') },
        attribute subject_xmlid { $subject-xmlid },
        attribute relation { ($json-types:relation-types($relation), concat('unknown:', $relation))[1] },
        attribute object_xmlid { $object-xmlid }
    }
};

declare function json-types:annotation($subject-xmlid as xs:string, $type as xs:string, $content as xs:string?, $datetime as xs:dateTime?, $userId as xs:string?) as element(eft:annotation) {
    element { QName('http://read.84000.co/ns/1.0', 'annotation') } {
        attribute json:array { true() },
        attribute xmlId { string-join(($subject-xmlid, $type), '/') },
        attribute subject_xmlid { $subject-xmlid },
        attribute type { ($json-types:annotation-types($type), concat('unknown:', $type))[1] },
        attribute created_at { $datetime },
        attribute person { $userId },
        element content { $content }
    }
};

declare function json-types:classification($type as xs:string) as element(eft:classification) {
    element { QName('http://read.84000.co/ns/1.0', 'classification') } {
        attribute json:array { true() },
        attribute xmlId { $type },
        attribute type { ($json-types:classification-types($type)('outputKey'), concat('unknown:', $type))[1] },
        attribute name { $json-types:classification-types($type)('label') },
        attribute definition { $json-types:classification-types($type)('description') },
        attribute parent_xmlid { $json-types:classification-types($type)('parentKey') }
    }
};

declare function json-types:authority($xmlId as xs:string, $lastUpdated as xs:dateTime?, $headword as xs:string, $headword-language as xs:string?, $label as xs:string?, $definition as xs:string?) as element(eft:authority) {
    element { QName('http://read.84000.co/ns/1.0', 'authority') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute lastUpdated { ($lastUpdated, xs:dateTime("2024-12-01T00:00:00"))[1] }(:$lastUpdated[. instance of xs:dateTime] ! attribute lastUpdated { . }:),
        attribute url { concat('/rest/authorities.json?', string-join((concat('api-version=', $json-types:api-version),  concat('id=', $xmlId)), '&amp;')) },
        element headword { $headword },
        element headword_language { $headword-language },
        element label { $label },
        element definition { $definition }
    }
};

declare function json-types:authority-classification($authority-xmlid as xs:string, $classification-type as xs:string) as element(eft:authorityClassification) {
    element { QName('http://read.84000.co/ns/1.0', 'authorityClassification') } {
        attribute json:array { true() },
        attribute xmlId { string-join(($authority-xmlid, $classification-type, 'authorityClassification'), '/') },
        attribute authority_xmlid { $authority-xmlid },
        attribute classification_xmlid { ($json-types:classification-types($classification-type) ! $classification-type, concat('unknown:', $classification-type))[1] }
    }
};

declare function json-types:work($text-id as xs:string, $titles as element(eft:title)*, $tantric-restriction as xs:boolean, $glossary-excluded as xs:boolean, $version as xs:string, $version-date as xs:string?, $status as xs:string, $publication-date as xs:string?) as element(eft:work) {
    element { QName('http://read.84000.co/ns/1.0', 'work') } {
        attribute json:array {'true'},
        attribute workId { $text-id },
        attribute publicationVersion { $version },
        attribute publicationVersionDate { $version-date },
        attribute publicationStatus { $status },
        attribute publicationDate { $publication-date },
        element tantricRestriction { attribute json:literal { 'true' }, $tantric-restriction },
        element glossaryExcluded { attribute json:literal { 'true' }, $glossary-excluded },
        $titles
    }
};

declare function json-types:glossary($xmlId as xs:string, $glossaryXmlid as xs:string, $authorityXmlid as xs:string?, $nameXmlid as xs:string, $workXmlid as xs:string, $definition as xs:string?, $definitionRend as xs:string?, $termType as xs:string?, $attestation-key as xs:string?, $verified as xs:boolean, $glossMode as xs:string) as element(eft:glossary) {
    element { QName('http://read.84000.co/ns/1.0', 'glossary') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute glossary_xmlid { $glossaryXmlid },
        attribute authority_xmlid { $authorityXmlid },
        attribute name_xmlid  { $nameXmlid },
        attribute work_xmlid  { $workXmlid },
        element definition { $definition },
        element definition_rend { $definition ! concat(($definitionRend, 'incompatible')[1], 'WithStandard') },
        element termType { ($termType[. = ('translationMain', 'translationAlternative')], $termType ! concat('unknown:', .))[1] },
        element attestation { $attestation-key ! ($json-types:attestation-types(.) ! .('outputKey'), concat('unknown:', .))[1] },
        (:attribute type { ($json-types:classification-types($type)('outputKey'), concat('unknown:', $type))[1] },:)
        element verified { attribute json:literal { true() }, $verified },
        element glossMode { $glossMode }
    }
};

declare function json-types:creator($xmlId as xs:string, $authorityXmlid as xs:string?, $nameXmlid as xs:string, $workXmlid as xs:string, $type as xs:string) as element(eft:creator) {
    element { QName('http://read.84000.co/ns/1.0', 'creator') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute authority_xmlid { $authorityXmlid },
        attribute name_xmlid  { $nameXmlid },
        attribute work_xmlid  { $workXmlid },
        element type { ($json-types:creator-types($type), concat('unknown:', $type))[1] }
    }
};

declare function json-types:name($xmlId as xs:string, $language as xs:string, $content as xs:string, $authorityXmlid as xs:string?, $internalName as xs:boolean) as element(eft:name) {
    element { QName('http://read.84000.co/ns/1.0', 'name') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute language { $language },
        element content { $content },
        element content_transformed { 
            if($language eq 'Bo-Ltn') then 
                $content ! normalize-unicode(.) ! normalize-space(.) ! common:bo-term(.) 
            else () 
        },
        element internal { attribute json:literal { true() }, $internalName },
        element authority_xmlid { $authorityXmlid }
    }
};

declare function json-types:title($xmlId as xs:string, $language as xs:string, $workXmlid as xs:string, $type as xs:string, $content as xs:string, $attestation-key as xs:string?, $catalogueWorkXmlid as xs:string?) as element(eft:name) {
    element { QName('http://read.84000.co/ns/1.0', 'title') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute work_xmlid { $workXmlid },
        attribute type { ($json-types:title-types($type), concat('unknown:', $type))[1] },
        attribute language { $language },
        element catalogue_work_xmlid { ($catalogueWorkXmlid, attribute json:literal { true() })[1] },
        element attestation { $attestation-key ! $json-types:attestation-types(.)('outputKey') },
        element content { $content }
    }
};

declare function json-types:catalogue-section($xmlId as xs:string, $parentXmlid as xs:string, $type as xs:string, $label as xs:string?, $sort-index as xs:integer, $titles as element(eft:title)*, $description as xs:string?) as element(eft:catalogueSection) {
    element { QName('http://read.84000.co/ns/1.0', 'catalogueSection') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute parent_xmlid { $parentXmlid },
        attribute catalogueSectionType { ($json-types:catalogue-section-types($type), concat('unknown:', $type))[1] },
        element label { $label },
        element sortIndex { attribute json:literal { 'true' }, $sort-index },
        $titles,
        element description { $description }
    }
};

declare function json-types:catalogue-work($xmlId as xs:string, $sectionXmlid as xs:string, $workXmlid as xs:string, $description as xs:string?, $start-volume as xs:integer, $start-page as xs:integer, $end-volume as xs:integer, $end-page as xs:integer, $page-count as xs:integer) as element(eft:catalogueText)  {
    element { QName('http://read.84000.co/ns/1.0', 'catalogueWork') } {
        attribute json:array { true() },
        attribute xmlId { $xmlId },
        attribute work_xmlid { $workXmlid },
        attribute catalogue_section_xmlid { $sectionXmlid },
        attribute description { $description },
        element startVolume { attribute json:literal { 'true' }, $start-volume },
        element startPage { attribute json:literal { 'true' }, $start-page },
        element endVolume { attribute json:literal { 'true' }, $end-volume },
        element endPage { attribute json:literal { 'true' }, $end-page },
        element countPages { attribute json:literal { 'true' }, $page-count }
    }
};

declare function json-types:project($xmlId as xs:string, $workXmlid as xs:string, $contractId as xs:string?, $contractDate as xs:date?, $progressNote as xs:string?, $actionNote as xs:string?) as element(eft:project) {
    element { QName('http://read.84000.co/ns/1.0', 'project') } {
        attribute json:array {'true'},
        attribute xmlId { $xmlId },
        attribute work_xmlid  { $workXmlid },
        attribute contract_id  { $contractId },
        attribute contract_date  { $contractDate },
        element note_progress  { $progressNote },
        element note_next_action  { $actionNote }
    }
};

declare function json-types:project-target($xmlId as xs:string, $projectXmlid as xs:string, $status-id as xs:string, $datetime as xs:dateTime, $completedLogXmlid as xs:string?) as element(eft:project-target) {
    element { QName('http://read.84000.co/ns/1.0', 'project-target') } {
        attribute json:array {'true'},
        attribute xmlId { $xmlId },
        attribute project_xmlid  { $projectXmlid },
        attribute target_status { $status-id },
        attribute target_datetime { $datetime },
        attribute completed_log_xmlid { $completedLogXmlid }
    }
};

declare function json-types:submission($xmlId as xs:string, $projectXmlid as xs:string, $workXmlid as xs:string, $filename as xs:string, $filename-original as xs:string) as element(eft:submission) {
    element { QName('http://read.84000.co/ns/1.0', 'submission') } {
        attribute json:array {'true'},
        attribute xmlId { $xmlId },
        attribute project_xmlid  { $projectXmlid },
        attribute filename { $filename },
        attribute original_filename { $filename-original },
        attribute download_url { concat('https://projects.84000-translate.org/imported-file/?', string-join((concat('text-id=', $workXmlid), concat('submission-id=',$filename)), '&amp;')) }
    }
};

declare function json-types:log($xmlId as xs:string, $targetXmlid as xs:string, $type as xs:string, $datetime as xs:dateTime?, $user as xs:string?, $new-value as xs:string?, $description as xs:string?) as element(eft:log) {
    element { QName('http://read.84000.co/ns/1.0', 'log') } {
        attribute json:array {'true'},
        attribute xmlId { $xmlId },
        attribute target_xmlid  { $targetXmlid },
        attribute type { ($json-types:log-types($type), concat('unknown:', $type))[1] },
        attribute timestamp { $datetime },
        attribute user { $user },
        attribute newValue { $new-value },
        element description { $description }
    }
};

declare function json-types:control-data($targetXmlid as xs:string, $type as xs:string, $value as item()) as element(eft:controlData) {
    element { QName('http://read.84000.co/ns/1.0', 'controlData') } {
        attribute json:array {'true'},
        attribute target_xmlid  { $targetXmlid },
        element type { ($json-types:control-data-types($type), concat('unknown:', $type))[1] },
        element value { attribute json:literal { 'true' }, $value }
    }
};

declare function json-types:linked-data($subject-xmlid as xs:string, $relation as xs:string, $object-uri as xs:string) as element(eft:linkedData) {
    element { QName('http://read.84000.co/ns/1.0', 'linkedData') } {
        attribute json:array { true() },
        attribute subject_xmlid { $subject-xmlid },
        attribute relation { ($json-types:relation-types($relation), concat('unknown:', $relation))[1] },
        attribute object_uri { $object-uri }
    }
};
