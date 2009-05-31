#!/usr/bin/env ruby
# :title:Simple Hpricot Examples
# = Name
# Simple Hpricot Examples
# = Description
# Simple examples of using Hpricot to parse XML.

require 'rubygems'

require 'hpricot'

module HpricotHelper

  def read_file target

    begin

      # return this...
      File.open(target, "r")

    rescue

      # ...or die with message
      puts "first argument should have been <file>"
      exit 1

    end

  end

  def dom_from_file target

    fh = read_file target
    
    dom = Hpricot(fh.read)

  end

  def get_by_tagname dom, tagName

    dom.search(tagName).to_a

  end

  # == retrieve just the text content from all the tags of a certain type
  def get_articles_by_tagname dom, tagName

    accumulator = []

    articles = get_by_tagname dom, tagName

    articles.each do | raw |
    
      accumulator.push raw.inner_text
  
    end
    
    accumulator

  end

end

# For example:
#
#     require 'hpricot_helper'
#     include HpricotHelper
#     d = dom_from_file 'sample_data/simpsons.xml'
#     a = get_articles_by_tagname d, 'familymember'
