#!/usr/bin/env ruby

require 'daemons'

Daemons.run('pagebot.rb', :app_name => 'pagebot',
            :multiple => false,
            :monitor => true,
            :log_output => true)