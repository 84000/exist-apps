xquery version "3.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace eft="http://read.84000.co/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

import module namespace store="http://read.84000.co/store" at "../../../84000-reading-room/modules/store.xql";

(
    (:store:http-download(concat($store:conf/@source-url, '/rest/authorities.json?data-mode=authorities'), '/db/apps/84000-data/uploads/export-to-cms', 'authorities.json', $store:permissions-group),:)
    store:http-download(concat($store:conf/@source-url, '/rest/authorities.json?data-mode=classifications'), '/db/apps/84000-data/uploads/export-to-cms', 'authority-classifications.json', $store:permissions-group)(:,
    store:http-download(concat($store:conf/@source-url, '/rest/authorities.json?data-mode=annotations'), '/db/apps/84000-data/uploads/export-to-cms', 'authority-annotations.json', $store:permissions-group):)
)