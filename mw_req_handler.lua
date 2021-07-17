-- Prototype Lua script for Request Forward based on another upstream for condition

local httpc = require("resty.http").new()

local recv_str = "Request received at : " ..  ngx.now()
ngx.log(ngx.WARN, recv_str)


-- Header to add before forwarding to Request evaluation service

local process_header_name = "Nginx-Req-Handler"
local process_header_value = "true"

-- Header to be added after Request evaluation service responded 200, and before Forward the reqyest to actual upstream

local rl_enabled_name = "Condition-Check-Applied"
local rl_enabled_value = "true"

-- store the method, headers and body of actual request

local req_method =  ngx.req.get_method()
local req_body = ngx.req.get_body_data()
local req_headers = ngx.req.get_headers()

-- Sending request to Request evaluation service , with Nginx-Req-Hander header inserted

local res, err = httpc:request_uri("https://request-validation.service.cluster.local", {
     method = req_method,
     headers = {
         [process_header_name] = process_header_value
     }
})

-- Return if the request failed to send to  Request evaluation service

if not res then
    ngx.log(ngx.ERR, "Request failed : " , err)
end

-- Not really used, except status and body. Can be used to log the responses

local status =  res.status
local length = res.headers["Content-Length"]
local body = res.body

-- Forward the request to actual upstream if it gets a 200 response code and body contains "FORWARD" from Request evaluation service
-- It also insers the Condition-Check-Applied header
-- If it gets a non 200 response code, it returns 429 response code to actual request 

if (status == 200) and (string.match(body,"FORWARD")) then
    ngx.log(ngx.WARN, "Forward request")
    ngx.req.set_header(rl_enabled_name,rl_enabled_value)
    local res, err =  httpc:request_uri("https://application-service.service.cluster.local/app-service", {
        method = req_method ,
        body = req_body ,
        headers = req_headers
    })

    local final_body =  res.body;
    ngx.say(final_body)
    ngx.log(ngx.WARN, "Forward request completed")
else    
    ngx.exit(429)    
end

local req_done_str = "Request completed at : " .. ngx.now()

ngx.log(ngx.WARN, req_done_str)
