=begin
Vericred API

Vericred's API allows you to search for Health Plans that a specific doctor
accepts.

## Getting Started

Visit our [Developer Portal](https://vericred.3scale.net/access_code?access_code=vericred&cms_token=3545ca52af07bde85b7c0c3aa9d1985e) to
create an account.

Once you have created an account, you can create one Application for
Production and another for our Sandbox (select the appropriate Plan when
you create the Application).

## Authentication

To authenticate, pass the API Key you created in the Developer Portal as
a `Vericred-Api-Key` header.

`curl -H 'Vericred-Api-Key: YOUR_KEY' "https://api.vericred.com/providers?search_term=Foo&zip_code=11215"`

## Versioning

Vericred's API default to the latest version.  However, if you need a specific
version, you can request it with an `Accept-Version` header.

The current version is `v3`.  Previous versions are `v1` and `v2`.

`curl -H 'Vericred-Api-Key: YOUR_KEY' -H 'Accept-Version: v2' "https://api.vericred.com/providers?search_term=Foo&zip_code=11215"`

## Pagination

Most endpoints are not paginated.  It will be noted in the documentation if/when
an endpoint is paginated.

When pagination is present, a `meta` stanza will be present in the response
with the total number of records

```
{
  things: [{ id: 1 }, { id: 2 }],
  meta: { total: 500 }
}
```

## Sideloading

When we return multiple levels of an object graph (e.g. `Provider`s and their `State`s
we sideload the associated data.  In this example, we would provide an Array of
`State`s and a `state_id` for each provider.  This is done primarily to reduce the
payload size since many of the `Provider`s will share a `State`

```
{
  providers: [{ id: 1, state_id: 1}, { id: 2, state_id: 1 }],
  states: [{ id: 1, code: 'NY' }]
}
```

If you need the second level of the object graph, you can just match the
corresponding id.

## Selecting specific data

All endpoints allow you to specify which fields you would like to return.
This allows you to limit the response to contain only the data you need.

For example, let's take a request that returns the following JSON by default

```
{
  provider: {
    id: 1,
    name: 'John',
    phone: '1234567890',
    field_we_dont_care_about: 'value_we_dont_care_about'
  },
  states: [{
    id: 1,
    name: 'New York',
    code: 'NY',
    field_we_dont_care_about: 'value_we_dont_care_about'
  }]
}
```

To limit our results to only return the fields we care about, we specify the
`select` query string parameter for the corresponding fields in the JSON
document.

In this case, we want to select `name` and `phone` from the `provider` key,
so we would add the parameters `select=provider.name,provider.phone`.
We also want the `name` and `code` from the `states` key, so we would
add the parameters `select=states.name,staes.code`.  The id field of
each document is always returned whether or not it is requested.

Our final request would be `GET /providers/12345?select=provider.name,provider.phone,states.name,states.code`

The response would be

```
{
  provider: {
    id: 1,
    name: 'John',
    phone: '1234567890'
  },
  states: [{
    id: 1,
    name: 'New York',
    code: 'NY'
  }]
}
```



OpenAPI spec version: 

Generated by: https://github.com/swagger-api/swagger-codegen.git


=end

require "uri"

module VericredClient
  class ProvidersApi
    attr_accessor :api_client

    def initialize(api_client = ApiClient.default)
      @api_client = api_client
    end

    # Find providers by term and zip code
    # All `Provider` searches require a `zip_code`, which we use for weighting
the search results to favor `Provider`s that are near the user.  For example,
we would want "Dr. John Smith" who is 5 miles away to appear before
"Dr. John Smith" who is 100 miles away.

The weighting also allows for non-exact matches.  In our prior example, we
would want "Dr. Jon Smith" who is 2 miles away to appear before the exact
match "Dr. John Smith" who is 100 miles away because it is more likely that
the user just entered an incorrect name.

The free text search also supports Specialty name search and "body part"
Specialty name search.  So, searching "John Smith nose" would return
"Dr. John Smith", the ENT Specialist before "Dr. John Smith" the Internist.


    # @param search_term String to search by
    # @param zip_code Zip Code to search near
    # @param [Hash] opts the optional parameters
    # @option opts [String] :accepts_insurance Limit results to Providers who accept at least one insurance plan.  Note that the inverse of this filter is not supported and any value will evaluate to true
    # @option opts [Array<String>] :hios_ids HIOS id of one or more plans
    # @option opts [String] :page Page number
    # @option opts [String] :per_page Number of records to return per page
    # @option opts [String] :radius Radius (in miles) to use to limit results
    # @return [InlineResponse200]
    def providers_get(search_term, zip_code, opts = {})
      data, _status_code, _headers = providers_get_with_http_info(search_term, zip_code, opts)
      return data
    end

    # Find providers by term and zip code
    # All &#x60;Provider&#x60; searches require a &#x60;zip_code&#x60;, which we use for weighting
the search results to favor &#x60;Provider&#x60;s that are near the user.  For example,
we would want &quot;Dr. John Smith&quot; who is 5 miles away to appear before
&quot;Dr. John Smith&quot; who is 100 miles away.

The weighting also allows for non-exact matches.  In our prior example, we
would want &quot;Dr. Jon Smith&quot; who is 2 miles away to appear before the exact
match &quot;Dr. John Smith&quot; who is 100 miles away because it is more likely that
the user just entered an incorrect name.

The free text search also supports Specialty name search and &quot;body part&quot;
Specialty name search.  So, searching &quot;John Smith nose&quot; would return
&quot;Dr. John Smith&quot;, the ENT Specialist before &quot;Dr. John Smith&quot; the Internist.


    # @param search_term String to search by
    # @param zip_code Zip Code to search near
    # @param [Hash] opts the optional parameters
    # @option opts [String] :accepts_insurance Limit results to Providers who accept at least one insurance plan.  Note that the inverse of this filter is not supported and any value will evaluate to true
    # @option opts [Array<String>] :hios_ids HIOS id of one or more plans
    # @option opts [String] :page Page number
    # @option opts [String] :per_page Number of records to return per page
    # @option opts [String] :radius Radius (in miles) to use to limit results
    # @return [Array<(InlineResponse200, Fixnum, Hash)>] InlineResponse200 data, response status code and response headers
    def providers_get_with_http_info(search_term, zip_code, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug "Calling API: ProvidersApi.providers_get ..."
      end
      # verify the required parameter 'search_term' is set
      fail ArgumentError, "Missing the required parameter 'search_term' when calling ProvidersApi.providers_get" if search_term.nil?
      # verify the required parameter 'zip_code' is set
      fail ArgumentError, "Missing the required parameter 'zip_code' when calling ProvidersApi.providers_get" if zip_code.nil?
      # resource path
      local_var_path = "/providers".sub('{format}','json')

      # query parameters
      query_params = {}
      query_params[:'search_term'] = search_term
      query_params[:'zip_code'] = zip_code
      query_params[:'accepts_insurance'] = opts[:'accepts_insurance'] if opts[:'accepts_insurance']
      query_params[:'hios_ids'] = @api_client.build_collection_param(opts[:'hios_ids'], :csv) if opts[:'hios_ids']
      query_params[:'page'] = opts[:'page'] if opts[:'page']
      query_params[:'per_page'] = opts[:'per_page'] if opts[:'per_page']
      query_params[:'radius'] = opts[:'radius'] if opts[:'radius']

      # header parameters
      header_params = {}

      # HTTP header 'Accept' (if needed)
      local_header_accept = []
      local_header_accept_result = @api_client.select_header_accept(local_header_accept) and header_params['Accept'] = local_header_accept_result

      # HTTP header 'Content-Type'
      local_header_content_type = []
      header_params['Content-Type'] = @api_client.select_header_content_type(local_header_content_type)

      # form parameters
      form_params = {}

      # http body (model)
      post_body = nil
            auth_names = []
      data, status_code, headers = @api_client.call_api(:GET, local_var_path,
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => 'InlineResponse200')
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: ProvidersApi#providers_get\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end

    # Find a specific Provider
    # To retrieve a specific provider, just perform a GET using his NPI number


    # @param npi NPI number
    # @param [Hash] opts the optional parameters
    # @return [InlineResponse2001]
    def providers_npi_get(npi, opts = {})
      data, _status_code, _headers = providers_npi_get_with_http_info(npi, opts)
      return data
    end

    # Find a specific Provider
    # To retrieve a specific provider, just perform a GET using his NPI number


    # @param npi NPI number
    # @param [Hash] opts the optional parameters
    # @return [Array<(InlineResponse2001, Fixnum, Hash)>] InlineResponse2001 data, response status code and response headers
    def providers_npi_get_with_http_info(npi, opts = {})
      if @api_client.config.debugging
        @api_client.config.logger.debug "Calling API: ProvidersApi.providers_npi_get ..."
      end
      # verify the required parameter 'npi' is set
      fail ArgumentError, "Missing the required parameter 'npi' when calling ProvidersApi.providers_npi_get" if npi.nil?
      # resource path
      local_var_path = "/providers/{npi}".sub('{format}','json').sub('{' + 'npi' + '}', npi.to_s)

      # query parameters
      query_params = {}

      # header parameters
      header_params = {}

      # HTTP header 'Accept' (if needed)
      local_header_accept = []
      local_header_accept_result = @api_client.select_header_accept(local_header_accept) and header_params['Accept'] = local_header_accept_result

      # HTTP header 'Content-Type'
      local_header_content_type = []
      header_params['Content-Type'] = @api_client.select_header_content_type(local_header_content_type)

      # form parameters
      form_params = {}

      # http body (model)
      post_body = nil
            auth_names = []
      data, status_code, headers = @api_client.call_api(:GET, local_var_path,
        :header_params => header_params,
        :query_params => query_params,
        :form_params => form_params,
        :body => post_body,
        :auth_names => auth_names,
        :return_type => 'InlineResponse2001')
      if @api_client.config.debugging
        @api_client.config.logger.debug "API called: ProvidersApi#providers_npi_get\nData: #{data.inspect}\nStatus code: #{status_code}\nHeaders: #{headers}"
      end
      return data, status_code, headers
    end
  end
end