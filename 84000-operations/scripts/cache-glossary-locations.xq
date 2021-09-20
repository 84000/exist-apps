
(: Set job as running :)

scheduler:get-scheduled-jobs(),

util:log('info', system:get-module-load-path() (:|| '/' || request:get-parameter('param-name1', 'param-value-none'):))