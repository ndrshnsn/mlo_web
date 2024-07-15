# frozen_string_literal: true

# Pagy initializer file (6.0.4)

# Instance variables
# See https://ddnexus.github.io/pagy/docs/api/pagy#instance-variables
Pagy::DEFAULT[:page]   = 1                                  # default
Pagy::DEFAULT[:items]  = 15                                 # default
Pagy::DEFAULT[:outset] = 0                                  # default
Pagy::DEFAULT[:size]       = [1,4,4,1]                       # default
Pagy::DEFAULT[:page_param] = :page                           # default

# The :params can be also set as a lambda e.g ->(params){ params.exclude('useless').merge!('custom' => 'useful') }
# Pagy::DEFAULT[:params]     = {}                              # default
# Pagy::DEFAULT[:fragment]   = '#fragment'                     # example
# Pagy::DEFAULT[:link_extra] = 'data-remote="true"'            # example
# Pagy::DEFAULT[:i18n_key]   = 'pagy.item_name'                # default
# Pagy::DEFAULT[:cycle]      = true                            # example
# Pagy::DEFAULT[:request_path] = "/foo"                        # example

# Array extra: Paginate arrays efficiently, avoiding expensive array-wrapping and without overriding
# See https://ddnexus.github.io/pagy/docs/extras/array
# require 'pagy/extras/array'

# Headers extra: http response headers (and other helpers) useful for API pagination
# See http://ddnexus.github.io/pagy/extras/headers
# require 'pagy/extras/headers'
# Pagy::DEFAULT[:headers] = { page: 'Current-Page',
#                            items: 'Page-Items',
#                            count: 'Total-Count',
#                            pages: 'Total-Pages' }     # default

# Frontend Extras
require 'pagy/extras/bootstrap'
require 'pagy/extras/array'

# Feature Extras

# Gearbox extra: Automatically change the number of items per page depending on the page number
# See https://ddnexus.github.io/pagy/docs/extras/gearbox
# require 'pagy/extras/gearbox'
# set to false only if you want to make :gearbox_extra an opt-in variable
# Pagy::DEFAULT[:gearbox_extra] = false               # default true
# Pagy::DEFAULT[:gearbox_items] = [15, 30, 60, 100]   # default

# Items extra: Allow the client to request a custom number of items per page with an optional selector UI
# See https://ddnexus.github.io/pagy/docs/extras/items
# require 'pagy/extras/items'
# set to false only if you want to make :items_extra an opt-in variable
# Pagy::DEFAULT[:items_extra] = false    # default true
# Pagy::DEFAULT[:items_param] = :items   # default
# Pagy::DEFAULT[:max_items]   = 100      # default

# I18n

# When you are done setting your own default freeze it, so it will not get changed accidentally
#Pagy::DEFAULT.freeze