xquery version "3.0";

import module namespace store="http://read.84000.co/store" at "../../../84000-reading-room/modules/store.xql";

(
    (:store:http-download(concat($store:conf/@source-url, '/rest/catalogue.json'), '/db/apps/84000-static/json', 'catalogue.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities.json'), '/db/apps/84000-static/json', 'authorities.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/names.json'), '/db/apps/84000-static/json', 'names.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/glossaries.json'), '/db/apps/84000-static/json', 'glossaries.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/creators.json'), '/db/apps/84000-static/json', 'creators.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/classifications.json'), '/db/apps/84000-static/json', 'classifications.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities-classifications.json'), '/db/apps/84000-static/json', 'authorities-classifications.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/object-relations.json'), '/db/apps/84000-static/json', 'object-relations.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/annotations.json'), '/db/apps/84000-static/json', 'annotations.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/texts-status.json'), '/db/apps/84000-static/json', 'texts-status.json', $store:permissions-group),:)
    ()
)