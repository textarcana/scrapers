#!/usr/bin/env ruby
# :title:Simple Hpricot Examples
# = Name
# Simple Hpricot Examples
# = Description
# Simple examples of using Hpricot to parse XML.

module HpricotHelper

  def read_file target

    begin

      # return this...
      File.open(target, "r")

    rescue

      # ...or die with message
      puts "usage:    ruby simple.rb <file>"
      exit 1

    end

  end

  def dump_file_dom filehandle
    
    fh = filehandle

    dom = Hpricot(fh.read)

  end

end
