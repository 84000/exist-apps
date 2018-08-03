xquery version "3.1";

(:~
 : Borrows several functions from eXist book.
 :)

import module namespace config="http://agilehumanities.ca/apps/84000/config" 
  at "modules/config.xqm";

(:----------------------------------------------------------------------------:)

declare function local:get-base-path($path as xs:string) as xs:string
(: Returns the path leading up to the last part in $path. E.g. /a/b/c/d ==> /a/b/c :)
{
  replace($path, '(.*)[/\\][^/\\]+$', '$1')  
};

(:----------------------------------------------------------------------------:)

declare function local:get-name($path as xs:string) as xs:string
(: Returns the final name of a path. E.g. /a/b/c/d ==> d :)
{
  replace($path, '.*[/\\]([^/\\]+)$', '$1')
};

(:----------------------------------------------------------------------------:)

declare function local:get-load-path() as xs:string
(: Returns the load path of the application: Where did the repository manager install it? :)
{
  (: The function system:get-module-load-path() returns something with the string 'embedded-eXist-server' in it. 
     Strange. The following regexp makes this a normal path, even if this string string should disappear in a
     future release. :)
    local:get-base-path(
      replace(system:get-module-load-path(), '^(xmldb:exist://)?(embedded-eXist-server)?(.+)$', '$3')
    )
};

(:----------------------------------------------------------------------------:)

declare function local:report-error($msg-parts as xs:string*) as item()?
{
  error(xs:QName('local:ERROR'), string-join($msg-parts, ''))
};

(:----------------------------------------------------------------------------:)

declare function local:create-collection-path($collection-path as xs:string) as xs:boolean
(: Creates the given collection path (and all sub-collections leading up to it) :)
{
  if (xmldb:collection-available($collection-path)) 
    then true() 
    else
      (: The collection does not exist. First make sure the path leading up to this
         exists and afterwards create it: :)    
      let $collection := local:get-name($collection-path)
      let $base-path := local:get-base-path($collection-path)
      return
        if (local:create-collection-path($base-path))
          then 
            if (exists(xmldb:create-collection($base-path, $collection)))
              then true()
              else local:report-error(('Error creating collection ', $collection, ' in ', $base-path))
          else false()
};

(:----------------------------------------------------------------------------:)

declare function local:create-data-root() as xs:boolean
(: Creates $config:data-root and sets permissions, if 
 : it doesn't already exist.
 :)
{
	if (xmldb:collection-available($config:data-root))
		then true()
	else
		let	$data-root-created := local:create-collection-path($config:data-root)
		let $owner := sm:chown(xs:anyURI($config:data-root), $config:app-user)
		let $group := sm:chgrp(xs:anyURI($config:data-root), $config:app-group)
	return $data-root-created
};

(:----------------------------------------------------------------------------:)

declare function local:create-data-collections() as xs:boolean
(: Creates the wordDocs and TEIDocs collections :)
{
	let $data-root-created := local:create-data-root()
	let $collection-status :=
		for $collection in ($config:wordDocs, $config:TEIDocs)
			let $created := local:create-collection-path($collection)
			let $owner := sm:chown(xs:anyURI($collection), $config:app-user)
			let $group := sm:chgrp(xs:anyURI($collection), $config:app-group)
			let $allowed := sm:chmod(xs:anyURI($collection), 'rwxrwxrwx')
		return xmldb:collection-available($collection)
	
	return (xmldb:collection-available($config:wordDocs) and
		      xmldb:collection-available($config:TEIDocs))
};

(:----------------------------------------------------------------------------:)

declare function local:create-app-user() as xs:boolean
{
	let $create-user :=
		if (sm:user-exists($config:app-user))
			then true()
		else sm:create-account($config:app-user, "", $config:app-user, ())

	let $create-group :=
		if (sm:group-exists($config:app-group))
			then true()
		else sm:create-group($config:app-group, $config:app-user, "")

	return sm:user-exists($config:app-user)
};

(:----------------------------------------------------------------------------:)

let $userCreated := local:create-app-user()
let $dataCollectionsCreated := local:create-data-collections()
return ($userCreated and $dataCollectionsCreated)