xquery version "3.0";

declare namespace eft = "http://read.84000.co/ns/1.0";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

import module namespace common = "http://read.84000.co/common" at "../../../modules/common.xql";
import module namespace entities = "http://read.84000.co/entities" at "../../../modules/entities.xql";
import module namespace functx="http://www.functx.com";

declare option output:method "json";
declare option output:indent "yes";
declare option output:media-type "application/json";
declare option output:json-ignore-whitespace-text-nodes "yes";

declare variable $local:api-version := '0.4.0';

declare variable $local:request-entity-id := request:get-parameter('entity', '');

declare variable $local:operations-data := collection(concat($common:data-path, '/operations'));
declare variable $local:entities := $local:operations-data//eft:entities;
declare variable $local:contributors := $local:operations-data//eft:contributors;
declare variable $local:sponsors := $local:operations-data//eft:sponsors;

declare variable $local:request-entity := $local:operations-data/id($local:request-entity-id);

declare variable $local:xslt := doc(concat($common:app-path, "/xslt/tei-to-xhtml.xsl"));
declare variable $local:html5-serialization-parameters := 
    element { QName('http://www.w3.org/2010/xslt-xquery-serialization','serialization-parameters') }{
        element method { 
            attribute value { 'html5' }
        },
        element media-type { 
            attribute value { 'text/html' }
        },
        element suppress-indentation { 
            attribute value { 'yes' }
        }
    };

element entities {
    
    attribute modelType { 'entities' },
    attribute apiVersion { $local:api-version },
    attribute url { concat('/rest/entities.json?', string-join(( $local:request-entity/@xml:id ! concat('entity-id=', .), concat('api-version=', $local:api-version)), '&amp;')) },
    
    (: Entities :)
    for $entity in $local:entities/eft:entity
    where not($local:request-entity-id gt '') or $entity[@xml:id eq $local:request-entity-id]
    return
        element authority {
            attribute type { 'eft:entity' },
            attribute xmlId { $entity/@xml:id },
            element heading { ($entity/eft:label[@xml:lang eq 'en'], $entity/eft:label)[1] ! string-join(text()) ! normalize-space(.) },
            element definition {
                let $definitions := $entity/eft:content[@type eq 'glossary-definition'][descendant::text()[normalize-space()]]
                where $definitions
                let $definition-tei := $definitions ! element { QName('http://www.tei-c.org/ns/1.0', 'p') } { . }
                let $definition-html := $definition-tei ! transform:transform(., $local:xslt, <parameters/>)
                return
                    string-join($definition-html ! serialize(., $local:html5-serialization-parameters) ! replace(., concat('^',functx:escape-for-regex('&lt;!DOCTYPE html&gt;'),'\s*'), '')) ! normalize-space(.)                       
                
            }
        }
    ,
    
    (: Contributors :)
    for $contributor in $local:contributors/eft:person
    where not($local:request-entity-id gt '') or $contributor[@xml:id eq $local:request-entity-id]
    return
        element authority {
            attribute type { 'eft:contributor' },
            attribute xmlId { $contributor/@xml:id },
            element heading { ($contributor/eft:label)[1] ! string-join(text()) ! normalize-space(.) },
            element definition {  }
        }
    ,
    
    (: Teams :)
    for $team in $local:contributors/eft:team
    where not($local:request-entity-id gt '') or $team[@xml:id eq $local:request-entity-id]
    return
        element authority {
            attribute type { 'eft:translationTeam' },
            attribute xmlId { $team/@xml:id },
            element heading { ($team/eft:label)[1] ! string-join(text()) ! normalize-space(.) },
            element definition {  }
        }
    ,
    
    (: Institutions :)
    for $institution in $local:contributors/eft:institution
    where not($local:request-entity-id gt '') or $institution[@xml:id eq $local:request-entity-id]
    return
        element authority {
            attribute type { 'eft:institution' },
            attribute xmlId { $institution/@xml:id },
            element heading { ($institution/eft:label)[1] ! string-join(text()) ! normalize-space(.) },
            element definition {  }
        }
    ,
    
    (: Sponsors :)
    for $sponsor in $local:sponsors/eft:sponsor
    where not($local:request-entity-id gt '') or $sponsor[@xml:id eq $local:request-entity-id]
    return
        element authority {
            attribute type { 'eft:sponsor' },
            attribute xmlId { $sponsor/@xml:id },
            element heading { ($sponsor/eft:label)[1] ! string-join(text()) ! normalize-space(.) },
            element definition {  }
        }
    
}