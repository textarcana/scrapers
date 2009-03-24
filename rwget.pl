#!/usr/bin/env ruby
#== Synopsis
# Time-stamp <[c:/noah/n_s/tools/foo_tool/selenium-rc-tests/rwget.rb] was last modified by Noah Sussman at 13:46:48 on 2008.07.22 on 5M8DLC1-NYO.  (Serious Cat) v1.3>
# Based on the demo code packaged with Selenium-RC: 10:24:44 PM EST on Saturday, March 22 2008
# Rendered WGet and Rendered-Versus-Server-Source diff
# Get rendered HTML for a DHTML page and optionally compare it with the HTML stored on the server.
#
#== Examples
# Get the rendered HTML from site.com
#    rwget site.com
#
#== Usage
#    rwget [options] <http url>
#
#== Options
#    -d, --diff    diff the rendered source agains the server source.
#
#== Author
#    Noah Sussman (noah@onemorebug.com)
#
#== Copyright
#    Copyright (c) 2008 Noah Sussman under the MIT License:
#    http://www.opensource.org/licenses/mit-license.php


# URL: http://ajax.sys-con.com/node/507034

# Created in response to a discussion about "ghosting," between Kord Campbell of Splunk and Christian Heilman of Yahoo! at Ajax World 2008.

# IMPORTANT: The Selenium-RC server must be running on port 4444 (the default) and you must have Curl and Tidy installed on your system.

# NOTE: Diffing the rendered versus the "server" source. This option works OK as a learning tool, but I need to do more in terms of normalizing the server source versus the rendered source. I run both the "server" and innerHTML sources through Tidy, but unfortunately there still seems to be a lot of extraneous differences between them.

# So while this works OK for downloading the rendered source via a Ruby script, I've got a ways to go before it can produce a reliable "rendered diff."

require 'open3'
require 'rdoc/usage'
require 'uri'
#require '~/Documents/n_s/tools/foo_tool/selenium-rc-tests/selenium.rb'
require 'selenium'

#page = ARGV[0]
#click_on_id = ARGV[1]

def rendered_wget (list)
  #First arg is shifted off, any remaining args are assumed to be IDs and get clicked before the source is grabbed.
  page = list.shift()
  unless page =~ /^http:\/\//
    page = "http://" + page
  end
  page_url = URI.parse(page)
  remote_host = page_url.scheme + "://" + page_url.host
  @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox", remote_host, 10000);
#  @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*iexplore", remote_host, 10000);
  @selenium.start
  @selenium.open(page)
  @selenium.wait_for_page_to_load(5000)
  for id in (list)
    @selenium.click(id)
  end
  src = @selenium.get_html_source
  @selenium.stop
  return src
end

if (ARGV.length == 0)
  RDoc::usage('usage') 
elsif (ARGV[0] =~ /^-?-d/)
  #diff rendered vs. server source
  tidy_rendered, tidy_server = ""
  ARGV.shift()    #No more need for the -d option now that we know it was passed.
  server_src = `curl -s #{ARGV[0]}`
  rendered_src = rendered_wget ARGV    #corrupts ARGV
  Open3.popen3('tidy ') { |stdin, stdout, stderr| 
    stdin.puts rendered_src
    stdin.close_write	#without this the script will hang
    tidy_rendered = stdout.read
  }
  rendered_tmp = File.open("rwget_rendered.tmp", "w");
  rendered_tmp.puts tidy_rendered
  rendered_tmp.close
  Open3.popen3('tidy ') { |stdin, stdout, stderr| 
    stdin.puts server_src
    stdin.close_write	#without this the script will hang
    tidy_server = stdout.read
  }  
  server_tmp = File.open("rwget_server.tmp", "w");
  server_tmp.puts tidy_server
  server_tmp.close

  diffs = `diff -u rwget_server.tmp rwget_rendered.tmp`

  puts diffs

  `rm rwget_rendered.tmp rwget_server.tmp`

  #How do I diff 2 buffers without dumping to tmp files?
else
  #print rendered source
  puts rendered_wget(ARGV)
end
