xquery version "3.0";

import module namespace store="http://read.84000.co/store" at "../../../84000-reading-room/modules/store.xql";

(
    (:store:http-download(concat($store:conf/@source-url, '/rest/catalogue.json'), '/db/apps/84000-static/json', 'catalogue.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities.json'), '/db/apps/84000-static/json', 'authorities.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/names.json'), '/db/apps/84000-static/json', 'names.json', $store:permissions-group),:)
    store:http-download(concat($store:conf/@source-url, '/rest/glossaries.json'), '/db/apps/84000-static/json', 'glossaries.json', $store:permissions-group),
    (:store:http-download(concat($store:conf/@source-url, '/rest/creators.json'), '/db/apps/84000-static/json', 'creators.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/classifications.json'), '/db/apps/84000-static/json', 'classifications.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities-classifications.json'), '/db/apps/84000-static/json', 'authorities-classifications.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities-relations.json'), '/db/apps/84000-static/json', 'authorities-relations.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities-annotations.json'), '/db/apps/84000-static/json', 'authorities-annotations.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/translation-projects.json'), '/db/apps/84000-static/json', 'translation-projects.json', $store:permissions-group),:)
    (:store:http-download(concat($store:conf/@source-url, '/rest/works-relations.json'), '/db/apps/84000-static/json', 'works-relations.json', $store:permissions-group),:)
    ()
)